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
  }) = _BombModel;

  factory BombModel.fromJson(Map<String, dynamic> json) =>
      _$BombModelFromJson(json);
}
