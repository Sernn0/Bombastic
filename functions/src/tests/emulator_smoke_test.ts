import * as admin from 'firebase-admin';

// Initialize for emulator
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';
admin.initializeApp({ projectId: 'likelion-holycow' });

const db = admin.firestore();

async function testCheckIn() {
  console.log('Testing checkIn callable...');
  // Set up test user doc
  const uid = 'test-user-001';
  const groupId = 'test-group-001';
  await db.collection('users').doc(uid).set({
    lastCheckInDate: null,
    groupCurrencies: { [groupId]: 100 }
  });
  // Note: callable functions need Firebase Functions SDK to invoke directly.
  // This test verifies the Firestore state after manual invocation.
  console.log('Test user set up. Invoke checkIn callable manually with { groupId } to test.');
}

async function testCheckGameExpiry() {
  console.log('Testing checkGameExpiry logic...');
  const groupId = 'test-expired-group';
  const pastDate = new Date(Date.now() - 8 * 24 * 60 * 60 * 1000); // 8 days ago
  await db.collection('groups').doc(groupId).set({
    status: 'playing',
    gameExpiresAt: admin.firestore.Timestamp.fromDate(pastDate),
    memberUids: ['user1', 'user2'],
    penaltyCount: 2
  });
  console.log(`Created expired test group: ${groupId}`);
  console.log('Trigger checkGameExpiry function manually, then verify status == "finished" and results/summary exists.');
}

async function main() {
  await testCheckIn();
  await testCheckGameExpiry();
  console.log('Smoke test setup complete. Run emulator and invoke functions to verify.');
}

main().catch(console.error);
