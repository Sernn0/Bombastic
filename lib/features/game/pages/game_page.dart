import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/group_model.dart';
import '../../group/controllers/group_controller.dart';
import '../controllers/game_controller.dart';
import '../controllers/timer_controller.dart';

class GamePage extends ConsumerWidget {
  const GamePage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(watchGroupProvider(groupId));

    return groupAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('오류: $e')),
      ),
      data: (group) {
        if (group == null) {
          return const Scaffold(
            body: Center(child: Text('그룹을 찾을 수 없습니다.')),
          );
        }

        final isPlaying = group.status == GroupStatus.playing;

        return PopScope(
          canPop: !isPlaying,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && isPlaying) {
              _showExitBlockedDialog(context);
            }
          },
          child: switch (group.status) {
            GroupStatus.waiting => _WaitingView(group: group),
            GroupStatus.playing => _PlayingView(groupId: groupId),
            GroupStatus.finished => _FinishedView(group: group),
          },
        );
      },
    );
  }

  static void _showExitBlockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('나갈 수 없습니다'),
        content: const Text('게임 진행 중에는 나갈 수 없습니다.\n그룹은 계속 유지됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

// ── Waiting 상태 UI ──────────────────────────────────────────

class _WaitingView extends ConsumerWidget {
  const _WaitingView({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);
    final isHost = group.memberUids.isNotEmpty && group.memberUids[0] == uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 참여 코드 표시
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('참여 코드', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        group.joinCode,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 참여자 목록
              Text(
                '참여자 (${group.memberUids.length}/${group.maxMembers})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: group.memberUids.length,
                  itemBuilder: (_, i) {
                    final memberUid = group.memberUids[i];
                    final nickname =
                        group.memberNicknames[memberUid] ?? '알 수 없음';
                    final isSelf = memberUid == uid;
                    final isMemberHost = i == 0;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(nickname.isNotEmpty
                            ? nickname[0]
                            : '?'),
                      ),
                      title: Text(
                        '$nickname${isSelf ? ' (나)' : ''}',
                        style: TextStyle(
                          fontWeight:
                              isSelf ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isMemberHost
                          ? const Chip(label: Text('방장'))
                          : null,
                    );
                  },
                ),
              ),

              // 안내 문구
              if (!isHost)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    '방장이 게임을 시작하면 자동으로 시작됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),

              // 방장 게임 시작 버튼
              if (isHost)
                ElevatedButton(
                  onPressed: group.memberUids.length >= 2
                      ? () async {
                          try {
                            await ref
                                .read(functionsProvider)
                                .httpsCallable('startGame')
                                .call({'groupId': group.id});
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('게임 시작 실패: $e')),
                              );
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '게임 시작',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Playing 상태 UI (기존 게임 화면) ─────────────────────────────

class _PlayingView extends ConsumerWidget {
  const _PlayingView({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bombAsync = ref.watch(activeBombProvider(groupId));
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
          return _GameBody(
            groupId: groupId,
            bombId: bomb.id,
            holderUid: bomb.holderUid,
          );
        },
      ),
    );
  }
}

class _GameBody extends ConsumerWidget {
  const _GameBody({
    required this.groupId,
    required this.bombId,
    required this.holderUid,
  });

  final String groupId;
  final String bombId;
  final String holderUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(bombTimerProvider);
    final gameCtrl = ref.read(gameControllerProvider.notifier);
    final isMyTurn = ref.watch(isMyTurnProvider(groupId));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const Center(
            child: Text('💣', style: TextStyle(fontSize: 120)),
          ),
          const SizedBox(height: 32),
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
          ElevatedButton(
            onPressed: isMyTurn
                ? () async {
                    await gameCtrl.passBomb(
                      groupId: groupId,
                      bombId: bombId,
                    );
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

// ── Finished 상태 UI ─────────────────────────────────────────

class _FinishedView extends StatelessWidget {
  const _FinishedView({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              '게임이 종료되었습니다!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  context.push('${AppRoutes.result}/${group.id}'),
              child: const Text('결과 보기'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
