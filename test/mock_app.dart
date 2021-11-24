import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class RouteLocation {
  static const home = '/';
  static const products = '/products';
  static const preferences = '/preferences';
  static const productDetail = '/products/:id';
  static const signIn = '/sign-in';
}

XRouter getTestRouter({List<XResolver> resolvers = const []}) {
  return XRouter(
    resolvers: resolvers,
    routes: [
      XRoute(
        titleBuilder: (_, __) => 'sign in !',
        path: RouteLocation.signIn,
        builder: (ctx, route) => Container(
          key: const ValueKey(RouteLocation.signIn),
        ),
      ),
      XRoute(
        path: RouteLocation.preferences,
        builder: (ctx, route) => Container(
          key: const ValueKey(RouteLocation.preferences),
        ),
      ),
      XRoute(
        path: RouteLocation.home,
        builder: (ctx, route) =>
            Container(key: const ValueKey(RouteLocation.home)),
      ),
      XRoute(
        path: RouteLocation.products,
        titleBuilder: (_, __) => 'products',
        builder: (ctx, route) => Container(
          key: const ValueKey(RouteLocation.products),
        ),
      ),
      XRoute(
        path: RouteLocation.productDetail,
        builder: (ctx, route) => Container(
            key: ValueKey(
                '${RouteLocation.productDetail}-${route.pathParams["id"]}')),
      ),
    ],
  );
}

class TestApp extends StatelessWidget {
  final XRouter router;

  const TestApp(
    this.router, {
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

class MockAuthResolver extends ValueNotifier<bool?> with XResolver {
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
