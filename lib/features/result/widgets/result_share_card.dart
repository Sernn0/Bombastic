import 'package:flutter/material.dart';

import '../models/game_result_model.dart';

/// SNS 공유용 결과 카드 위젯 (screenshot 패키지로 캡처됨)
class ResultShareCard extends StatelessWidget {
  const ResultShareCard({super.key, required this.result});

  final GameResultModel result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '💣 Bombastic',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '게임 종료! ${result.endedAt.year}.${result.endedAt.month}.${result.endedAt.day}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ...result.rankList.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        e.key < 3
                            ? ['🥇', '🥈', '🥉'][e.key]
                            : '${e.key + 1}',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.value.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        '💥 ${e.value.explodeCount}회',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 16),
          const Text(
            '#Bombastic #봄바스틱 #폭탄돌리기',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
