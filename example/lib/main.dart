import 'package:example/pages/dashboard_page.dart';
import 'package:example/pages/favorites_page.dart';
import 'package:example/pages/home_page.dart';
import 'package:example/pages/loading_page.dart';
import 'package:example/pages/preferences_page.dart';
import 'package:example/pages/products_page.dart';
import 'package:example/services/auth_service.dart';
import 'package:example/services/products_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

import 'pages/product_details_page.dart';
import 'pages/sign_in_page.dart';

import 'package:example/pages/product_details_page.dart';
import 'package:example/pages/sign_in_page.dart';
import 'package:flutter/cupertino.dart';

/// This is a complex app routing example

/// all the locations in the app
class RouteLocations {
  static const home = '/app';
  static const dashboard = '$home/dashboard';
  static const products = '$home/products';
  static const favorites = '$home/favorites';
  static const preferences = '$home/preferences';
  static const productDetail = '$home/products/:id';
  static const productInfo = '$productDetail/info';
  static const productComments = '$productDetail/comments';
  static const signIn = '/sign-in';
}

/// the routes for each location
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
    path: RouteLocations.home,
    builder: (ctx, route) => const HomePage(),
    childRouterConfig: XChildRouterConfig(
      routes: [
        XRoute(
          path: RouteLocations.dashboard,
          builder: (ctx, route) => const DashboardPage(),
          titleBuilder: (_, __) => 'dashboard',
        ),
        XRoute(
          path: RouteLocations.products,
          titleBuilder: (_, __) => 'products',
          builder: (ctx, route) => const ProductsPage(),
        ),
        XRoute(
          path: RouteLocations.favorites,
          builder: (ctx, route) => const FavoritesPage(),
          titleBuilder: (_, __) => 'My favorites',
        ),
      ],
    ),
  ),

  // Here this route has a child router
  XRoute(
    path: RouteLocations.productDetail,
    builder: (ctx, route) => ProductDetailsPage(route.pathParams['id']!),
    // here is a nested router
    childRouterConfig: XChildRouterConfig(
      resolvers: [
        XRedirectResolver(
          from: RouteLocations.productDetail,
          to: RouteLocations.productInfo,
        ),
      ],
      routes: [
        XRoute(
          path: RouteLocations.productInfo,
          builder: (_, __) =>
              const Center(child: Text('info (Displayed via nested router)')),
        ),
        XRoute(
          path: RouteLocations.productComments,
          builder: (_, __) => const Center(
              child: Text('comments (displayed via nested router)')),
        ),
      ],
    ),
  ),
];

// the router instance used throughout the app,
// It is up to you if you want to let it as a global variable, use injection,
// inherited widget to access it.. That's outside the scope.
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

/// goes to login page if we are not signed in.
class AuthResolver extends ValueNotifier implements XResolver {
  AuthResolver() : super(AuthStatus.unknown) {
    AuthService.instance.authStatusStream
        .listen((authStatus) => value = authStatus);
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

/// checks if the product exists, else redirect to product details page
class ProductFoundResolver implements XResolver {
  final _productDetailsPattern = XRoutePattern(RouteLocations.productDetail);
  @override
  XResolverAction resolve(String target) {
    final parsed = _productDetailsPattern.parse(target, matchChildren: true);
    final productId = parsed.pathParameters['id'];
    if (parsed.matches) {
      try {
        ProductsService.products
            .firstWhere((product) => product.id == productId);
      } catch (e) {
        return const Redirect(RouteLocations.productDetail);
      }
    }
    return const Next();
  }
}

void main() async {
  // router.eventStream.listen((event) => print(event));
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
