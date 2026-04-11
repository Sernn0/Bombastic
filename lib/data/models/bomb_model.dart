import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bomb_model.freezed.dart';
part 'bomb_model.g.dart';

enum BombStatus { active, exploded, defused }

@freezed
abstract class BombModel with _$BombModel {
  const factory BombModel({
    required String id,
    required String groupId,
    required String holderUid,       // 현재 폭탄 보유자
    required DateTime receivedAt,    // 받은 시각
    required DateTime expiresAt,     // 만료 시각
    required BombStatus status,
    @Default(0) int round,           // 몇 번째 라운드
    String? explodedUid,             // 폭발 당한 사람
    @Default(false) bool hasPenalty, // 패널티 강화 여부
  }) = _BombModel;

  factory BombModel.fromJson(Map<String, dynamic> json) =>
      _$BombModelFromJson(_normalizeBombJson(json));
}

Map<String, dynamic> _normalizeBombJson(Map<String, dynamic> json) {
  final map = Map<String, dynamic>.from(json);
  map['receivedAt'] =
      _normalizeRequiredDateValue(map['receivedAt'], 'receivedAt');
  map['expiresAt'] = _normalizeRequiredDateValue(map['expiresAt'], 'expiresAt');
  return map;
}

Object _normalizeRequiredDateValue(Object? value, String field) {
  final normalized = _normalizeNullableDateValue(value);
  if (normalized == null) {
    throw FormatException('Missing required date field: $field');
  }
  return normalized;
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
