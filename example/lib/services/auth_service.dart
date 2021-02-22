import 'package:rxdart/rxdart.dart';

enum AuthStatus { unknown, authenticated, unautenticated }

class AuthService {
  static BehaviorSubject<AuthStatus> _authStateSubj$ =
      BehaviorSubject<AuthStatus>.seeded(AuthStatus.unknown);
  static get authStatus$ => _authStateSubj$.stream;

  static signIn() {
    _authStateSubj$.add(AuthStatus.authenticated);
  }

  static signOut() {
    _authStateSubj$.add(AuthStatus.unautenticated);
  }
}
