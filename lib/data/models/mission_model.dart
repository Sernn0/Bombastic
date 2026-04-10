import 'package:freezed_annotation/freezed_annotation.dart';

part 'mission_model.freezed.dart';
part 'mission_model.g.dart';

enum MissionType { daily, weekly }

@freezed
abstract class MissionModel with _$MissionModel {
  const factory MissionModel({
    required String id,
    required String title,
    required String description,
    required int reward,
    required MissionType type,
    @Default(false) bool isCompleted,
  }) = _MissionModel;

  factory MissionModel.fromJson(Map<String, dynamic> json) =>
      _$MissionModelFromJson(json);
}
