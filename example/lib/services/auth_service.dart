import 'package:rxdart/rxdart.dart';

enum AuthStatus { unknown, authenticated, unautenticated }

class AuthService {
  BehaviorSubject<AuthStatus> _authStateSubj$ =
      BehaviorSubject<AuthStatus>.seeded(AuthStatus.unknown);
  get authStatus$ => _authStateSubj$.stream;

  signIn() {
    _authStateSubj$.add(AuthStatus.authenticated);
  }

  signOut() {
    _authStateSubj$.add(AuthStatus.unautenticated);
  }

  // singleton

  AuthService._() {
    // setting the status to unauthenticated after 1sec
    Future.delayed(Duration(seconds: 1),
        () => _authStateSubj$.add(AuthStatus.unautenticated));
  }

  static final AuthService instance = AuthService._();
}
