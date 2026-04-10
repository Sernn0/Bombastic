import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bomb_pass/core/controllers/auth_controller.dart';
import 'package:bomb_pass/core/router/app_router.dart';
import 'package:bomb_pass/data/firebase/firebase_providers.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('오류: $e')),
      ),
      data: (user) {
        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.home);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const _SignInAttemptPage();
      },
    );
  }
}

class _SignInAttemptPage extends ConsumerStatefulWidget {
  const _SignInAttemptPage();

  @override
  ConsumerState<_SignInAttemptPage> createState() => _SignInAttemptPageState();
}

class _SignInAttemptPageState extends ConsumerState<_SignInAttemptPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).signIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('사용자 정보를 확인 중입니다...'),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
