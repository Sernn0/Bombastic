import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase/firebase_providers.dart';
import '../../../data/repositories/bomb_repository.dart';
import '../../../data/repositories/shop_repository.dart';

part 'admin_controller.g.dart';

@riverpod
class AdminController extends _$AdminController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> executeCommand({
    required String command,
    required String groupId,
  }) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) throw Exception('로그인이 필요합니다.');

    state = const AsyncLoading();
    final next = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      
      final parts = command.trim().split(' ');
      if (parts.isEmpty) throw Exception('명령어가 없습니다.');
      final cmd = parts[0].toLowerCase();
      
      switch (cmd) {
        case '/money':
          final amount = parts.length > 1 ? int.tryParse(parts[1]) ?? 10000 : 10000;
          final userRef = firestore.collection('users').doc(uid);
          await firestore.runTransaction((tx) async {
            final snap = await tx.get(userRef);
            final currencies = Map<String, dynamic>.from(
              snap.data()?['groupCurrencies'] as Map<String, dynamic>? ?? {},
            );
            final current = (currencies[groupId] as num?)?.toInt() ?? 0;
            tx.update(userRef, {'groupCurrencies.$groupId': current + amount});
          });
          break;
          
        case '/items':
          final items = await ref.read(shopRepositoryProvider).fetchItems();
          final ids = items.map((e) => e.id).toList();
          await firestore.collection('users').doc(uid).update({
            'groupOwnedItemIds.$groupId': FieldValue.arrayUnion(ids),
          });
          break;
          
        case '/explode':
          final bomb = await ref.read(bombRepositoryProvider).watchActiveBomb(groupId).first;
          if (bomb == null) throw Exception('진행 중인 게임(폭탄)이 없습니다.');
          if (bomb.holderUid != uid) throw Exception('나에게 폭탄이 있을 때만 즉시 터뜨릴 수 있습니다!');
          
          await firestore.collection('groups').doc(groupId).collection('bombs').doc(bomb.id).update({
            'expiresAt': Timestamp.now(), // 타이머 즉시 만료 (타이머 컨트롤러에서 처리됨)
          });
          break;
          
        case '/mission':
          // 당일 출석 체크인을 없애서, 미션을 다시 고침 (다시 보상 수급 가능)
          await firestore.collection('users').doc(uid).update({
            'lastCheckInDate': FieldValue.delete(),
          });
          break;
          
        case '/steal':
          final bomb2 = await ref.read(bombRepositoryProvider).watchActiveBomb(groupId).first;
          if (bomb2 == null) throw Exception('진행 중인 게임(폭탄)이 없습니다.');
          await firestore.collection('groups').doc(groupId).collection('bombs').doc(bomb2.id).update({
            'holderUid': uid,
            'receivedAt': Timestamp.now(),
            'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(seconds: 15))),
          });
          break;
          
        case '/endgame':
          await firestore.collection('groups').doc(groupId).update({
            'status': 'finished',
          });
          final bomb3 = await ref.read(bombRepositoryProvider).watchActiveBomb(groupId).first;
          if (bomb3 != null) {
            await firestore.collection('groups').doc(groupId).collection('bombs').doc(bomb3.id).update({
              'status': 'exploded',
            });
          }
          break;
          
        default:
          throw Exception('알 수 없는 명령어: $cmd');
      }
    });
    if (ref.mounted) state = next;
  }
}
