import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';

import '../controllers/result_controller.dart';
import '../widgets/result_share_card.dart';

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(gameResultProvider(groupId));
    final screenshotCtrl = ScreenshotController();

    return Scaffold(
      appBar: AppBar(title: const Text('게임 결과')),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (result) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SNS 공유용 카드 (screenshot 범위)
              Screenshot(
                controller: screenshotCtrl,
                child: ResultShareCard(result: result),
              ),
              const SizedBox(height: 24),

              // 공유 버튼
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(resultControllerProvider.notifier)
                    .shareResult(screenshotCtrl),
                icon: const Icon(Icons.share),
                label: const Text('SNS 공유'),
              ),
              const SizedBox(height: 16),

              // 명예의 전당
              const Text(
                '명예의 전당 🏆',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...result.rankList.asMap().entries.map(
                    (e) => ListTile(
                      leading: Text(
                        e.key < 3
                            ? ['🥇', '🥈', '🥉'][e.key]
                            : '${e.key + 1}',
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(e.value.displayName),
                      trailing: Text('💥 ${e.value.explodeCount}회'),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
