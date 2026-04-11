// 변경 후 dart run build_runner build --delete-conflicting-outputs 실행 필요
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String displayName,
    /// 그룹별 재화 잔액 (groupId → amount)
    @Default({}) Map<String, int> groupCurrencies,
    /// 그룹별 보유 아이템 (groupId → itemIds)
    @Default({}) Map<String, List<String>> groupOwnedItemIds,
    @Default([]) List<String> completedMissionIds,
    @Default([]) List<String> groupIds,
    @Default({}) Map<String, String> groupNicknames,
    String? currentGroupId,
    DateTime? lastCheckInDate,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(_normalizeUserJson(json));
}

Map<String, dynamic> _normalizeUserJson(Map<String, dynamic> json) {
  final map = Map<String, dynamic>.from(json);
  map['lastCheckInDate'] = _normalizeNullableDateValue(map['lastCheckInDate']);
  map['createdAt'] = _normalizeNullableDateValue(map['createdAt']);

  // groupCurrencies: Map<String, dynamic> → Map<String, int>
  if (map['groupCurrencies'] != null) {
    final raw = map['groupCurrencies'] as Map<String, dynamic>;
    map['groupCurrencies'] =
        raw.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  // groupOwnedItemIds: Map<String, List<dynamic>> → Map<String, List<String>>
  if (map['groupOwnedItemIds'] != null) {
    final raw = map['groupOwnedItemIds'] as Map<String, dynamic>;
    map['groupOwnedItemIds'] = raw.map(
      (k, v) => MapEntry(k, (v as List<dynamic>).cast<String>()),
    );
  }

  return map;
}

String? _normalizeNullableDateValue(Object? value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate().toIso8601String();
  if (value is DateTime) return value.toIso8601String();
  if (value is String) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value).toIso8601String();
  }
  throw FormatException('Unsupported date value: $value');
}
