# 💣 Bombastic

<div align="center">

[![Landing Page](https://img.shields.io/badge/랜딩페이지-bombastic--web.vercel.app-FF3B30?style=for-the-badge&logo=vercel&logoColor=white)](https://bombastic-web.vercel.app/)
[![Android APK](https://img.shields.io/badge/Android-APK_다운로드-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://github.com/sernn0/bombastic/releases/latest)
[![iOS App Store](https://img.shields.io/badge/iOS-심사중-lightgrey?style=for-the-badge&logo=apple&logoColor=white)](#)
[![Notion](https://img.shields.io/badge/기획문서-Notion-000000?style=for-the-badge&logo=notion&logoColor=white)](https://holycow-likelion.notion.site/bombastic?source=copy_link)

> **2~10명이 함께 즐기는 실시간 장기전 소셜 게임**  
> 폭탄을 돌려라, 마지막에 들고 있는 사람이 진다.

</div>

---

## 목차

1. [게임 소개](#게임-소개)
2. [다운로드](#다운로드)
3. [핵심 규칙](#핵심-규칙)
4. [주요 기능](#주요-기능)
5. [화면 흐름](#화면-흐름)
6. [기술 스택](#기술-스택)
7. [아키텍처](#아키텍처)
8. [Firestore 데이터 모델](#firestore-데이터-모델)
9. [Cloud Functions](#cloud-functions)
10. [개발 환경 설정](#개발-환경-설정)
11. [팀](#팀)

---

## 게임 소개

**Bombastic(봄바스틱)**은 친구들과 며칠 동안 폭탄을 주고받으며 진행하는 실시간 소셜 게임입니다.

폭탄은 매 **24시간**마다 자동으로 터집니다. 터지는 순간 들고 있던 플레이어가 폭발 카운트를 받습니다.  
게임 기간(4~7일)이 끝났을 때 **폭발 횟수가 가장 많은 사람이 패배자**가 되어 내기를 이행해야 합니다.

단순히 빨리 넘기는 것만이 전략이 아닙니다. 아이템으로 전달 순서를 뒤바꾸거나 상대방의 타이머를 단축시키는 심리전이 펼쳐집니다.

---

## 다운로드

| 플랫폼 | 상태 | 링크 |
|--------|------|------|
| 🤖 Android | ✅ APK 배포 중 | [최신 릴리스](https://github.com/sernn0/bombastic/releases/latest) |
| 🍎 iOS | ⏳ App Store 심사 중 | 출시 예정 |

> Android APK 설치 시 기기 설정에서 **"알 수 없는 앱 설치"** 를 허용해야 합니다.

---

## 핵심 규칙

| 항목 | 내용 |
|------|------|
| 인원 | 2 ~ 10명 |
| 게임 기간 | 최대 7일 (폭발 시 자동 종료) |
| 폭탄 타이머 | 24시간마다 자동 폭발 |
| 전달 순서 | 참여 순서 고정 (아이템으로 변경 가능) |
| 패배 조건 | 게임 종료 시 폭발 횟수 최다인 사람 |

---

## 주요 기능

### 🏠 그룹 관리
- **그룹 생성** — 그룹 이름·최대 인원 설정, 6자리 참여코드 자동 발급
- **초대 링크** — `bombastic://join?code=XXXXXX` 딥링크 및 카카오 공유로 원터치 참여
- **그룹별 닉네임** — 그룹마다 다른 닉네임 사용 가능
- **나가기** — 게임 시작 전까지 자유롭게 탈퇴 가능

### 💣 게임 진행
- **실시간 폭탄 현황** — 현재 보유자와 남은 시간을 실시간으로 확인
- **서버 기반 타이머** — 클라이언트 시간 조작 방지: 서버의 `expiresAt` 기준으로 카운트다운
- **폭탄 전달** — 버튼 한 번으로 다음 사람에게 즉시 패스
- **전달 방향 표시** — 현재 정방향/역방향 시각적으로 표시
- **폭발 애니메이션** — 폭발 시 2.2초 전체 화면 연출

### 🎁 아이템 시스템

랜덤박스(💰 100)를 열어 아이템을 획득하고 전략적으로 사용하세요.

| 아이템 | 효과 | 사용 조건 |
|--------|------|-----------|
| 🔀 순서 뒤섞기 | 나를 제외한 멤버의 전달 순서를 무작위로 재배치 | 상시 |
| ↩️ 방향 반전 | 폭탄 전달 방향을 반대로 뒤집기 | 상시 |
| ⏱️ 타이머 단축 | 현재 폭탄의 남은 시간을 절반으로 단축 | 폭탄 보유 중 |
| 😇 수호천사 | 폭발 시 자동으로 1회 막아줌 | 자동 발동 (패시브) |

### 💰 재화 & 상점
- **출석 체크** — 매일 그룹 내 출석하면 +💰 50 (그룹별 독립 적립, 한국 시간 기준)
- **미션 완료** — 각종 미션 달성 시 +💰 30
- **랜덤박스** — 💰 100으로 아이템 1개 획득 (확률형, 서버에서 처리)

### 📋 미션
| 미션 | 조건 |
|------|------|
| 첫 번째 패스 | 폭탄을 1번 넘기기 |
| 아이템 수집가 | 랜덤박스 첫 구매 |
| 패서 | 폭탄 5회 넘기기 |
| 베테랑 패서 | 폭탄 10회 넘기기 |
| 아이템 헌터 | 랜덤박스 3개 구매 |
| 번개 패서 | 받은 지 10분 안에 패스 |

### 📊 결과 & 어워드

게임 종료 후 **엔딩 크레딧**이 재생되며 5개 부문 어워드가 수여됩니다.

| 어워드 | 설명 |
|--------|------|
| 💥 패배자 | 폭발 횟수 최다 — 내기를 꼭 이행하세요 😈 |
| 🔥 폭탄 러버 | 폭탄을 가장 오래 들고 있던 사람 |
| 🛡️ 안전제일 | 폭탄을 가장 짧게 들고 있던 사람 |
| 🎯 다재다능 | 아이템을 가장 많이 사용한 사람 |
| 🚀 폭탄 배송 | 폭탄을 가장 많이 넘긴 사람 |

결과 화면에서 **SNS 공유 카드**를 생성해 패배자를 온 세상에 알릴 수 있습니다.

### 🔔 알림
- FCM 푸시 알림으로 폭탄 전달·폭발 이벤트를 실시간 수신

---

## 화면 흐름

```
로그인 (익명 인증, 계정 불필요)
  └─ 홈 (내 그룹 목록)
       ├─ 그룹 만들기
       └─ 그룹 참여 (코드 입력 / 딥링크 / 카카오 공유)
            └─ 닉네임 설정
                 └─ 대기실 (초대 링크 공유, 방장: 게임 시작)
                      └─ 게임 중
                           ├─ 홈 탭   — 폭탄 현황, 전달 버튼, 카운트다운
                           ├─ 상점 탭 — 랜덤박스 구매, 인벤토리, 아이템 사용
                           ├─ 미션 탭 — 출석 체크, 미션 목록 및 달성 현황
                           ├─ 로그 탭 — 전체 패스 기록 타임라인
                           └─ 설정 탭 — 테마 전환, 그룹 나가기
                                └─ 게임 종료
                                     ├─ 엔딩 크레딧 (어워드 발표)
                                     └─ 결과 페이지 (순위·통계, SNS 공유)
```

---

## 기술 스택

| 구분 | 기술 | 버전 |
|------|------|------|
| 클라이언트 | Flutter (Dart) | SDK ≥ 3.8.0 |
| 상태관리 | Riverpod | v3 |
| 라우팅 | GoRouter | 14.2.7 |
| 데이터 모델 | freezed + json_serializable | 3.0.0 / 6.8.0 |
| 인증 | Firebase Auth (익명) | 5.7.0 |
| DB | Cloud Firestore | 5.6.12 |
| 서버 로직 | Cloud Functions (TypeScript) | Node 20 |
| 푸시 알림 | Firebase Cloud Messaging | 15.0.4 |
| 딥링크 | app_links + Kakao SDK | — |
| 공유 | share_plus + kakao_flutter_sdk_share | — |
| 오디오 | audioplayers | 6.0.0 |

---

## 아키텍처

### 데이터 흐름

```
Firestore onSnapshot
  → Repository (Stream)
    → Riverpod Provider
      → UI (ConsumerWidget)
```

- **무결성 보장** — 폭탄 생성·폭발 등 게임 핵심 로직은 **Cloud Functions(Callable / Firestore Trigger)** 에서만 처리. 클라이언트가 직접 쓰지 않음
- **타이머 위변조 방지** — 모든 타이머는 서버 측 `expiresAt` 타임스탬프 기준으로 산출
- **원자적 트랜잭션** — 패스 로그 + 폭탄 업데이트는 Firestore Transaction으로 일관성 보장

### 디렉터리 구조 (`lib/`)

```
lib/
  main.dart                        # Firebase 초기화, ProviderScope, MaterialApp.router
  core/
    router/app_router.dart         # GoRouter (AppRoutes 명명 라우트)
    theme/app_theme.dart           # Material 3, Jua / IBM Plex Sans KR 폰트
    constants/app_constants.dart
  data/
    firebase/firebase_providers.dart   # FirebaseAuth, Firestore Riverpod 프로바이더
    models/                            # freezed 모델: Group, Bomb, Mission, ShopItem, User
    repositories/                      # Firestore 스트림/퓨처 래퍼
  features/
    auth/      — 익명 로그인 게이트
    home/      — 그룹 목록 홈
    group/     — 생성·참여·닉네임·대기실
    game/      — 게임 화면, GameController, TimerController
    mission/   — 미션 목록
    shop/      — 랜덤박스·인벤토리
    result/    — 결과 페이지, 공유 카드
  widgets/     — 공통 위젯 (TopToast, LoadingOverlay, FloatingBombBackground 등)
```

### Cloud Functions (`functions/src/`)

```
bomb/
  bombCallable.ts        — passBomb, explodeBomb (Callable)
  bombExpireScheduler.ts — 1분 주기 폭발 감지 스케줄러
  bombTriggers.ts        — onBombExploded 트리거 → 게임 종료 처리

group/
  groupCallable.ts       — startGame (Callable)
  groupTriggers.ts       — onGroupMemberJoined → 첫 폭탄 생성

shop/
  shopCallable.ts        — openLootBox (Callable, 서버 가중 랜덤)

mission/
  missionTriggers.ts     — onPassCreated, onUserUpdated → 미션 자동 평가

checkin/
  checkinCallable.ts     — checkIn, getTodayKey (한국 시간 기준)

item/
  itemCallable.ts        — useItem (효과 적용·트랜잭션 처리)

notification/
  fcmSender.ts           — FCM 푸시 알림 발송
```

---

## Firestore 데이터 모델

```
users/{uid}
  ├─ uid, displayName, fcmToken
  ├─ groupIds: string[]
  ├─ groupCurrencies: {groupId → balance}
  ├─ groupOwnedItemIds: {groupId → itemId[]}
  ├─ groupLootBoxCount: {groupId → count}
  ├─ groupCompletedMissionIds: {groupId → missionId[]}
  └─ groupLastCheckInDate: {groupId → 'YYYY-MM-DD'}

groups/{groupId}
  ├─ id, name, joinCode, hostUid, maxMembers
  ├─ memberUids: string[]           # 전달 순서 (인덱스 순)
  ├─ memberNicknames: {uid → nick}
  ├─ status: 'waiting'|'playing'|'finished'
  ├─ penaltyCount: {uid → count}
  ├─ createdAt, gameStartedAt, gameEndedAt, gameExpiresAt
  │
  ├─ bombs/{bombId}
  │    ├─ holderUid, receivedAt, expiresAt
  │    ├─ status: 'active'|'exploded'
  │    └─ round, explodedUid, hasPenalty
  │
  ├─ passes/{passId}               # 패스 감사 로그
  ├─ itemUsages/{usageId}          # 아이템 사용 감사 로그
  └─ results/summary               # 최종 결과 요약

shopItems/{itemId}
  ├─ name, description, type
  ├─ usageType: 'always'|'bombHolder'|'passive'
  ├─ probability (가중치)
  └─ isAvailable
```

---

## 개발 환경 설정

> 배포된 앱을 사용하려면 이 섹션은 필요 없습니다. 소스 빌드가 필요한 개발자용 안내입니다.

### 사전 요구사항
- Flutter SDK ≥ 3.8.0
- Node.js 20 (Cloud Functions)
- Firebase CLI

### 설치 및 실행

```bash
# 의존성 설치 + 코드 생성
bash setup.sh

# 앱 실행
flutter run

# 코드 생성 (모델·프로바이더 변경 시)
dart run build_runner build --delete-conflicting-outputs
```

### Firebase 설정

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=likelion-holycow
```

- `lib/firebase_options.dart` — gitignore 처리됨, 로컬에서 생성 필요
- `android/app/google-services.json` — Firebase 콘솔에서 다운로드
- `ios/Runner/GoogleService-Info.plist` — Firebase 콘솔에서 다운로드

### Cloud Functions 배포

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

---

## 팀

**멋쟁이사자처럼 HolyCow 팀** — Bombastic 프로젝트

| 역할 | 이름 |
|------|------|
| 기획 / 개발 | [GitHub](https://github.com/sernn0) |

---

## 관련 링크

- **공식 랜딩 페이지**: [bombastic-web.vercel.app](https://bombastic-web.vercel.app/)
- **기획 문서 (Notion)**: [노션 바로가기](https://holycow-likelion.notion.site/bombastic?source=copy_link)
- **Android APK**: [최신 릴리스](https://github.com/sernn0/bombastic/releases/latest)
