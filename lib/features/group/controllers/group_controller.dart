import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/group_model.dart';
import '../../../data/repositories/group_repository.dart';

part 'group_controller.g.dart';

/// 현재 유저가 속한 그룹 실시간 스트림
@riverpod
Stream<GroupModel?> currentGroup(Ref ref) {
  // TODO: 현재 유저의 groupId를 UserModel에서 가져오도록 연결
  return const Stream.empty();
}

@riverpod
class GroupController extends _$GroupController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// 새 그룹 생성
  Future<bool> createGroup({
    required String name,
    required int maxMembers,
    String nickname = '익명',
  }) async {
    state = const AsyncLoading();
    final uid = ref.read(currentUidProvider);
    if (uid == null) {
      state = AsyncError('로그인이 필요합니다.', StackTrace.current);
      return false;
    }

    final joinCode = _generateJoinCode();
    final result = await AsyncValue.guard(
      () => ref.read(groupRepositoryProvider).createGroup(
            creatorUid: uid,
            joinCode: joinCode,
            name: name,
            maxMembers: maxMembers,
            nickname: nickname,
          ),
    );

    state = result.when(
      data: (_) => const AsyncData(null),
      error: AsyncError.new,
      loading: AsyncLoading.new,
    );
    return !state.hasError;
  }

  /// 코드로 그룹 참여
  Future<bool> joinGroup(String joinCode) async {
    if (joinCode.length != AppConstants.joinCodeLength) {
      state = AsyncError('${AppConstants.joinCodeLength}자리 코드를 입력하세요.', StackTrace.current);
      return false;
    }

    state = const AsyncLoading();
    final uid = ref.read(currentUidProvider);
    if (uid == null) {
      state = AsyncError('로그인이 필요합니다.', StackTrace.current);
      return false;
    }

    final repo = ref.read(groupRepositoryProvider);
    final result = await AsyncValue.guard(() async {
      final group = await repo.findByJoinCode(joinCode);
      if (group == null) throw Exception('존재하지 않는 코드입니다.');
      if (group.memberUids.length >= group.maxMembers) {
        throw Exception('그룹이 가득 찼습니다.');
      }
      await repo.joinGroup(groupId: group.id, uid: uid);
    });

    state = result.when(
      data: (_) => const AsyncData(null),
      error: AsyncError.new,
      loading: AsyncLoading.new,
    );
    return !state.hasError;
  }

  String _generateJoinCode() {
    const uuid = Uuid();
    return uuid.v4().replaceAll('-', '').substring(0, AppConstants.joinCodeLength).toUpperCase();
  }
}
