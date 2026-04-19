import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/audio_service.dart';
import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/group_model.dart';
import '../../../widgets/floating_bomb_background.dart';
import '../controllers/home_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // 메인 홈에 진입하면 메인 테마송 재생 및 다른 특수 사운드 중지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playBgm('GameMainThemeSong1.mp3');
      ref.read(audioServiceProvider).stopTicking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(myGroupsProvider);
    final uid = ref.watch(currentUidProvider) ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('💣 Bombastic'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
      ),
      body: FloatingBombBackground(
        child: Column(
          children: [
            Expanded(
              child: groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
              data: (groups) => groups.isEmpty
                  ? const _EmptyGroupView()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: groups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) =>
                          _GroupCard(group: groups[i], myUid: uid),
                    ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(audioServiceProvider).playSfx('ButtonClickSound1.mp3');
                        context.push(AppRoutes.groupJoin);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                      ),
                      icon: const Icon(Icons.login),
                      label: const Text('그룹 참여하기'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(audioServiceProvider).playSfx('ButtonClickSound1.mp3');
                        context.push(AppRoutes.groupCreate);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('그룹 만들기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

// ── 그룹 카드 ────────────────────────────────────────────────

class _GroupCard extends ConsumerWidget {
  const _GroupCard({required this.group, required this.myUid});

  final GroupModel group;
  final String myUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myNickname = group.memberNicknames[myUid] ?? '나';
    final isFull = group.memberUids.length >= group.maxMembers;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _StatusBadge(status: group.status),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('내 닉네임: $myNickname'),
            Text(
              '${group.memberUids.length}/${group.maxMembers}명'
              '${group.status == GroupStatus.waiting && !isFull ? ' · 대기 중' : ''}',
              style: TextStyle(
                color: isFull ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ref.read(audioServiceProvider).playSfx('ButtonClickSound1.mp3');
          context.push('${AppRoutes.game}/${group.id}');
        },
      ),
    );
  }
}

// ── 상태 배지 ─────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final GroupStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      GroupStatus.waiting => (Icons.hourglass_top, Colors.orange),
      GroupStatus.playing => (Icons.local_fire_department, Colors.red),
      GroupStatus.finished => (Icons.emoji_events, Colors.grey),
    };

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color),
    );
  }
}

// ── 빈 상태 ──────────────────────────────────────────────────

class _EmptyGroupView extends StatelessWidget {
  const _EmptyGroupView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('💣', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text(
            '참여 중인 그룹이 없어요.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '그룹을 만들거나 참여코드로 입장하세요.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
