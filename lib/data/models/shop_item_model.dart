import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_item_model.freezed.dart';
part 'shop_item_model.g.dart';

enum ItemType { swapOrder, addBomb, enhancePenalty }

@freezed
abstract class ShopItemModel with _$ShopItemModel {
  const factory ShopItemModel({
    required String id,
    required String name,
    required String description,
    required int price,
    required ItemType type,
    @Default(true) bool isAvailable,
  }) = _ShopItemModel;

  factory ShopItemModel.fromJson(Map<String, dynamic> json) =>
      _$ShopItemModelFromJson(json);
}
