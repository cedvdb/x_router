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

class RouteLocations {
  static const home = '/app';
  static const dashboard = '$home/dashboard';
  static const products = '$home/products';
  static const favorites = '$home/favorites';
  static const preferences = '$home/preferences';
  static const productDetail = '$home/products/:id';
  static const loading = '/loading';
  static const signIn = '/sign-in';
}

final _routes = [
  XRoute(
    path: RouteLocations.signIn,
    builder: (ctx, route) => SignInPage(),
    titleBuilder: (ctx, route) => 'sign in ! (Browser tab title)',
  ),
  XRoute(
    path: RouteLocations.preferences,
    builder: (ctx, route) => const PreferencesPage(),
    titleBuilder: (ctx, route) => translate(ctx, 'preferences'),
  ),
  XRoute(
    pageKey: const ValueKey('home-layout'),
    path: RouteLocations.dashboard,
    builder: (ctx, route) => const HomeLayout(text: 'dashboard'),
    titleBuilder: (_, __) => 'dashboard',
  ),
  XRoute(
    path: RouteLocations.favorites,
    pageKey: const ValueKey('home-layout'),
    builder: (ctx, route) => const HomeLayout(text: 'favorites'),
    titleBuilder: (_, __) => 'My favorites',
  ),
  XRoute(
    path: RouteLocations.products,
    pageKey: const ValueKey('home-layout'),
    titleBuilder: (_, __) => 'products',
    builder: (ctx, route) => const HomeLayout(text: 'products'),
  ),
  XRoute(
    path: RouteLocations.productDetail,
    builder: (ctx, route) => ProductDetailsPage(route.pathParams['id']!),
    childRouter: ProductDetailsPage.productRouter,
  ),
];

final router = XRouter(
  resolvers: [
    AuthResolver(),
    XRedirectResolver(
      from: RouteLocations.home,
      to: RouteLocations.dashboard,
      matchChildren: false,
    ),
    XRedirectResolver(
      from: RouteLocations.productDetail,
      to: '${RouteLocations.productDetail}/info',
      matchChildren: false,
    ),
    XNotFoundResolver(redirectTo: RouteLocations.home, routes: _routes),
  ],
  routes: _routes,
);

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
        if (target.startsWith(RouteLocations.signIn)) {
          return const Redirect(RouteLocations.home);
        } else {
          return const Next();
        }
      case AuthStatus.unautenticated:
        if (target.startsWith(RouteLocations.signIn)) {
          return const Next();
        } else {
          return const Redirect(RouteLocations.signIn);
        }
      case AuthStatus.unknown:
      default:
        return Loading(
          (_, __) => const LoadingPage(text: 'Guard: Checking Auth Status'),
        );
    }
  }
}

void main() async {
  router.eventStream.listen((event) => print(event));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: router.informationParser,
      routerDelegate: router.delegate,
      debugShowCheckedModeBanner: false,
      title: 'XRouter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

// fake translate
String translate(BuildContext ctx, String text) => text;
