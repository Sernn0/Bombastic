# Bomb System 설계 문서

> Task #9, #10, #11 통합 설계 — 코드 구현 전 명세

---

## 1. passBomb Callable Function (Task #9)

### 개요

`passBomb`는 `functions.https.onCall`로 구현하는 Cloud Function이다.
현재 폭탄 보유자가 다음 사람에게 폭탄을 넘기는 핵심 게임 로직을 서버에서 처리한다.

아키텍처 원칙(무결성이 중요한 쓰기는 Cloud Functions 경유)에 따라,
클라이언트의 `BombRepository.passBomb()`는 이 Callable Function 호출로 대체한다.

### 파일 위치

`functions/src/bomb/passBomb.ts` — 신규 파일, `index.ts`에서 export 추가

### Input / Output

```typescript
// Request
interface PassBombRequest {
  groupId: string;       // 그룹 ID
  currentBombId: string; // 현재 폭탄 문서 ID
}

// Response (성공)
interface PassBombResponse {
  success: true;
  nextHolderUid: string;
  newExpiresAt: FirebaseFirestore.Timestamp;
}
```

### 인증 및 검증 단계

1. **인증 확인**: `context.auth`가 null이면 `unauthenticated` 에러
2. **입력 검증**: `groupId`, `currentBombId`가 유효한 문자열인지 확인
3. **그룹 문서 조회**: `groups/{groupId}` → `status === 'playing'` 확인
4. **폭탄 문서 조회**: `groups/{groupId}/bombs/{currentBombId}` →
   - `status === 'active'` 확인
   - `holderUid === context.auth.uid` 확인 (본인 소유만 전달 가능)
   - `expiresAt > now` 확인 (만료된 폭탄은 스케줄러가 폭발 처리)

### Firestore Transaction 흐름

기존 `BombRepository.passBomb()`가 bomb 문서를 in-place update하는 패턴을 사용하므로,
**기존 bomb 문서를 업데이트하는 방식을 유지**한다.

이유:
- `watchActiveBomb`가 `status == active` + `limit(1)` 쿼리를 사용하므로 문서가 하나면 충돌 없음
- round 값은 폭발 후 새 폭탄 생성 시에만 증가 → pass 시에는 같은 문서 재사용이 자연스러움
- 클라이언트 Stream이 동일 문서를 watch하므로 끊김 없음

```pseudocode
runTransaction:
  // 1. Read
  groupDoc = tx.get(groups/{groupId})
  bombDoc  = tx.get(groups/{groupId}/bombs/{currentBombId})

  // 2. Validate (transaction 내 최신 데이터 기준)
  assert groupDoc.status == 'playing'
  assert bombDoc.status == 'active'
  assert bombDoc.holderUid == callerUid
  assert bombDoc.expiresAt > now

  // 3. 다음 홀더 계산 (Section 2 참조)
  memberUids = groupDoc.memberUids
  direction  = groupDoc.passDirection ?? 'forward'
  nextHolder = getNextHolder(memberUids, callerUid, direction)

  // 4. 폭탄 문서 업데이트
  duration = getDurationForPlayerCount(memberUids.length)
  tx.update(bombRef, {
    holderUid: nextHolder,
    receivedAt: serverTimestamp(),
    expiresAt: Timestamp.fromMillis(Date.now() + duration)
  })

  // 5. 아이템 효과 적용 지점 (TODO)
  // - enhancePenalty 활성 시: penaltyMultiplier 필드는 이미 bomb 문서에 설정됨
  // - swapOrder 적용 시: memberUids가 이미 셔플된 상태이므로 추가 처리 불필요
  // - addBomb: 별도 Callable Function (useItem)으로 분리
```

### 에러 처리

