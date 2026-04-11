import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/shop_item_model.dart';
import '../../../data/repositories/shop_repository.dart';

part 'shop_controller.g.dart';

/// 상점 아이템 목록 (실시간)
@riverpod
Stream<List<ShopItemModel>> shopItems(Ref ref) {
  return ref.watch(shopRepositoryProvider).watchShopItems();
}

@riverpod
class ShopController extends _$ShopController {
  @override
  AsyncValue<ShopItemModel?> build() => const AsyncData(null);

  /// 랜덤박스 구매 — 성공 시 state에 획득 아이템 저장
  Future<ShopItemModel?> purchaseRandomBox() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return null;

    state = const AsyncLoading();
    ShopItemModel? obtained;
    state = await AsyncValue.guard(() async {
      obtained =
          await ref.read(shopRepositoryProvider).purchaseRandomBox(uid: uid);
      return obtained;
    });
    return obtained;
  }
}
