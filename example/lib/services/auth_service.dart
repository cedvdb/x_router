import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AuthStatus { unknown, authenticated, unautenticated }

class AuthService {
  final _authStateSubject =
      BehaviorSubject<AuthStatus>.seeded(AuthStatus.unknown);
  late final Stream<AuthStatus> authStatusStream = _authStateSubject.stream;

  signIn() async {
    _authStateSubject.add(AuthStatus.unknown);
    await Future.delayed(const Duration(seconds: 1));
    _authStateSubject.add(AuthStatus.authenticated);
  }

  signOut() {
    _authStateSubject.add(AuthStatus.unautenticated);
  }

  // singleton

  AuthService._() {
    init();
  }

  init() async {
    await Hive.initFlutter();

    final authBox = await Hive.openBox('authBox');
    // listen for auth changes and saves it in storage
    _authStateSubject.stream.listen((state) {
      if (state == AuthStatus.unknown) {
        return;
      }
      final isAuthenticated = state == AuthStatus.authenticated;
      authBox.put('authenticated', isAuthenticated);
    });

    // setting the status to what it was before after 1sec
    Future.delayed(const Duration(seconds: 2), () {
      final bool? wasAuthenticated = authBox.get('authenticated');
      if (wasAuthenticated == null) {
        _authStateSubject.add(AuthStatus.unautenticated);
      } else {
        _authStateSubject.add(
          wasAuthenticated
              ? AuthStatus.authenticated
              : AuthStatus.unautenticated,
        );
      }
    });
  }

  static final AuthService instance = AuthService._();
}
