// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  uid: json['uid'] as String,
  displayName: json['displayName'] as String,
  currency: (json['currency'] as num?)?.toInt() ?? 0,
  ownedItemIds:
      (json['ownedItemIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  groupIds:
      (json['groupIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  groupNicknames:
      (json['groupNicknames'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  currentGroupId: json['currentGroupId'] as String?,
  lastCheckInDate: json['lastCheckInDate'] == null
      ? null
      : DateTime.parse(json['lastCheckInDate'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'currency': instance.currency,
      'ownedItemIds': instance.ownedItemIds,
      'groupIds': instance.groupIds,
      'groupNicknames': instance.groupNicknames,
      'currentGroupId': instance.currentGroupId,
      'lastCheckInDate': instance.lastCheckInDate?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };
