import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

const db = admin.firestore();
const messaging = admin.messaging();

interface SendPushOptions {
  uid: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

/**
 * 특정 유저에게 FCM 푸시 알림 발송 (uid → FCM 토큰 조회 후 전송).
 */
async function sendPushToUser({ uid, title, body, data }: SendPushOptions): Promise<void> {
  const userSnap = await db.collection('users').doc(uid).get();
  const fcmToken = userSnap.data()?.fcmToken as string | undefined;

  if (!fcmToken) {
    functions.logger.warn(`FCM 토큰 없음: ${uid}`);
    return;
  }

  await messaging.send({
    token: fcmToken,
    notification: { title, body },
    data,
    android: {
      priority: 'high',
      notification: { channelId: 'bombastic_channel' },
    },
    apns: {
      payload: { aps: { sound: 'default', badge: 1 } },
    },
  });

  functions.logger.info(`푸시 발송 완료: ${uid} → "${title}"`);
}

/**
 * 폭탄을 받은 사람에게 알림 발송.
 * Firestore bomb 문서의 holderUid 변경 시 트리거.
 */
export const notifyBombReceived = functions.firestore
  .document('groups/{groupId}/bombs/{bombId}')
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.holderUid === after.holderUid) return; // 전달 없음

    const newHolder = after.holderUid as string;
    const expiresAt = (after.expiresAt as admin.firestore.Timestamp).toDate();
    const remainHours = Math.floor((expiresAt.getTime() - Date.now()) / 3600000);

    await sendPushToUser({
      uid: newHolder,
      title: '💣 폭탄을 받았습니다!',
      body: `${remainHours}시간 안에 다음 사람에게 전달하세요!`,
      data: { type: 'BOMB_RECEIVED' },
    });
  });

/**
 * 폭탄 만료 1시간 전 경고 알림 (스케줄러에서 호출).
 */
export const notifyBombWarning = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async () => {
    const now = Date.now();
    const warningThreshold = new Date(now + 60 * 60 * 1000); // 1시간 후

    const snapshot = await db
      .collectionGroup('bombs')
      .where('status', '==', 'active')
      .where('expiresAt', '<=', admin.firestore.Timestamp.fromDate(warningThreshold))
      .where('expiresAt', '>', admin.firestore.Timestamp.fromMillis(now))
      .get();

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const holderUid = data.holderUid as string;

      await sendPushToUser({
        uid: holderUid,
        title: '⚠️ 폭탄 만료 임박!',
        body: '1시간 안에 전달하지 않으면 폭발합니다!',
        data: { type: 'BOMB_WARNING' },
      });
    }
  });

/**
 * 폭탄 폭발 시 그룹 전원에게 알림 발송.
 */
export const notifyBombExploded = functions.firestore
  .document('groups/{groupId}/bombs/{bombId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status) return;
    if (after.status !== 'exploded') return;

    const { groupId } = context.params;
    const explodedUid = after.explodedUid as string;

    const groupSnap = await db.collection('groups').doc(groupId).get();
    const memberUids = (groupSnap.data()?.memberUids as string[]) ?? [];

    // 폭발 당한 사람 이름 조회
    const userSnap = await db.collection('users').doc(explodedUid).get();
    const displayName = (userSnap.data()?.displayName as string) ?? '누군가';

    await Promise.all(
      memberUids.map((uid) =>
        sendPushToUser({
          uid,
          title: '💥 폭탄이 폭발했습니다!',
          body: `${displayName}에게 폭탄이 폭발했습니다!`,
          data: { type: 'BOMB_EXPLODED', explodedUid },
        }),
      ),
    );
  });
