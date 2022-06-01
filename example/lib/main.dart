import 'package:example/layout/home_layout.dart';
import 'package:example/pages/dashboard_page.dart';
import 'package:example/pages/favorites_page.dart';
import 'package:example/pages/loading_page.dart';
import 'package:example/pages/preferences_page.dart';
import 'package:example/pages/product_details_page.dart';
import 'package:example/pages/products_page.dart';
import 'package:example/pages/sign_in_page.dart';
import 'package:example/services/auth_service.dart';
import 'package:example/services/products_service.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

/// This example features a complex
/// app navigation system with child routing
///
/// Most apps don't need all these features
/// but despite the complexity the example
/// is quite understandable

/// all the locations in the app
class RouteLocations {
  // this is the main page which will show the navigation
  // the other pages are displayed inside that page above the nav
  static const app = '/app';
  static const dashboard = '$app/dashboard';
  static const products = '$app/products';
  static const favorites = '$app/favorites';
  static const preferences = '$app/preferences';
  static const productDetail = '$app/products/:id';
  static const productInfo = '$productDetail/info';
  static const productComments = '$productDetail/comments';
  static const signIn = '/sign-in';
}

/// the routes for each location
final _routes = [
  XRoute(
    path: RouteLocations.signIn,
    builder: (ctx, activatedRoute) => SignInPage(),
    titleBuilder: (ctx) => 'sign in ! (Browser tab title)',
  ),
  XRoute(
    path: RouteLocations.preferences,
    builder: (ctx, activatedRoute) => const PreferencesPage(),
    titleBuilder: (ctx) => translate(ctx, 'preferences'),
  ),
  XRoute(
      path: RouteLocations.app,
      builder: (context, activatedRoute) => HomeLayout(child: child)),
  XRoute(
    path: RouteLocations.dashboard,
    builder: (ctx, activatedRoute) => const HomeLayout(
      child: DashboardPage(),
    ),
    titleBuilder: (_) => 'dashboard',
  ),
  XRoute(
    path: RouteLocations.products,
    builder: (ctx, activatedRoute) => const HomeLayout(
      child: ProductsPage(),
    ),
    titleBuilder: (_) => 'products',
  ),
  XRoute(
    path: RouteLocations.favorites,
    builder: (ctx, activatedRoute) => const HomeLayout(
      child: FavoritesPage(),
    ),
    titleBuilder: (_) => 'My favorites',
  ),
  XRoute(
    path: RouteLocations.productDetail,
    builder: (ctx, activatedRoute) => HomeLayout(
      child: ProductDetailsPage(route.pathParams['id']!),
    ),
    // nested Router !
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
              child: Text('comments (Displayed via nested router)')),
        ),
      ],
    ),
  ),
  // XRoute(
  //   path: RouteLocations.home,
  //   builder: (ctx, activatedRoute) => const HomePage(),
  //   childRouterConfig: XChildRouterConfig(
  //     routes: [

  //       // XRoute(
  //       //   path: RouteLocations.productInfo,
  //       //   builder: (ctx, activatedRoute) => ProductDetailsPage(route.pathParams['id']!),
  //       //   // here is a nested router
  //       //   // childRouterConfig: XChildRouterConfig(
  //       //   //   resolvers: [
  //       //   //     XRedirectResolver(
  //       //   //       from: RouteLocations.productDetail,
  //       //   //       to: RouteLocations.productInfo,
  //       //   //     ),
  //       //   //   ],
  //       //   //   routes: [
  //       //   //     XRoute(
  //       //   //       path: RouteLocations.productInfo,
  //       //   //       builder: (_, __) => const Center(
  //       //   //           child: Text('info (Displayed via nested router)')),
  //       //   //     ),
  //       //   //     XRoute(
  //       //   //       path: RouteLocations.productComments,
  //       //   //       builder: (_, __) => const Center(
  //       //   //           child: Text('comments (displayed via nested router)')),
  //       //   //     ),
  //       //   //   ],
  //       //   // ),
  //       // ),
  //     ],
  //   ),
  // ),
];

// the router instance used throughout the app,
// It is up to you if you want to let it as a global variable, use injection,
// inherited widget to access it.. That's outside the scope.
final router = XRouter(
  resolvers: [
    AuthResolver(),
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
    XNotFoundResolver(redirectTo: RouteLocations.app, routes: _routes),
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
          return const Redirect(RouteLocations.app);
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
      debugShowCheckedModeBanner: false,
      title: 'XRouter Demo',
      theme: ThemeData.from(
              colorScheme: const ColorScheme.light(
                  primary: Colors.blue, secondary: Colors.blue))
          .copyWith(
        textSelectionTheme:
            const TextSelectionThemeData(selectionColor: Colors.orange),
      ),
    );
  }
}

// fake translate
String translate(BuildContext ctx, String text) => text;
