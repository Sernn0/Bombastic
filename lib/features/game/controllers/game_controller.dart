import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/bomb_model.dart';
import '../../../data/repositories/bomb_repository.dart';

part 'game_controller.g.dart';

/// 현재 활성 폭탄 실시간 스트림
@riverpod
Stream<BombModel?> activeBomb(Ref ref) {
  // TODO: currentGroupId를 실제 값으로 연결
  const groupId = ''; // ref.watch(currentGroupIdProvider)
  if (groupId.isEmpty) return const Stream.empty();
  return ref.watch(bombRepositoryProvider).watchActiveBomb(groupId);
}

/// 내 차례인지 여부
@riverpod
bool isMyTurn(Ref ref) {
  final bomb = ref.watch(activeBombProvider).asData?.value;
  final uid = ref.watch(currentUidProvider);
  return bomb?.holderUid == uid;
}

@riverpod
class GameController extends _$GameController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// 폭탄을 다음 사람에게 전달
  Future<void> passBomb(String bombId) async {
    state = const AsyncLoading();

    // TODO: 실제 그룹 멤버 순서 기반으로 nextHolderUid 계산
    // final group = ref.read(currentGroupProvider).valueOrNull;
    // final nextUid = _getNextHolder(group, ref.read(currentUidProvider));

    state = await AsyncValue.guard(() async {
      // await ref.read(bombRepositoryProvider).passBomb(
      //   groupId: groupId,
      //   bombId: bombId,
      //   nextHolderUid: nextUid,
      //   expiresAt: DateTime.now().add(
      //     const Duration(seconds: AppConstants.defaultBombDurationSeconds),
      //   ),
      // );
      throw UnimplementedError('passBomb: groupId 및 nextHolder 연결 필요');
    });
  }
}
