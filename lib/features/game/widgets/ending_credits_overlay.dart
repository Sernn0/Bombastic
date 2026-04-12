import 'package:flutter/material.dart';

import '../../../data/models/group_model.dart';

class EndingCreditsOverlay extends StatefulWidget {
  const EndingCreditsOverlay({
    super.key,
    required this.group,
    required this.onDismissed,
  });

  final GroupModel group;
  final VoidCallback onDismissed;

  @override
  State<EndingCreditsOverlay> createState() => _EndingCreditsOverlayState();
}

class _EndingCreditsOverlayState extends State<EndingCreditsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _contentKey = GlobalKey();
  double _contentHeight = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onDismissed();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _maybeStart() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() => _contentHeight = box.size.height);
      }
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    _maybeStart();

    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 스크롤 크레딧 영역
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final totalDistance = screenHeight + _contentHeight;
              final dy = screenHeight - _controller.value * totalDistance;
              return Transform.translate(
                offset: Offset(0, dy),
                child: child,
              );
            },
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _CreditsContent(
                  key: _contentKey,
                  group: widget.group,
                ),
              ),
            ),
          ),

          // X 버튼
          Positioned(
            top: topPadding + 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white54, size: 28),
              tooltip: '건너뛰기',
              onPressed: widget.onDismissed,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 크레딧 내용 ───────────────────────────────────────────────

class _CreditsContent extends StatelessWidget {
  const _CreditsContent({super.key, required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 64),
        _section(
          child: Column(
            children: [
              const Text(
                '💣',
                style: TextStyle(fontSize: 72, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bombastic',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                group.name,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
        _section(
          child: Column(
            children: [
              _header('명예의 전당 🏆'),
              const SizedBox(height: 24),
              ...group.memberUids.asMap().entries.map((e) {
                final uid = e.value;
                final nickname = group.memberNicknames[uid] ?? uid;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    nickname,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 80),
        _section(
          child: Column(
            children: [
              _header('함께해 주셔서'),
              const SizedBox(height: 16),
              _header('감사합니다 🎉'),
            ],
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _header(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _section({required Widget child}) {
    return Center(child: child);
  }
}
