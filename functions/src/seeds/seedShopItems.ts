import * as admin from 'firebase-admin';

/**
 * Firestore shopItems 컬렉션 초기 데이터 시드 스크립트.
 *
 * 실행 방법:
 *   npx ts-node src/seeds/seedShopItems.ts
 *
 * 사전 조건:
 *   - GOOGLE_APPLICATION_CREDENTIALS 환경변수에 서비스 계정 키 경로 설정
 *     또는 Firebase 에뮬레이터 환경에서 실행
 */

admin.initializeApp();

const db = admin.firestore();

interface ShopItemSeed {
  id: string;
  name: string;
  description: string;
  price: number;
  type: string;
  usageType: string;
  isAvailable: boolean;
}

const shopItems: ShopItemSeed[] = [
  {
    id: 'swapOrder',
    name: '순서 섞기',
    description: '폭탄 전달 순서를 랜덤으로 섞습니다 (내 위치 유지)',
    price: 50,
    type: 'swapOrder',
    usageType: 'always',
    isAvailable: true,
  },
  {
    id: 'addBomb',
    name: '폭탄 추가',
    description: '새로운 폭탄을 게임에 추가합니다',
    price: 80,
    type: 'addBomb',
    usageType: 'always',
    isAvailable: true,
  },
  {
    id: 'enhancePenalty',
    name: '패널티 강화',
    description: '현재 들고 있는 폭탄의 패널티를 강화합니다',
    price: 100,
    type: 'enhancePenalty',
    usageType: 'bombHolder',
    isAvailable: true,
  },
  {
    id: 'shrinkDuration',
    name: '시간 단축',
    description: '모든 활성 폭탄의 남은 제한시간을 50% 단축합니다',
    price: 60,
    type: 'shrinkDuration',
    usageType: 'always',
    isAvailable: true,
  },
  {
    id: 'reverseDirection',
    name: '방향 반전',
    description: '폭탄 전달 방향을 반대로 바꿉니다',
    price: 70,
    type: 'reverseDirection',
    usageType: 'bombHolder',
    isAvailable: true,
  },
  {
    id: 'adjustGameDays',
    name: '기간 조정',
    description: '게임 기간을 1일 증가 또는 감소시킵니다',
    price: 90,
    type: 'adjustGameDays',
    usageType: 'always',
    isAvailable: true,
  },
];

async function seed(): Promise<void> {
  const batch = db.batch();

  for (const item of shopItems) {
    const ref = db.collection('shopItems').doc(item.id);
    batch.set(ref, item);
  }

  await batch.commit();
  console.log(`shopItems 시드 완료: ${shopItems.length}개 아이템 등록`);
}

seed()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('시드 실패:', err);
    process.exit(1);
  });
