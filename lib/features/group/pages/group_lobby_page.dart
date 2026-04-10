import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../controllers/group_controller.dart';

class GroupLobbyPage extends ConsumerWidget {
  const GroupLobbyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(currentGroupProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('대기실')),
      body: groupAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (group) {
          if (group == null) {
            return const Center(child: Text('그룹을 찾을 수 없습니다.'));
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 참여코드 표시
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('참여 코드', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          group.joinCode,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: group.joinCode),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('코드 복사됨')),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('복사'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 멤버 목록
                Text(
                  '참여자 ${group.memberUids.length}/${group.maxMembers}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  group.maxMembers,
                  (i) => ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: i < group.memberUids.length
                        ? Text('플레이어 ${i + 1}')
                        : const Text('대기 중...', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const Spacer(),

                // 게임 시작 (방장만, 4명 모두 참여 시)
                if (group.memberUids.length == group.maxMembers)
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.game),
                    child: const Text('게임 시작!'),
                  )
                else
                  const Center(child: Text('다른 플레이어를 기다리는 중...')),
              ],
            ),
          );
        },
      ),
    );
  }
}
