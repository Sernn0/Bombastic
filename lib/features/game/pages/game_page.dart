import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/bomb_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/shop_item_model.dart';
import '../../group/controllers/group_controller.dart';
import '../../shop/controllers/shop_controller.dart';
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

        return switch (group.status) {
          GroupStatus.waiting => _WaitingView(group: group),
          GroupStatus.playing => _PlayingView(groupId: groupId),
          GroupStatus.finished => _FinishedView(group: group),
        };
      },
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
              Text(
                '참여자 (${group.memberUids.length}/${group.maxMembers})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: group.memberUids.length,
                  itemBuilder: (_, i) {
                    final memberUid = group.memberUids[i];
                    final nickname = group.memberNicknames[memberUid] ?? '알 수 없음';
                    final isSelf = memberUid == uid;
                    final isMemberHost = i == 0;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(nickname.isNotEmpty ? nickname[0] : '?'),
                      ),
                      title: Text(
                        '$nickname${isSelf ? ' (나)' : ''}',
                        style: TextStyle(
                          fontWeight: isSelf ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isMemberHost ? const Chip(label: Text('방장')) : null,
                    );
                  },
                ),
              ),
              if (!isHost)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    '방장이 게임을 시작하면 자동으로 시작됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              if (isHost)
                ElevatedButton(
                  onPressed: group.memberUids.length >= 2
                      ? () async {
                          try {
                            await ref
                                .read(gameControllerProvider.notifier)
                                .startGame(groupId: group.id);
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

// ── Playing 상태 UI ──────────────────────────────────────────

class _PlayingView extends ConsumerWidget {
  const _PlayingView({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bombsAsync = ref.watch(activeBombsProvider(groupId));
    final groupName =
        ref.watch(watchGroupProvider(groupId)).asData?.value?.name ?? 'Bombastic';

    return Scaffold(
      appBar: AppBar(
        title: Text('💣 $groupName'),
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
      body: bombsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (bombs) {
          if (bombs.isEmpty) {
            return const Center(child: Text('폭탄을 기다리는 중...'));
          }
          return _GameBody(groupId: groupId, bombs: bombs);
        },
      ),
    );
  }
}

class _GameBody extends ConsumerWidget {
  const _GameBody({required this.groupId, required this.bombs});

  final String groupId;
  final List<BombModel> bombs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMyTurn = ref.watch(isMyTurnProvider(groupId));
    final uid = ref.watch(currentUidProvider);
    final group = ref.watch(watchGroupProvider(groupId)).asData?.value;
    final ownedItemIds =
        ref.watch(currentUserProvider).asData?.value?.ownedItemIds ??
            const <String>[];
    final shopItems =
        ref.watch(shopItemsProvider).asData?.value ?? const <ShopItemModel>[];

    final memberUids = group?.memberUids ?? const <String>[];

    // 보유 아이템 중 사용 가능한 것 필터링
    final usableItems = shopItems
        .where((item) => ownedItemIds.contains(item.id))
        .where((item) => item.usageType == UsageType.always || isMyTurn)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 폭탄 카드들 (다중 폭탄 지원)
          ...bombs.map(
            (bomb) => _BombCard(
              bomb: bomb,
              groupId: groupId,
              group: group,
              uid: uid,
              memberUids: memberUids,
            ),
          ),

          // 아이템 인벤토리
          if (usableItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            Row(
              children: [
                const Text(
                  '🎒 사용 가능한 아이템',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${usableItems.length}개)',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: usableItems
                  .map((item) => _ItemChip(
                        item: item,
                        groupId: groupId,
                        group: group,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 폭탄 카드 (단일 폭탄 표시) ───────────────────────────────

class _BombCard extends ConsumerWidget {
  const _BombCard({
    required this.bomb,
    required this.groupId,
    required this.group,
    required this.uid,
    required this.memberUids,
  });

  final BombModel bomb;
  final String groupId;
  final GroupModel? group;
  final String? uid;
  final List<String> memberUids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMyBomb = bomb.holderUid == uid;
    final timer = ref.watch(bombTimerProvider(groupId));
    final holderNickname = group?.memberNicknames[bomb.holderUid] ?? bomb.holderUid;

    return Card(
      color: isMyBomb ? Colors.red.shade50 : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 보유자 + 패널티 배지
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: isMyBomb ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                  isMyBomb ? '내가 폭탄을 보유 중!' : '현재 보유: $holderNickname',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isMyBomb ? Colors.red : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (bomb.hasPenalty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '⚡ 패널티',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // 타이머
            Center(
              child: Text(
                timer,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: isMyBomb ? Colors.red : Colors.grey,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Center(
              child: Text(
                isMyBomb ? '⚠️ 빨리 전달하세요!' : '대기 중...',
                style: TextStyle(
                  fontSize: 14,
                  color: isMyBomb ? Colors.red : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(child: Text('💣', style: TextStyle(fontSize: 64))),
            const SizedBox(height: 8),

            // 전달 순서 (가로 스크롤)
            if (memberUids.length > 1) ...[
              const Text(
                '전달 순서',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: memberUids.length,
                  separatorBuilder: (_, __) => const Center(
                    child: Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                  ),
                  itemBuilder: (_, i) {
                    final mUid = memberUids[i];
                    final nick = group?.memberNicknames[mUid] ?? '?';
                    final isHolder = mUid == bomb.holderUid;
                    final isMe = mUid == uid;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isHolder ? Colors.red : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isHolder ? Colors.red : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        isMe ? '$nick(나)' : nick,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isHolder ? FontWeight.bold : FontWeight.normal,
                          color: isHolder ? Colors.white : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 전달 버튼 (내 폭탄만)
            if (isMyBomb)
              ElevatedButton(
                onPressed: () => ref
                    .read(gameControllerProvider.notifier)
                    .passBomb(groupId: groupId, bombId: bomb.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  '다음 사람에게 전달! 🔥',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── 아이템 칩 ───────────────────────────────────────────────

class _ItemChip extends ConsumerWidget {
  const _ItemChip({required this.item, required this.groupId, this.group});

  final ShopItemModel item;
  final String groupId;
  final GroupModel? group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(gameControllerProvider).isLoading;

    return OutlinedButton(
      onPressed: isLoading ? null : () => _onTap(context, ref),
      child: Text(item.name, style: const TextStyle(fontSize: 13)),
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    // adjustGameDays는 일수 선택 다이얼로그 먼저
    if (item.type == ItemType.adjustGameDays) {
      final days = await _showAdjustDaysDialog(context);
      if (days == null || !context.mounted) return;
      await _useItem(context, ref, days: days);
      return;
    }

    // 나머지는 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.name),
        content: Text(item.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('사용'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      await _useItem(context, ref);
    }
  }

  /// adjustGameDays 전용: +2/+1/-1/-2 선택 다이얼로그
  Future<int?> _showAdjustDaysDialog(BuildContext context) {
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기간 조정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.description,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Text('모든 활성 폭탄에 적용됩니다.'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _DayButton(days: -2, onTap: () => Navigator.pop(ctx, -2)),
                _DayButton(days: -1, onTap: () => Navigator.pop(ctx, -1)),
                _DayButton(days: 1, onTap: () => Navigator.pop(ctx, 1)),
                _DayButton(days: 2, onTap: () => Navigator.pop(ctx, 2)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  Future<void> _useItem(BuildContext context, WidgetRef ref, {int? days}) async {
    final targetUid = await ref
        .read(gameControllerProvider.notifier)
        .useItem(groupId: groupId, itemId: item.id, days: days);

    if (!context.mounted) return;

    final state = ref.read(gameControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용 실패: ${state.error}')),
      );
      return;
    }

    // addBomb: 누가 폭탄 받았는지 알려줌
    if (item.type == ItemType.addBomb && targetUid != null) {
      final targetNick = group?.memberNicknames[targetUid] ?? targetUid;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('💣 $targetNick에게 새 폭탄이 생성됐습니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} 사용 완료!')),
      );
    }
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({required this.days, required this.onTap});

  final int days;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPositive = days > 0;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: isPositive ? Colors.green.shade700 : Colors.red.shade700,
        side: BorderSide(
          color: isPositive ? Colors.green.shade300 : Colors.red.shade300,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        '${isPositive ? '+' : ''}$days일',
        style: const TextStyle(fontWeight: FontWeight.bold),
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
              onPressed: () => context.push('${AppRoutes.result}/${group.id}'),
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
