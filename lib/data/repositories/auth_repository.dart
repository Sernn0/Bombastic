import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../firebase/firebase_providers.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
}

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  /// 익명 로그인
  Future<UserCredential> signInAnonymously() {
    return _auth.signInAnonymously();
  }

  /// 로그아웃
  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;
}
