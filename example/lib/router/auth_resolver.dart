import 'package:example/services/auth_service.dart';
import 'package:x_router/x_router.dart';

class AuthResolver extends XResolver<AuthStatus> {
  AuthResolver() : super(initialState: AuthStatus.unknown) {
    AuthService.instance.authStatus$.listen((status) => state = status);
  }

  @override
  Future<String> resolve(String target) async {
    switch (state) {
      case AuthStatus.authenticated:
        if (target.startsWith('/sign-in')) return '/';
        if (target.startsWith('/loading')) {
          return target.replaceFirst('/loading', '');
        }
        return target;
      case AuthStatus.unautenticated:
        return '/sign-in';
      case AuthStatus.unknown:
      default:
        if (target.startsWith('/loading')) return target;
        return '/loading$target';
    }
  }
}
