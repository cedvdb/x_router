import 'package:example/pages/loading_page.dart';
import 'package:example/pages/sign_in_page.dart';
import 'package:example/router/routes.dart';
import 'package:example/services/products_service.dart';
import 'package:x_router/x_router.dart';

import '../pages/dashboard_page.dart';
import '../pages/product_details_page.dart';
import '../pages/products_page.dart';
import 'auth_resolver.dart';
import 'product_found_resolver.dart';

final router = XRouter(
  resolvers: [
    XNotFoundResolver(redirectTo: '/'),
    AuthResolver(),
    XRedirectResolver(from: '/', to: AppRoutes.dashboard),
  ],
  routes: [
    XRoute(
      path: AppRoutes.dashboard,
      builder: (ctx, params) => DashboardPage(),
    ),
    XRoute(
      path: AppRoutes.products,
      builder: (ctx, params) => ProductsPage(),
    ),
    XRoute(
        path: AppRoutes.productDetail,
        builder: (ctx, params) => ProductDetailsPage(params['id']),
        resolvers: [
          productFoundResolver,
        ]),
    XRoute(
      path: AppRoutes.loading,
      builder: (ctx, params) => LoadingPage(),
    ),
    XRoute(
      path: AppRoutes.signIn,
      builder: (ctx, params) => SignInPage(),
    )
  ],
  onRouterStateChanges: (s) => print(s),
);
