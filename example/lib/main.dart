import 'package:example/pages/loading_page.dart';
import 'package:example/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

import 'pages/home_layout.dart';
import 'pages/product_details_page.dart';
import 'pages/sign_in_page.dart';

import 'package:example/pages/home_layout.dart';
import 'package:example/pages/product_details_page.dart';
import 'package:example/pages/sign_in_page.dart';
import 'package:flutter/cupertino.dart';

class AppRoutes {
  static const home = '/app';
  static const dashboard = '$home/dashboard';
  static const products = '$home/products';
  static const favorites = '$home/favorites';
  static const preferences = '$home/preferences';
  static const productDetail = '$home/products/:id';
  static const loading = '/loading';
  static const signIn = '/sign-in';

  static final routes = [
    XRoute(
      title: 'sign in !',
      path: signIn,
      builder: (ctx, route) => SignInPage(),
    ),
    XRoute(
      title: 'dashboard',
      path: dashboard,
      builder: (ctx, route) => HomeLayout(
        index: 0,
        title: 'dashboard',
      ),
    ),
    XRoute(
      path: products,
      title: 'products',
      builder: (ctx, route) => HomeLayout(
        index: 1,
        title: 'products',
      ),
    ),
    XRoute(
      path: favorites,
      builder: (ctx, route) => HomeLayout(
        index: 2,
        title: 'favorites',
      ),
    ),
    XRoute(
      path: productDetail,
      builder: (ctx, route) => ProductDetailsPage(route.pathParams['id']!),
    ),
  ];
}

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final _router = XRouter(
    resolvers: [
      AuthResolver(),
      XRedirectResolver(from: AppRoutes.home, to: AppRoutes.dashboard),
      XNotFoundResolver(redirectTo: AppRoutes.home, routes: AppRoutes.routes),
    ],
    routes: AppRoutes.routes,
    onEvent: (event) {
      if (event is NavigationEnd) print(event);
    },
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _router.informationParser,
      routerDelegate: _router.delegate,
      debugShowCheckedModeBanner: false,
      title: 'XRouter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

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
