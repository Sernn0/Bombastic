import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../controllers/game_controller.dart';
import '../controllers/timer_controller.dart';

class GamePage extends ConsumerWidget {
  const GamePage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bombAsync = ref.watch(activeBombProvider);
    final timer = ref.watch(bombTimerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('💣 Bombastic'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            onPressed: () => context.push(AppRoutes.shop),
          ),
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () => context.push(AppRoutes.mission),
          ),
        ],
      ),
      body: bombAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (bomb) {
          if (bomb == null) {
            return const Center(child: Text('폭탄을 기다리는 중...'));
          }
          return _GameBody(bombId: bomb.id, holderUid: bomb.holderUid);
        },
      ),
    );
  }
}

class _GameBody extends ConsumerWidget {
  const _GameBody({required this.bombId, required this.holderUid});

  final String bombId;
  final String holderUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(bombTimerProvider);
    final gameCtrl = ref.read(gameControllerProvider.notifier);
    final isMyTurn = ref.watch(isMyTurnProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 타이머 디스플레이
          Center(
            child: Text(
              timer,
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: isMyTurn ? Colors.red : Colors.grey,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 폭탄 아이콘
          const Center(
            child: Text('💣', style: TextStyle(fontSize: 120)),
          ),
          const SizedBox(height: 32),

          // 상태 메시지
          Center(
            child: Text(
              isMyTurn ? '내 차례! 빨리 전달하세요!' : '상대방 차례입니다...',
              style: TextStyle(
                fontSize: 20,
                color: isMyTurn ? Colors.red : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // 전달 버튼 (내 차례일 때만 활성화)
          ElevatedButton(
            onPressed: isMyTurn
                ? () async {
                    await gameCtrl.passBomb(bombId);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
            child: const Text(
              '다음 사람에게 전달! 🔥',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
