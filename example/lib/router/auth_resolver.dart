import 'package:example/pages/loading_page.dart';
import 'package:example/router/routes.dart';
import 'package:example/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class AuthResolver extends XResolver<AuthStatus> {
  AuthResolver() : super(initialState: AuthStatus.unknown) {
    AuthService.instance.authStatus$.listen((status) => state = status);
  }

  @override
  XResolverAction resolve(String target) {
    switch (state) {
      case AuthStatus.authenticated:
        if (target.startsWith(AppRoutes.signIn))
          return Redirect(AppRoutes.home);
        else
          return Next();
      case AuthStatus.unautenticated:
        if (target.startsWith(AppRoutes.signIn))
          return Next();
        else
          return Redirect(AppRoutes.signIn);
      case AuthStatus.unknown:
      default:
        return Loading(
          LoadingPage(text: 'Checking Auth Status'),
        );
    }
  }
}
