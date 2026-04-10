import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

enum GroupStatus { waiting, playing, finished }

@freezed
abstract class GroupModel with _$GroupModel {
  const factory GroupModel({
    required String id,
    required String name,
    required String joinCode,
    required String hostUid,
    required int maxMembers,                          // 방장이 설정한 인원 (2~10)
    required List<String> memberUids,                 // 고정 순서 (index = 전달 순서)
    required Map<String, String> memberNicknames,     // uid → 그룹 내 닉네임
    required GroupStatus status,
    required DateTime createdAt,
    DateTime? gameStartedAt,
    DateTime? gameEndedAt,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);
}
