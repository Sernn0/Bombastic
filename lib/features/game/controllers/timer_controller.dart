import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/bomb_model.dart';
import 'game_controller.dart';

part 'timer_controller.g.dart';

/// 내가 보유한 폭탄의 남은 시간을 HH:MM:SS 문자열로 제공.
/// 내 폭탄이 없으면 가장 만료가 임박한 활성 폭탄 기준.
@riverpod
String bombTimer(Ref ref, String groupId) {
  final uid = ref.watch(currentUidProvider);
  final bombs = ref.watch(activeBombsProvider(groupId)).asData?.value ?? [];

  if (bombs.isEmpty) return '00:00:00';

  // 내 폭탄 우선, 없으면 만료가 가장 임박한 폭탄
  final BombModel target = bombs.firstWhere(
    (b) => b.holderUid == uid,
    orElse: () => bombs.reduce(
      (a, b) => a.expiresAt.isBefore(b.expiresAt) ? a : b,
    ),
  );

  final remaining = target.expiresAt.difference(DateTime.now());
  if (remaining.isNegative) return '00:00:00';

  final timer = Timer.periodic(const Duration(seconds: 1), (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  return AppDateUtils.formatDuration(remaining);
}