| 조건 | HttpsError 코드 | 메시지 |
|------|-----------------|--------|
| 미인증 | `unauthenticated` | 로그인이 필요합니다 |
| 잘못된 입력 | `invalid-argument` | groupId와 currentBombId가 필요합니다 |
| 그룹 없음 | `not-found` | 그룹을 찾을 수 없습니다 |
| 게임 미진행 | `failed-precondition` | 게임이 진행 중이 아닙니다 |
| 폭탄 없음/비활성 | `not-found` | 활성 폭탄을 찾을 수 없습니다 |
| 본인 폭탄 아님 | `permission-denied` | 본인의 폭탄만 전달할 수 있습니다 |
| 이미 만료 | `failed-precondition` | 폭탄이 이미 만료되었습니다 |

### 클라이언트 연동 변경

`GameController.passBomb()` (현재 TODO 상태)를 Callable Function 호출로 구현:

```
GameController.passBomb(bombId):
  result = CloudFunctions.instance.httpsCallable('passBomb').call({
    groupId: currentGroupId,
    currentBombId: bombId,
  })
```

`BombRepository.passBomb()`는 제거하고 Callable Function만 사용한다.

---

## 2. memberUids 인덱스 기반 순환 로직 & 제한시간 (Task #10)

### 순환 알고리즘

```pseudocode
function getNextHolder(memberUids: string[], currentUid: string, direction: string): string
  n = memberUids.length
  i = memberUids.indexOf(currentUid)

  if i == -1:
    throw Error("현재 보유자가 멤버 목록에 없습니다")

  if direction == 'forward':
    return memberUids[(i + 1) % n]
  else:  // 'reverse'
    return memberUids[(i - 1 + n) % n]
```

**예시 (5명: [A, B, C, D, E])**:

| 현재 보유자 | forward (다음) | reverse (다음) |
|------------|---------------|---------------|
| A (idx 0) | B (idx 1) | E (idx 4) |
| C (idx 2) | D (idx 3) | B (idx 1) |
| E (idx 4) | A (idx 0, wrap) | D (idx 3) |

### passDirection 필드 위치: GroupModel

방향은 **그룹 단위 상태**로 관리한다.

**GroupModel 변경:**
```dart
@Default('forward') String passDirection,  // 'forward' | 'reverse'
```

**근거:**
- 방향 변경은 다음 전달부터 그룹 전체에 적용됨 (특정 폭탄 귀속 아님)
- swapOrder 아이템과 방향 모두 그룹 문서에 있어야 일관성 유지
- BombModel에 두면 폭발 후 새 폭탄 생성 시 이전 폭탄 참조 필요 → 불필요한 의존성

### swapOrder 아이템과의 상호작용

swapOrder는 `memberUids` 배열 자체를 셔플한다 (사용자 본인 위치는 유지):

```pseudocode
function applySwapOrder(memberUids, callerUid):
  callerIndex = memberUids.indexOf(callerUid)
  others = memberUids.filter(uid => uid != callerUid)
  shuffled = shuffle(others)  // Fisher-Yates
  result = [...shuffled]
  result.splice(callerIndex, 0, callerUid)  // 원래 위치에 재삽입
  return result
```

### 폭탄 제한시간 분석

**현재**: `defaultBombDurationSeconds = 86400` (24시간 고정)

**문제**: 24시간 고정은 인원이 많을수록 사이클이 느려진다.

| 플레이어 수 | 24h 기준 1사이클 | 4일 내 사이클 수 |
|------------|----------------|----------------|
| 2명 | 2일 | 2회 |
| 3명 | 3일 | 1.3회 |
| 5명 | 5일 | 0.8회 (미완) |
| 10명 | 10일 | 0.4회 (미완) |

5명 이상이면 minGameDays(4일) 내 1사이클도 못 돈다.

### 권장: 플레이어 수별 고정 제한시간 테이블

목표: minGameDays(4일) 내 최소 2사이클 보장

```typescript
// functions/src/bomb/constants.ts
export const BOMB_DURATION_TABLE: Record<number, number> = {
  2:  86400000,  // 24시간
  3:  57600000,  // 16시간
  4:  43200000,  // 12시간
  5:  36000000,  // 10시간
  6:  28800000,  // 8시간
  7:  25200000,  // 7시간
  8:  21600000,  // 6시간
  9:  19200000,  // ~5.3시간
  10: 17280000,  // ~4.8시간
};

export function getDurationForPlayerCount(count: number): number {
  return BOMB_DURATION_TABLE[count] ?? 86400000;
}
```

