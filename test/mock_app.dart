import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class RouteLocation {
  static const home = '/';
  static const products = '/products';
  static const preferences = '/preferences';
  static const productDetails = '/products/:id';
  static const productDetailsInfo = '$productDetails/info';
  static const productDetailsComments = '$productDetails/comments';
  static const signIn = '/sign-in';
}

XRouter createTestRouter({List<XResolver> resolvers = const []}) {
  late XRouter router;
  router = XRouter(
    resolvers: resolvers,
    routes: [
      XRoute(
        titleBuilder: (_) => 'sign in !',
        path: RouteLocation.signIn,
        builder: (ctx, navigatedRoute) => Container(
          key: const ValueKey(RouteLocation.signIn),
        ),
      ),
      XRoute(
        path: RouteLocation.preferences,
        builder: (ctx, navigatedRoute) => Container(
          key: const ValueKey(RouteLocation.preferences),
        ),
      ),
      XRoute(
        path: RouteLocation.home,
        builder: (ctx, navigatedRoute) =>
            Container(key: const ValueKey(RouteLocation.home)),
      ),
      XRoute(
        path: RouteLocation.products,
        titleBuilder: (_) => 'products',
        builder: (ctx, navigatedRoute) => Container(
          key: const ValueKey(RouteLocation.products),
        ),
      ),
      XRoute(
        path: RouteLocation.productDetails,
        builder: (ctx, navigatedRoute) => Container(
          key: ValueKey(
              '${RouteLocation.productDetails}-${navigatedRoute.pathParams["id"]}'),
          child: ProductDetailsPage(
            router: router,
          ),
        ),
        children: [
          XRoute(
            path: RouteLocation.productDetailsInfo,
            builder: (_, __) => Container(
              key: const ValueKey(RouteLocation.productDetailsInfo),
            ),
          ),
          XRoute(
            path: RouteLocation.productDetailsComments,
            builder: (_, __) => Container(
              key: const ValueKey(RouteLocation.productDetailsComments),
            ),
          ),
        ],
      ),
    ],
  );
  return router;
}

class TestApp extends StatelessWidget {
  final XRouter router;
  const TestApp({
    Key? key,
    required this.router,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: router.delegate,
      routeInformationParser: router.informationParser,
      routeInformationProvider: router.informationProvider,
      debugShowCheckedModeBanner: false,
      title: 'XRouter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

// nested router
class ProductDetailsPage extends StatelessWidget {
  final XRouter router;
  const ProductDetailsPage({Key? key, required this.router}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Router(
      routerDelegate: router.childRouterStore
          .findChild(RouteLocation.productDetails)
          .delegate,
    );
  }
}

class MockAuthResolver extends ValueNotifier implements XResolver {
  MockAuthResolver() : super(null);

  signIn() => value = true;

  signOut() => value = false;

  @override
  XResolverAction resolve(String target) {
    switch (value) {
      case true:
        if (target.startsWith(RouteLocation.signIn)) {
          return const Redirect(RouteLocation.home);
        } else {
          return const Next();
        }
      case false:
        if (target.startsWith(RouteLocation.signIn)) {
          return const Next();
        } else {
          return const Redirect(RouteLocation.signIn);
        }
      default:
        return Loading(
          (ctx, route) => Container(
            key: const ValueKey('loading-screen'),
          ),
        );
    }
  }
}
