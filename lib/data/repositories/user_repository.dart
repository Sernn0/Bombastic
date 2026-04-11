// 변경 후 dart run build_runner build --delete-conflicting-outputs 실행 필요
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../firebase/firebase_providers.dart';
import '../models/user_model.dart';

part 'user_repository.g.dart';

@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepository(ref.watch(firestoreProvider));
}

class UserRepository {
  UserRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(AppConstants.usersCollection);

  /// 유저 문서 조회
  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromJson(doc.data()!);
  }

  /// 유저 문서 실시간 스트림
  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromJson(snap.data()!);
    });
  }

  /// 유저 문서 생성 또는 업데이트
  Future<void> setUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toJson(), SetOptions(merge: true));
  }

  /// 그룹 참여 시 groupIds에 추가 및 닉네임 저장
  Future<void> addGroupMembership({
    required String uid,
    required String groupId,
    required String nickname,
  }) async {
    try {
      await _users.doc(uid).update({
        'groupIds': FieldValue.arrayUnion([groupId]),
        'groupNicknames.$groupId': nickname,
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        final newUser = UserModel(
          uid: uid,
          displayName: 'User',
          groupIds: [groupId],
          groupNicknames: {groupId: nickname},
        );
        await _users.doc(uid).set(newUser.toJson(), SetOptions(merge: true));
      } else {
        rethrow;
      }
    }
  }

  /// 그룹별 닉네임 업데이트
  Future<void> updateGroupNickname({
    required String uid,
    required String groupId,
    required String nickname,
  }) async {
    try {
      await _users.doc(uid).update({
        'groupNicknames.$groupId': nickname,
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        final newUser = UserModel(
          uid: uid,
          displayName: 'User',
          groupIds: [groupId],
          groupNicknames: {groupId: nickname},
        );
        await _users.doc(uid).set(newUser.toJson(), SetOptions(merge: true));
      } else {
        rethrow;
      }
    }
  }

  /// 그룹 탈퇴 시 groupIds에서 제거 및 닉네임 삭제
  Future<void> removeGroupMembership({
    required String uid,
    required String groupId,
  }) async {
    try {
      await _users.doc(uid).update({
        'groupIds': FieldValue.arrayRemove([groupId]),
        'groupNicknames.$groupId': FieldValue.delete(),
      });
    } on FirebaseException catch (e) {
      if (e.code != 'not-found') {
        rethrow;
      }
    }
  }
}
