import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../firebase/firebase_providers.dart';
import '../models/shop_item_model.dart';

part 'shop_repository.g.dart';

@riverpod
ShopRepository shopRepository(Ref ref) {
  return ShopRepository(ref.watch(firestoreProvider));
}

class ShopRepository {
  ShopRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// 아이템 목록 조회
  Future<List<ShopItemModel>> fetchItems() async {
    final snap = await _firestore
        .collection(AppConstants.shopItemsCollection)
        .where('isAvailable', isEqualTo: true)
        .get();
    return snap.docs.map((d) => ShopItemModel.fromJson(d.data())).toList();
  }

  /// 아이템 목록 실시간 스트림
  Stream<List<ShopItemModel>> watchShopItems() {
    return _firestore
        .collection(AppConstants.shopItemsCollection)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ShopItemModel.fromJson(d.data())).toList());
  }

  /// 아이템 구매 (트랜잭션으로 재화 차감 + 소유 목록 추가)
  Future<void> purchaseItem({
    required String uid,
    required ShopItemModel item,
  }) async {
    final userRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid);

    await _firestore.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final currentCurrency = (userSnap.data()?['currency'] as int?) ?? 0;

      if (currentCurrency < item.price) {
        throw Exception('재화가 부족합니다.');
      }

      tx.update(userRef, {
        'currency': currentCurrency - item.price,
        'ownedItemIds': FieldValue.arrayUnion([item.id]),
      });
    });
  }
}
