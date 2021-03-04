import 'package:example/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:x_router/x_router.dart';

class AuthResolver extends ValueNotifier with XRouteResolver {
  AuthResolver() : super(AuthStatus.unknown) {
    AuthService.instance.authStatus$.listen((status) {
      value = status;
    });
  }

  @override
  String resolve(String target, List<XRoute> routes) {
    switch (value) {
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
        return '/loading$target';
    }
  }
}
