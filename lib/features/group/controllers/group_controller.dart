import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/group_model.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../data/repositories/user_repository.dart';

part 'group_controller.g.dart';

/// 특정 그룹 실시간 스트림
@riverpod
Stream<GroupModel?> watchGroup(Ref ref, String groupId) {
  if (groupId.isEmpty) return const Stream.empty();
  return ref.watch(groupRepositoryProvider).watchGroup(groupId);
}

@riverpod
class GroupController extends _$GroupController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// 새 그룹 생성 — 성공 시 groupId 반환
  /// 기본 닉네임은 빈 문자열(미설정). 생성 직후 nickname_input_page로
  /// 이동하여 방장이 직접 닉네임을 지정해야 한다.
  Future<String?> createGroup({
    required String name,
    required int maxMembers,
    String nickname = '',
  }) async {
    state = const AsyncLoading();
    final uid = ref.read(currentUidProvider);
    if (uid == null) {
      state = AsyncError('로그인이 필요합니다.', StackTrace.current);
      return null;
    }

    String? groupId;
    final result = await AsyncValue.guard(() async {
      // 클라이언트에서 코드 생성; 서버가 중복을 감지하면 새 코드로 1회 재시도
      GroupModel? group;
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          group = await ref.read(groupRepositoryProvider).createGroup(
                creatorUid: uid,
                joinCode: _generateJoinCode(),
                name: name,
                maxMembers: maxMembers,
                nickname: nickname,
              );
          break;
        } catch (e) {
          if (attempt == 0 && e.toString().contains('already-exists')) continue;
          rethrow;
        }
      }
      groupId = group!.id;
      await ref.read(userRepositoryProvider).addGroupMembership(
            uid: uid,
            groupId: group.id,
            nickname: nickname,
          );
    });

    state = result.when(
      data: (_) => const AsyncData(null),
      error: AsyncError.new,
      loading: AsyncLoading.new,
    );
    return state.hasError ? null : groupId;
  }

  /// 코드로 그룹 참여 — 성공 시 groupId 반환
  Future<String?> joinGroup(String joinCode) async {
    if (joinCode.length != AppConstants.joinCodeLength) {
      state = AsyncError('${AppConstants.joinCodeLength}자리 코드를 입력하세요.', StackTrace.current);
      return null;
    }

    state = const AsyncLoading();
    final uid = ref.read(currentUidProvider);
    if (uid == null) {
      state = AsyncError('로그인이 필요합니다.', StackTrace.current);
      return null;
    }

    final repo = ref.read(groupRepositoryProvider);
    String? groupId;
    final result = await AsyncValue.guard(() async {
      final group = await repo.findByJoinCode(joinCode);
      if (group == null) throw Exception('존재하지 않는 코드입니다.');
      if (group.memberUids.contains(uid)) {
        throw Exception('이미 참여한 그룹입니다.');
      }
      if (group.memberUids.length >= group.maxMembers) {
        throw Exception('그룹이 가득 찼습니다.');
      }
      await repo.joinGroup(groupId: group.id, uid: uid);
      // 닉네임을 명시적으로 빈 문자열로 초기화 — 이후 nickname_input_page에서
      // 사용자가 직접 설정해야 게임 시작이 활성화된다 (닉네임 미설정 감지용)
      await ref.read(userRepositoryProvider).addGroupMembership(
            uid: uid,
            groupId: group.id,
            nickname: '',
          );
      await repo.updateMemberNickname(
            groupId: group.id,
            uid: uid,
            nickname: '',
          );
      groupId = group.id;
    });

    state = result.when(
      data: (_) => const AsyncData(null),
      error: AsyncError.new,
      loading: AsyncLoading.new,
    );
    return state.hasError ? null : groupId;
  }

  /// 방장이 특정 멤버 강퇴
  Future<void> kickMember({
    required String groupId,
    required String kickedUid,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref
          .read(groupRepositoryProvider)
          .kickMember(groupId: groupId, kickedUid: kickedUid);
    });
    state = result.when(
      data: (_) => const AsyncData(null),
      error: AsyncError.new,
      loading: AsyncLoading.new,
    );
  }

  /// 그룹 나가기 — 마지막 멤버가 나가면 그룹 데이터 말소
  Future<void> leaveGroup({required String groupId}) async {
    state = const AsyncLoading();
    final uid = ref.read(currentUidProvider);
    if (uid == null) {
      state = AsyncError('로그인이 필요합니다.', StackTrace.current);
      return;
    }

    final result = await AsyncValue.guard(() async {
      await ref
          .read(groupRepositoryProvider)
          .leaveGroup(groupId: groupId, uid: uid);
      await ref
          .read(userRepositoryProvider)
          .removeGroupMembership(uid: uid, groupId: groupId);
    });

    state = result.when(
      data: (_) => const AsyncData(null),
      error: AsyncError.new,
      loading: AsyncLoading.new,
    );
  }

  String _generateJoinCode() {
    const uuid = Uuid();
    return uuid.v4().replaceAll('-', '').substring(0, AppConstants.joinCodeLength).toUpperCase();
  }
}