| 플레이어 수 | 제한시간 | 4일 내 사이클 수 |
|------------|---------|----------------|
| 2명 | 24시간 | 2.0회 |
| 3명 | 16시간 | 2.0회 |
| 4명 | 12시간 | 2.0회 |
| 5명 | 10시간 | 1.9회 |
| 6명 | 8시간 | 2.0회 |
| 10명 | 4.8시간 | 2.0회 |

고정 테이블이 동적 계산보다 직관적이고 밸런스 조정이 개별적으로 가능하다.

### AppConstants 변경 명세

```dart
// lib/core/constants/app_constants.dart 에 추가

/// 폭탄 제한시간 하한 (초) — 최소 4시간
static const int minBombDurationSeconds = 14400;

/// 폭탄 제한시간 상한 (초) — 최대 24시간
static const int maxBombDurationSeconds = 86400;

/// 게임 기간 내 목표 최소 사이클 수
static const int targetMinCycles = 2;

// defaultBombDurationSeconds (86400) 유지 — fallback 및 클라이언트 타이머 표시용
```

Cloud Functions 측 상수는 `functions/src/bomb/constants.ts` 신규 파일에 배치.

---

## 3. 아이템 속성 2종 분리 (Task #11)

### 개요

아이템을 두 가지 사용 타입으로 분류:
- **bombHolder**: 폭탄 보유 중이며 턴 넘기기 전에만 사용 가능
- **always**: 폭탄 소유 여부 관계없이 언제든 사용 가능

### ShopItemModel 변경

```dart
// lib/data/models/shop_item_model.dart

enum ItemType { swapOrder, addBomb, enhancePenalty, shrinkDuration, reverseDirection, adjustGameDays }

enum ItemUsageType { bombHolder, always }  // 신규 enum

@freezed
abstract class ShopItemModel with _$ShopItemModel {
  const factory ShopItemModel({
    required String id,
    required String name,
    required String description,
    required int price,
    required ItemType type,
    required ItemUsageType usageType,   // 신규 필드
    @Default(true) bool isAvailable,
  }) = _ShopItemModel;

  factory ShopItemModel.fromJson(Map<String, dynamic> json) =>
      _$ShopItemModelFromJson(json);
}
```

### 아이템 분류표

| ItemType | usageType | 근거 |
|----------|-----------|------|
| `swapOrder` | `always` | 순서 셔플은 방어(순서 변경으로 회피)/공격(특정 대상에게 유도) 모두 가능. 폭탄 보유 여부 무관 |
| `addBomb` | `always` | 새 폭탄 추가는 게임 전체에 영향. 비보유자도 상대 압박 목적으로 사용 가능 |
| `enhancePenalty` | `bombHolder` | 보유 중인 폭탄의 패널티를 강화한 뒤 전달하는 것이 핵심 전략. 폭탄이 없으면 강화 대상 없음 |
| `shrinkDuration` | `always` | 폭탄 제한시간을 단축시켜 긴장감 증가. 폭탄 보유 여부와 무관하게 전략적 사용 가능 |
| `reverseDirection` | `bombHolder` | 보유 중인 폭탄의 전달 방향을 반전시킨 뒤 넘기는 전략. 폭탄을 들고 있어야 방향 전환 의미 있음 |
| `adjustGameDays` | `always` | 게임 기간을 n일 증가/감소. 게임 전체에 영향을 미치므로 언제든 사용 가능 |

### BombModel 변경 (enhancePenalty 지원)

```dart
// lib/data/models/bomb_model.dart 에 필드 추가
@Default(1) int penaltyMultiplier,   // enhancePenalty 적용 시 증가
```

