import 'package:example/layout/home_layout.dart';
import 'package:example/pages/dashboard_page.dart';
import 'package:example/pages/favorites_page.dart';
import 'package:example/pages/loading_page.dart';
import 'package:example/pages/product_details_page.dart';
import 'package:example/pages/products_page.dart';
import 'package:example/pages/sign_in_page.dart';
import 'package:example/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

/// This example features a complex
/// app navigation system with child routing and reactive resolvers
///
/// The goal here is not to show the feature
/// not necessarily to have a simple getting started example.

/// all the locations in the app
class RouteLocations {
  // this is the main page which will show the navigation
  static const signIn = '/sign-in';
  // the other pages are displayed inside that page above the nav
  static const app = '/app';
  static const dashboard = '$app/dashboard';
  static const products = '$app/products';
  static const favorites = '$app/favorites';
  static const productDetail = '$app/products/:id';
}

/// the routes for each location
final _routes = [
  // Root router routes
  XRoute(
    path: RouteLocations.signIn,
    builder: (ctx, route) => const SignInPage(),
    titleBuilder: (ctx) => translate(ctx, 'sign in ! (Browser tab title)'),
  ),
  // this page contains a child router
  XRoute(
    path: RouteLocations.app,
    builder: (ctx, route) => const HomeLayout(),
    // those page will be placed inside the home layout page
    children: [
      XRoute(
        path: RouteLocations.dashboard,
        builder: (ctx, route) => const DashboardPage(),
        titleBuilder: (_) => 'dashboard',
      ),
      XRoute(
        path: RouteLocations.favorites,
        builder: (ctx, route) => const FavoritesPage(),
        titleBuilder: (_) => 'My favorites',
      ),
      XRoute(
        path: RouteLocations.products,
        builder: (ctx, route) {
          return const ProductsPage();
        },
        titleBuilder: (_) => 'products',
      ),
      XRoute(
        path: RouteLocations.productDetail,
        builder: (ctx, activatedRoute) =>
            ProductDetailsPage(activatedRoute.pathParams['id']!),
      ),
    ],
  ),
];

// the router instance used throughout the app
final router = XRouter(
  routes: _routes,
  resolvers: [
    // Auth reactive resolver, redirects when unauthenticated / authenticated
    AuthResolver(),
    // redirects app to dashboard
    XRedirectResolver(
      from: RouteLocations.app,
      to: RouteLocations.dashboard,
      matchChildren: false,
    ),
    XRedirectResolver(
      from: RouteLocations.productDetail,
      to: '${RouteLocations.productDetail}/info',
      matchChildren: false,
    ),
    // will redirect to app when a route is not found
    XNotFoundResolver(redirectTo: RouteLocations.app, routes: _routes),
  ],
);

void main() async {
  // router.eventStream.listen((event) => print(event));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: router.informationParser,
      routerDelegate: router.delegate,
      backButtonDispatcher: RootBackButtonDispatcher(),
      debugShowCheckedModeBanner: false,
      title: 'XRouter Demo',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
    );
  }
}

// fake translate
String translate(BuildContext ctx, String text) => text;

/// goes to login page if we are not signed in.
class AuthResolver extends ValueNotifier implements XResolver {
  AuthResolver() : super(AuthStatus.unknown) {
    AuthService.instance.authStatusStream
        .listen((authStatus) => value = authStatus);
  }

  @override
  XResolverAction resolve(String target) {
    final isSignIn =
        XRoutePattern(RouteLocations.signIn).match(target, matchChildren: true);
    switch (value) {
      case AuthStatus.authenticated:
        if (isSignIn) {
          return const Redirect(RouteLocations.app);
        } else {
          return const Next();
        }
      case AuthStatus.unautenticated:
        if (isSignIn) {
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
