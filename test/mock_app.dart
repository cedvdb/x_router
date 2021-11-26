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

late XRouter router;
XRouter createTestRouter({List<XResolver> resolvers = const []}) {
  router = XRouter(
    resolvers: resolvers,
    routes: [
      XRoute(
        titleBuilder: (_, __) => 'sign in !',
        path: RouteLocation.signIn,
        builder: (ctx, activeRoute) => Container(
          key: const ValueKey(RouteLocation.signIn),
        ),
      ),
      XRoute(
        path: RouteLocation.preferences,
        builder: (ctx, activeRoute) => Container(
          key: const ValueKey(RouteLocation.preferences),
        ),
      ),
      XRoute(
        path: RouteLocation.home,
        builder: (ctx, activeRoute) =>
            Container(key: const ValueKey(RouteLocation.home)),
      ),
      XRoute(
        path: RouteLocation.products,
        titleBuilder: (_, __) => 'products',
        builder: (ctx, activeRoute) => Container(
          key: const ValueKey(RouteLocation.products),
        ),
      ),
      XRoute(
        path: RouteLocation.productDetails,
        builder: (ctx, activeRoute) => Container(
          key: ValueKey(
              '${RouteLocation.productDetails}-${activeRoute.pathParams["id"]}'),
          child: const ProductDetailsPage(),
        ),
        childRouterConfig: XChildRouterConfig(
          routes: [
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
      ),
    ],
  );
  return router;
}

class TestApp extends StatelessWidget {
  const TestApp({
    Key? key,
  }) : super(key: key);

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

// nested router
class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Router(
      routerDelegate:
          router.childRouterStore.findDelegate(RouteLocation.productDetails),
    );
  }
}

class MockAuthResolver implements XResolver {
  bool? _isAuthenticated;
  XRouter? router;
  MockAuthResolver();

  signIn() {
    _isAuthenticated = true;
    router?.refresh();
  }

  signOut() {
    _isAuthenticated = false;
    router?.refresh();
  }

  @override
  XResolverAction resolve(String target) {
    switch (_isAuthenticated) {
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
