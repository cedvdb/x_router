import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class AppRoutes {
  static const home = '/';
  static const products = '/products';
  static const preferences = '/preferences';
  static const productDetail = '/products/:id';
  static const signIn = '/sign-in';

  static final routes = [
    XRoute(
      title: 'sign in !',
      path: signIn,
      builder: (ctx, route) => Container(
        key: const ValueKey(AppRoutes.signIn),
      ),
    ),
    XRoute(
      path: preferences,
      builder: (ctx, route) => Container(
        key: const ValueKey(AppRoutes.preferences),
      ),
    ),
    XRoute(
      path: AppRoutes.home,
      builder: (ctx, route) => Container(key: const ValueKey(AppRoutes.home)),
    ),
    XRoute(
      path: products,
      title: 'products',
      builder: (ctx, route) => Container(
        key: const ValueKey(AppRoutes.products),
      ),
    ),
    XRoute(
      path: productDetail,
      builder: (ctx, route) => Container(
          key: ValueKey('${AppRoutes.productDetail}${route.pathParams["id"]}')),
    ),
  ];
}

class MockApp extends StatelessWidget {
  late final XRouter _router;

  MockApp({
    required List<XResolver> resolvers,
    Key? key,
  }) : super(key: key) {
    _router = XRouter(
      routes: AppRoutes.routes,
      resolvers: resolvers,
    );
  }

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

// class AuthResolver extends ValueNotifier with XResolver {
//   AuthResolver() : super(AuthStatus.unknown) {
//     AuthService.instance.authStatus$.listen((status) => value = status);
//   }

//   @override
//   XResolverAction resolve(String target) {
//     switch (value) {
//       case AuthStatus.authenticated:
//         if (target.startsWith(AppRoutes.signIn))
//           return Redirect(AppRoutes.home);
//         else
//           return Next();
//       case AuthStatus.unautenticated:
//         if (target.startsWith(AppRoutes.signIn))
//           return Next();
//         else
//           return Redirect(AppRoutes.signIn);
//       case AuthStatus.unknown:
//       default:
//         return Loading(
//           LoadingPage(text: 'Checking Auth Status'),
//         );
//     }
//   }
// }