`bombExpireScheduler.ts` 폭발 처리에서 반영:
```typescript
// 기존: FieldValue.increment(1)
// 변경: FieldValue.increment(data.penaltyMultiplier ?? 1)
```

### 인벤토리 구조 권장 변경

현재 `UserModel.ownedItemIds` (List<String>) → `inventory` (Map<String, int>) 전환 권장:

```dart
// UserModel 변경
@Default({}) Map<String, int> inventory,
// 예: { "swapOrder": 2, "addBomb": 1, "enhancePenalty": 0 }
```

이유: 동일 아이템 다중 보유 시 List에 같은 문자열 반복보다 Map이 Firestore 읽기/쓰기 모두 효율적.

### 아이템 사용 흐름

#### always 타입 (swapOrder, addBomb, shrinkDuration, adjustGameDays)

```pseudocode
// useItem Callable Function
function useItem(groupId, itemType, callerUid):
  // 1. 인증 및 소유 확인
  userDoc = get(users/{callerUid})
  assert userDoc.inventory[itemType] > 0

  // 2. 그룹 playing 상태 확인
  groupDoc = get(groups/{groupId})
  assert groupDoc.status == 'playing'

  // 3. 효과 적용
  switch itemType:
    case 'swapOrder':
      newOrder = applySwapOrder(groupDoc.memberUids, callerUid)
      tx.update(groupRef, { memberUids: newOrder })

    case 'addBomb':
      nextHolder = getNextHolder(groupDoc.memberUids, callerUid, groupDoc.passDirection)
      duration = getDurationForPlayerCount(groupDoc.memberUids.length)
      tx.set(newBombRef, {
        groupId, holderUid: nextHolder,
        receivedAt: serverTimestamp(),
        expiresAt: Timestamp.fromMillis(Date.now() + duration),
        status: 'active',
        round: currentMaxRound + 1,
        penaltyMultiplier: 1
      })

    case 'shrinkDuration':
      // 현재 활성 폭탄들의 expiresAt을 일정 비율만큼 단축
      // 예: 남은 시간의 50% 차감, 하한선 = minBombDurationSeconds
      activeBombs = query(groups/{groupId}/bombs, status == 'active')
      for bomb in activeBombs:
        remaining = bomb.expiresAt - now
        shrunk = max(remaining * 0.5, MIN_BOMB_DURATION_MS)
        tx.update(bombRef, { expiresAt: Timestamp.fromMillis(now + shrunk) })

    case 'adjustGameDays':
      // 게임 종료일을 ±1일 조정 (gameEndedAt 기준)
      // 상한: maxGameDays, 하한: minGameDays
      // 사용 시 증가/감소 방향은 클라이언트에서 선택 (request에 direction 포함)
      currentEnd = groupDoc.gameEndedAt ?? (groupDoc.gameStartedAt + maxGameDays)
      newEnd = currentEnd + (adjustDirection * 1day)
      elapsed = (newEnd - groupDoc.gameStartedAt) / 1day
      assert minGameDays <= elapsed <= maxGameDays
      tx.update(groupRef, { gameEndedAt: newEnd })

  // 4. 인벤토리 차감
  tx.update(userRef, { [`inventory.${itemType}`]: FieldValue.increment(-1) })
```

#### bombHolder 타입 (enhancePenalty, reverseDirection)

```pseudocode
function useItem(groupId, itemType, callerUid):
  // 1~2: 동일

  // 2.5: 추가 검증 — 폭탄 보유자인지 확인
  activeBombs = query(groups/{groupId}/bombs, status == 'active', holderUid == callerUid)
  assert activeBombs.length > 0
  targetBomb = activeBombs[0]

  // 3. 효과 적용
  switch itemType:
    case 'enhancePenalty':
      currentMultiplier = targetBomb.penaltyMultiplier ?? 1
      tx.update(targetBombRef, { penaltyMultiplier: currentMultiplier + 1 })

    case 'reverseDirection':
      // 그룹의 passDirection을 반전 (forward ↔ reverse)
      // 폭탄을 들고 있는 상태에서 방향을 바꾼 뒤 전달하면 예상 밖의 사람에게 감
      currentDir = groupDoc.passDirection ?? 'forward'
      newDir = currentDir == 'forward' ? 'reverse' : 'forward'
      tx.update(groupRef, { passDirection: newDir })

  // 4. 인벤토리 차감 (동일)
```

