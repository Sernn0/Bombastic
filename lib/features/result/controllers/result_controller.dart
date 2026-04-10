import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';

import '../../../data/repositories/bomb_repository.dart';
import '../models/game_result_model.dart';

part 'result_controller.g.dart';

/// 게임 결과 계산 (폭발 기록 기반)
@riverpod
Future<GameResultModel> gameResult(Ref ref) async {
  // TODO: currentGroupId 실제 값으로 연결
  const groupId = '';
  final bombs = await ref.read(bombRepositoryProvider).fetchExplodedBombs(groupId);

  // uid별 폭발 횟수 집계
  final countMap = <String, int>{};
  for (final bomb in bombs) {
    if (bomb.explodedUid != null) {
      countMap[bomb.explodedUid!] = (countMap[bomb.explodedUid!] ?? 0) + 1;
    }
  }

  // 오름차순 정렬 (폭발 적을수록 상위)
  final rankList = countMap.entries
      .map(
        (e) => PlayerResultModel(
          uid: e.key,
          displayName: e.key, // TODO: UserModel에서 displayName 가져오기
          explodeCount: e.value,
          passCount: 0, // TODO: passCount 집계
        ),
      )
      .toList()
    ..sort((a, b) => a.explodeCount.compareTo(b.explodeCount));

  return GameResultModel(
    groupId: groupId,
    rankList: rankList,
    endedAt: DateTime.now(),
  );
}

@riverpod
class ResultController extends _$ResultController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// screenshot으로 카드 이미지 캡처 후 공유
  Future<void> shareResult(ScreenshotController screenshotCtrl) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final Uint8List? image = await screenshotCtrl.capture();
      if (image == null) throw Exception('이미지 캡처 실패');
      // TODO: share_plus 등으로 이미지 공유 구현
      // await Share.shareXFiles([XFile.fromData(image, mimeType: 'image/png')]);
    });
  }
}
