// 변경 후 dart run build_runner build --delete-conflicting-outputs 실행 필요
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String displayName,
    @Default(0) int currency,
    @Default([]) List<String> ownedItemIds,
    @Default([]) List<String> groupIds,
    @Default({}) Map<String, String> groupNicknames,
    String? currentGroupId,
    DateTime? lastCheckInDate,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