### Game UI 아이템 활성화 로직

```pseudocode
function isItemUsable(item: ShopItemModel, isMyTurn: bool, inventoryCount: int): bool
  if inventoryCount <= 0:
    return false

  if item.usageType == ItemUsageType.bombHolder:
    return isMyTurn   // 폭탄 보유 중일 때만
  else:  // always
    return true       // 언제든 가능
```

게임 화면(`_PlayingView`)에 아이템 패널 추가:
- 각 보유 아이템을 버튼으로 표시
- `bombHolder` 아이템: `isMyTurn == false`이면 비활성화 (greyed out)
- `always` 아이템: 보유 수량 > 0이면 항상 활성화
- 사용 시 `useItem` Callable Function 호출

### Firestore shopItems 시드 데이터

```json
[
  {
    "id": "swapOrder",
    "name": "순서 섞기",
    "description": "폭탄 전달 순서를 랜덤으로 섞습니다 (내 위치 유지)",
    "price": 50,
    "type": "swapOrder",
    "usageType": "always",
    "isAvailable": true
  },
  {
    "id": "addBomb",
    "name": "폭탄 추가",
    "description": "새로운 폭탄을 게임에 추가합니다",
    "price": 80,
    "type": "addBomb",
    "usageType": "always",
    "isAvailable": true
  },
  {
    "id": "enhancePenalty",
    "name": "패널티 강화",
    "description": "현재 들고 있는 폭탄의 패널티를 강화합니다",
    "price": 100,
    "type": "enhancePenalty",
    "usageType": "bombHolder",
    "isAvailable": true
  },
  {
    "id": "shrinkDuration",
    "name": "시간 단축",
    "description": "모든 활성 폭탄의 남은 제한시간을 50% 단축합니다",
    "price": 60,
    "type": "shrinkDuration",
    "usageType": "always",
    "isAvailable": true
  },
  {
    "id": "reverseDirection",
    "name": "방향 반전",
    "description": "폭탄 전달 방향을 반대로 바꿉니다",
    "price": 70,
    "type": "reverseDirection",
    "usageType": "bombHolder",
    "isAvailable": true
  },
  {
    "id": "adjustGameDays",
    "name": "기간 조정",
    "description": "게임 기간을 1일 증가 또는 감소시킵니다",
    "price": 90,
    "type": "adjustGameDays",
    "usageType": "always",
    "isAvailable": true
  }
]
```

---

## 구현 시 수정 대상 파일 요약

| 파일 | 변경 내용 |
|------|----------|
| `functions/src/bomb/passBomb.ts` | 신규 — passBomb Callable Function |
| `functions/src/bomb/constants.ts` | 신규 — BOMB_DURATION_TABLE, getDurationForPlayerCount |
| `functions/src/index.ts` | passBomb export 추가 |
| `functions/src/bomb/bombExpireScheduler.ts` | penaltyMultiplier 반영 |
| `lib/data/models/group_model.dart` | passDirection 필드 추가 |
| `lib/data/models/bomb_model.dart` | penaltyMultiplier 필드 추가 |
| `lib/data/models/shop_item_model.dart` | ItemUsageType enum + usageType 필드 추가 |
| `lib/data/models/user_model.dart` | ownedItemIds → inventory (Map) 변경 |
| `lib/core/constants/app_constants.dart` | min/maxBombDurationSeconds, targetMinCycles 추가 |
| `lib/features/game/controllers/game_controller.dart` | passBomb()를 Callable Function 호출로 구현 |
| `lib/data/repositories/bomb_repository.dart` | passBomb() 메서드 제거 (Callable로 대체) |
