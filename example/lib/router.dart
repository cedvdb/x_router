import 'package:example/pages/loading_page.dart';
import 'package:example/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:x_router/x_router.dart';
import 'pages/dashboard_page.dart';
import 'pages/product_details_page.dart';
import 'pages/products_page.dart';

class AppRoutes {
  static final String home = '/';
  static final String dashboard = '/dashboard';
  static final String products = '/products';
  static final String productDetail = '/products/:id';
  static final String loading = '/loading';
}

final router = XRouter(
  resolvers: [
    XNotFoundResolver(redirectTo: '/'),
    AuthResolver(),
    XRedirectResolver(from: '/', to: '/dashboard'),
  ],
  routes: [
    XRoute(
        path: AppRoutes.dashboard, builder: (ctx, params) => DashboardPage()),
    XRoute(path: AppRoutes.products, builder: (ctx, params) => ProductsPage()),
    XRoute(
      path: AppRoutes.productDetail,
      builder: (ctx, params) => ProductDetailsPage(params['id']),
    ),
    XRoute(path: AppRoutes.loading, builder: (ctx, params) => LoadingPage())
  ],
);

class AuthResolver extends ValueNotifier with XRouteResolver {
  AuthResolver() : super(AuthStatus.unknown) {
    AuthService.instance.authStatus$.listen((status) {
      print('authstate changed');
      value = status;
    });
  }

  @override
  String resolve(String target, List<XRoute> routes) {
    print(value);
    switch (value) {
      case AuthStatus.authenticated:
        return '/';
      case AuthStatus.unautenticated:
        return '/sign-in';
      case AuthStatus.unknown:
      default:
        return '/loading';
    }
  }
}
