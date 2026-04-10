import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/repositories/mission_repository.dart';

part 'mission_controller.g.dart';

/// 미션 목록 (실시간)
@riverpod
Stream<List<MissionModel>> missions(Ref ref) {
  return ref.watch(missionRepositoryProvider).watchMissions();
}

@riverpod
class MissionController extends _$MissionController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> checkIn() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final rewarded =
          await ref.read(missionRepositoryProvider).checkIn(uid);
      if (!rewarded) throw Exception('오늘은 이미 출석했습니다.');
    });
  }
}
