import 'dart:math';

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

  /// 랜덤박스 구매 — 재화 차감 후 가중치 기반으로 아이템 1개 지급, 획득 아이템 반환
  Future<ShopItemModel> purchaseRandomBox({required String uid}) async {
    final items = await fetchItems();
    final pool = items.where((i) => i.probability > 0).toList();
    if (pool.isEmpty) throw Exception('뽑기 가능한 아이템이 없습니다.');

    final userRef =
        _firestore.collection(AppConstants.usersCollection).doc(uid);

    late ShopItemModel obtained;

    await _firestore.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final currentCurrency = (userSnap.data()?['currency'] as int?) ?? 0;

      if (currentCurrency < CurrencyConstants.randomBoxPrice) {
        throw Exception('재화가 부족합니다.');
      }

      // 가중치 기반 랜덤 선택
      final totalWeight = pool.fold(0, (acc, i) => acc + i.probability);
      final roll = Random().nextInt(totalWeight);
      var cumulative = 0;
      obtained = pool.last;
      for (final item in pool) {
        cumulative += item.probability;
        if (roll < cumulative) {
          obtained = item;
          break;
        }
      }

      tx.update(userRef, {
        'currency': currentCurrency - CurrencyConstants.randomBoxPrice,
        'ownedItemIds': FieldValue.arrayUnion([obtained.id]),
      });
    });

    return obtained;
  }
}
