import 'package:example/pages/loading_page.dart';
import 'package:example/pages/preferences_page.dart';
import 'package:example/services/auth_service.dart';
import 'package:flutter/foundation.dart';
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
      path: AppRoutes.preferences,
      builder: (ctx, route) => const PreferencesPage(),
    ),
    XRoute(
      title: 'dashboard',
      pageKey: const ValueKey('home-layout'),
      path: dashboard,
      builder: (ctx, route) => const HomeLayout(
        title: 'dashboard',
      ),
    ),
    XRoute(
      path: favorites,
      pageKey: const ValueKey('home-layout'),
      builder: (ctx, route) => const HomeLayout(
        title: 'favorites',
      ),
    ),
    XRoute(
      path: products,
      pageKey: const ValueKey('home-layout'),
      title: 'products',
      builder: (ctx, route) => const HomeLayout(
        title: 'products',
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
      // if (event is NavigationEnd) print(event);
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

class AuthResolver extends ValueNotifier with XResolver {
  AuthResolver() : super(AuthStatus.unknown) {
    AuthService.instance.authStatusStream.listen((authStatus) {
      value = authStatus;
    });
  }

  @override
  XResolverAction resolve(String target) {
    switch (value) {
      case AuthStatus.authenticated:
        if (target.startsWith(AppRoutes.signIn)) {
          return const Redirect(AppRoutes.home);
        } else {
          return const Next();
        }
      case AuthStatus.unautenticated:
        if (target.startsWith(AppRoutes.signIn)) {
          return const Next();
        } else {
          return const Redirect(AppRoutes.signIn);
        }
      case AuthStatus.unknown:
      default:
        return const Loading(
          LoadingPage(text: 'Guard: Checking Auth Status'),
        );
    }
  }
}
