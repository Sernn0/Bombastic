import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/group_model.dart';

part 'home_controller.g.dart';

/// 현재 유저가 참여 중인 그룹 목록 실시간 스트림
@riverpod
Stream<List<GroupModel>> myGroups(Ref ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();

  return ref
      .watch(firestoreProvider)
      .collection(AppConstants.groupsCollection)
      .where('memberUids', arrayContains: uid)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => GroupModel.fromJson(d.data()))
          .toList());
}
