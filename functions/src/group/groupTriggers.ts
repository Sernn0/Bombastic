import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

import { bombDefaultDurationMs } from '../core/gameConfig';

const db = admin.firestore();

/**
 * 모든 멤버가 참여하고 모두가 닉네임을 설정하면 자동으로 게임을 시작.
 * 인원이 꽉 차는 이벤트뿐 아니라, 이후 각 멤버가 닉네임을 설정하는
 * 업데이트에서도 트리거되어 조건 충족 시점에 시작한다.
 */
const hasAllNicknames = (
  memberUids: string[],
  memberNicknames: Record<string, string> | undefined,
): boolean => {
  if (!memberNicknames) return false;
  return memberUids.every((uid) => {
    const nick = memberNicknames[uid];
    // 레거시 데이터 호환: '익명'은 닉네임 미설정으로 취급한다.
    return typeof nick === 'string' && nick.length > 0 && nick !== '익명';
  });
};

const isReadyToStart = (data: FirebaseFirestore.DocumentData): boolean => {
  const memberUids = (data.memberUids as string[]) ?? [];
  const memberNicknames =
    (data.memberNicknames as Record<string, string> | undefined) ?? {};
  const maxMembers = data.maxMembers as number;
  return (
    data.status === 'waiting' &&
    memberUids.length === maxMembers &&
    hasAllNicknames(memberUids, memberNicknames)
  );
};

export const onGroupMemberJoined = functions.firestore
  .document('groups/{groupId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // 이전에도 이미 ready였다면 중복 실행 방지 (멱등성)
    if (isReadyToStart(before)) return;
    if (!isReadyToStart(after)) return;

    const { groupId } = context.params;
    functions.logger.info(
      `그룹 ${groupId} 모든 조건 충족 (인원+닉네임) → 게임 시작`,
    );

    const now = admin.firestore.Timestamp.now();
    const expiresAt = new Date(now.toMillis() + bombDefaultDurationMs);
    const gameExpiresAt = new Date(now.toMillis() + 7 * 24 * 60 * 60 * 1000);

    // 첫 폭탄 생성 (첫 번째 멤버가 보유)
    const firstHolder = (after.memberUids as string[])[0];
    const bombRef = db.collection('groups').doc(groupId).collection('bombs').doc();

    const batch = db.batch();

    batch.set(bombRef, {
      id: bombRef.id,
      groupId,
      holderUid: firstHolder,
      receivedAt: now,
      expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
      status: 'active',
      round: 1,
      explodedUid: null,
    });

    batch.update(change.after.ref, {
      status: 'playing',
      gameStartedAt: now,
      gameExpiresAt: admin.firestore.Timestamp.fromDate(gameExpiresAt),
    });

    await batch.commit();
    functions.logger.info(`폭탄 생성 완료: ${bombRef.id}, 첫 보유자: ${firstHolder}`);
  });

/**
 * 방장이 게임을 시작하는 Callable Function.
 */
export const startGame = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
  }

  const { groupId } = data as { groupId: string };
  if (!groupId) {
    throw new functions.https.HttpsError('invalid-argument', 'groupId가 필요합니다.');
  }

  const groupRef = db.collection('groups').doc(groupId);
  const groupSnap = await groupRef.get();
  if (!groupSnap.exists) {
    throw new functions.https.HttpsError('not-found', '그룹을 찾을 수 없습니다.');
  }

  const group = groupSnap.data()!;

  if (group.memberUids[0] !== context.auth.uid) {
    throw new functions.https.HttpsError('permission-denied', '방장만 게임을 시작할 수 있습니다.');
  }

  if (group.status !== 'waiting') {
    throw new functions.https.HttpsError('failed-precondition', '이미 시작된 게임입니다.');
  }
  if (group.memberUids.length < 2) {
    throw new functions.https.HttpsError('failed-precondition', '최소 2명이 필요합니다.');
  }
  if (!hasAllNicknames(group.memberUids as string[], group.memberNicknames)) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      '모든 참여자가 닉네임을 설정해야 시작할 수 있습니다.',
    );
  }

  const now = admin.firestore.Timestamp.now();
  const expiresAt = new Date(now.toMillis() + bombDefaultDurationMs);
  const gameExpiresAt = new Date(now.toMillis() + 7 * 24 * 60 * 60 * 1000);
  const firstHolder = group.memberUids[0];
  const bombRef = db.collection('groups').doc(groupId).collection('bombs').doc();

  const batch = db.batch();
  batch.set(bombRef, {
    id: bombRef.id,
    groupId,
    holderUid: firstHolder,
    receivedAt: now,
    expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
    status: 'active',
    round: 1,
    explodedUid: null,
  });
  batch.update(groupRef, {
    status: 'playing',
    gameStartedAt: now,
    gameExpiresAt: admin.firestore.Timestamp.fromDate(gameExpiresAt),
  });

  await batch.commit();
  return { success: true, bombId: bombRef.id };
});
