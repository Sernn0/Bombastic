import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

import { bombDefaultDurationMs } from '../core/gameConfig';

const db = admin.firestore();

/**
 * 아이템 사용 Callable Function.
 * data: { groupId: string; itemId: string; days?: number }
 * 반환: { success: true; targetUid?: string } (addBomb의 경우 targetUid 포함)
 */
export const useItem = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
  }

  const { groupId, itemId, days } = data as {
    groupId: string;
    itemId: string;
    days?: number;
  };
  if (!groupId || !itemId) {
    throw new functions.https.HttpsError('invalid-argument', 'groupId와 itemId가 필요합니다.');
  }

  const uid = context.auth.uid;

  // ── 유저 소유 여부 확인 ──────────────────────────────────────
  const userRef = db.collection('users').doc(uid);
  const userSnap = await userRef.get();
  const ownedItems = (userSnap.data()?.ownedItemIds as string[]) ?? [];
  if (!ownedItems.includes(itemId)) {
    throw new functions.https.HttpsError('permission-denied', '해당 아이템을 보유하지 않았습니다.');
  }

  // ── 아이템 정보 조회 ─────────────────────────────────────────
  const itemSnap = await db.collection('shopItems').doc(itemId).get();
  if (!itemSnap.exists) {
    throw new functions.https.HttpsError('not-found', '아이템을 찾을 수 없습니다.');
  }
  const item = itemSnap.data()!;

  // ── 그룹/게임 상태 확인 ──────────────────────────────────────
  const groupRef = db.collection('groups').doc(groupId);
  const groupSnap = await groupRef.get();
  if (!groupSnap.exists) {
    throw new functions.https.HttpsError('not-found', '그룹을 찾을 수 없습니다.');
  }
  const group = groupSnap.data()!;
  if (group.status !== 'playing') {
    throw new functions.https.HttpsError('failed-precondition', '게임 진행 중이 아닙니다.');
  }

  // ── 현재 활성 폭탄 조회 (bombHolder 체크용, 내가 보유한 폭탄 기준) ──────
  const myBombSnap = await db
    .collection('groups')
    .doc(groupId)
    .collection('bombs')
    .where('status', '==', 'active')
    .where('holderUid', '==', uid)
    .limit(1)
    .get();
  const myBombDoc = myBombSnap.docs[0];

  // 첫 번째 활성 폭탄 (단순 참조용)
  const anyBombSnap = await db
    .collection('groups')
    .doc(groupId)
    .collection('bombs')
    .where('status', '==', 'active')
    .limit(1)
    .get();
  const anyBombDoc = anyBombSnap.docs[0];
  const anyBomb = anyBombDoc?.data();

  // bombHolder 전용 아이템: 내가 폭탄을 보유 중이어야 함
  if (item.usageType === 'bombHolder' && myBombDoc == null) {
    throw new functions.https.HttpsError(
      'permission-denied',
      '폭탄 보유자만 사용할 수 있는 아이템입니다.',
    );
  }

  const batch = db.batch();
  const members = group.memberUids as string[];
  const extraResult: Record<string, unknown> = {};

  // ── 아이템 효과 적용 ─────────────────────────────────────────
  switch (item.type as string) {
    case 'swapOrder': {
      // 내 위치 + 현재 폭탄 보유자 위치 유지, 나머지 순서 셔플
      const myIndex = members.indexOf(uid);
      const holderUid = anyBomb?.holderUid as string | undefined;
      const holderIndex = holderUid ? members.indexOf(holderUid) : -1;
      const pinnedIndices = new Set([myIndex, holderIndex].filter((i) => i >= 0));
      const mobileIndices = members
        .map((_, i) => i)
        .filter((i) => !pinnedIndices.has(i));
      // Fisher-Yates shuffle on mobile indices
      for (let i = mobileIndices.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [mobileIndices[i], mobileIndices[j]] = [mobileIndices[j], mobileIndices[i]];
      }
      const result = [...members];
      let mobilePtr = 0;
      for (let i = 0; i < result.length; i++) {
        if (!pinnedIndices.has(i)) {
          result[i] = members[mobileIndices[mobilePtr++]];
        }
      }
      batch.update(groupRef, { memberUids: result });
      break;
    }

    case 'reverseDirection': {
      // 전달 방향 반전 (배열 역순)
      batch.update(groupRef, { memberUids: [...members].reverse() });
      break;
    }

    case 'shrinkDuration': {
      // 모든 활성 폭탄 남은 시간 50% 단축
      const allBombsSnap = await db
        .collection('groups')
        .doc(groupId)
        .collection('bombs')
        .where('status', '==', 'active')
        .get();
      const now = new Date();
      const minExpiresMs = now.getTime() + 60 * 1000; // 최소 1분 보장
      for (const bombDoc of allBombsSnap.docs) {
        const expiresAt = (bombDoc.data().expiresAt as admin.firestore.Timestamp).toDate();
        const remaining = expiresAt.getTime() - now.getTime();
        const newMs = now.getTime() + Math.max(remaining * 0.5, 0);
        batch.update(bombDoc.ref, {
          expiresAt: admin.firestore.Timestamp.fromDate(
            new Date(Math.max(newMs, minExpiresMs)),
          ),
        });
      }
      break;
    }

    case 'enhancePenalty': {
      // 내가 보유한 폭탄에 패널티 강화 플래그 추가
      if (!myBombDoc) {
        throw new functions.https.HttpsError('not-found', '보유 중인 폭탄이 없습니다.');
      }
      batch.update(myBombDoc.ref, { hasPenalty: true });
      break;
    }

    case 'addBomb': {
      // 랜덤 멤버(사용자 본인 제외)에게 새 폭탄 추가
      const eligible = members.filter((m) => m !== uid);
      if (eligible.length === 0) {
        throw new functions.https.HttpsError('failed-precondition', '새 폭탄을 전달할 멤버가 없습니다.');
      }
      const target = eligible[Math.floor(Math.random() * eligible.length)];
      const now2 = admin.firestore.Timestamp.now();
      const newBombRef = db
        .collection('groups')
        .doc(groupId)
        .collection('bombs')
        .doc();
      batch.set(newBombRef, {
        id: newBombRef.id,
        groupId,
        holderUid: target,
        receivedAt: now2,
        expiresAt: admin.firestore.Timestamp.fromDate(
          new Date(now2.toMillis() + bombDefaultDurationMs),
        ),
        status: 'active',
        round: 1,
        explodedUid: null,
        hasPenalty: false,
      });
      extraResult.targetUid = target;
      break;
    }

    case 'adjustGameDays': {
      // 모든 활성 폭탄 만료 시간 ±N일 조정 (기본 +1, 최소 1분 보장)
      const adjustDays = typeof days === 'number' ? days : 1;
      const allBombsSnap2 = await db
        .collection('groups')
        .doc(groupId)
        .collection('bombs')
        .where('status', '==', 'active')
        .get();
      const minExpiresMs2 = Date.now() + 60 * 1000;
      for (const bombDoc of allBombsSnap2.docs) {
        const expiresAt2 = (bombDoc.data().expiresAt as admin.firestore.Timestamp).toDate();
        const newMs = expiresAt2.getTime() + adjustDays * 24 * 60 * 60 * 1000;
        batch.update(bombDoc.ref, {
          expiresAt: admin.firestore.Timestamp.fromDate(
            new Date(Math.max(newMs, minExpiresMs2)),
          ),
        });
      }
      break;
    }

    default:
      throw new functions.https.HttpsError('invalid-argument', `알 수 없는 아이템 타입: ${item.type}`);
  }

  // ── 인벤토리에서 아이템 제거 ─────────────────────────────────
  batch.update(userRef, {
    ownedItemIds: admin.firestore.FieldValue.arrayRemove(itemId),
  });

  await batch.commit();
  functions.logger.info(`아이템 사용 완료: uid=${uid}, item=${itemId}, group=${groupId}`);

  return { success: true, ...extraResult };
});
