import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/shop_item_model.dart';
import '../../../data/repositories/shop_repository.dart';

part 'shop_controller.g.dart';

/// 상점 아이템 목록
@riverpod
Future<List<ShopItemModel>> shopItems(Ref ref) {
  return ref.watch(shopRepositoryProvider).fetchItems();
}

@riverpod
class ShopController extends _$ShopController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> purchaseItem(ShopItemModel item) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(shopRepositoryProvider).purchaseItem(uid: uid, item: item),
    );
  }
}
