import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AuthStatus { unknown, authenticated, unautenticated }

class AuthService {
  BehaviorSubject<AuthStatus> _authStateSubj$ =
      BehaviorSubject<AuthStatus>.seeded(AuthStatus.unknown);
  late final Stream<AuthStatus> authStatus$ = _authStateSubj$.stream;

  signIn() {
    _authStateSubj$.add(AuthStatus.authenticated);
  }

  signOut() {
    _authStateSubj$.add(AuthStatus.unautenticated);
  }

  // singleton

  AuthService._() {
    init();
  }

  init() async {
    await Hive.initFlutter();

    final authBox = await Hive.openBox('authBox');
    // listen for auth changes and saves it in storage
    _authStateSubj$.stream.listen((state) {
      if (state == AuthStatus.unknown) {
        return;
      }
      final isAuthenticated = state == AuthStatus.authenticated;
      authBox.put('authenticated', isAuthenticated);
    });

    // setting the status to what it was before after 1sec
    Future.delayed(Duration(seconds: 1), () {
      final bool? wasAuthenticated = authBox.get('authenticated');
      if (wasAuthenticated == null) {
        _authStateSubj$.add(AuthStatus.unautenticated);
      } else {
        _authStateSubj$.add(
          wasAuthenticated
              ? AuthStatus.authenticated
              : AuthStatus.unautenticated,
        );
      }
    });
  }

  static final AuthService instance = AuthService._();
}
