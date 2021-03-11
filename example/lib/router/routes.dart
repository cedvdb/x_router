import 'package:example/pages/dashboard_page.dart';
import 'package:example/pages/loading_page.dart';
import 'package:example/pages/product_details_page.dart';
import 'package:example/pages/products_page.dart';
import 'package:example/pages/sign_in_page.dart';
import 'package:example/router/product_found_resolver.dart';
import 'package:x_router/x_router.dart';

class AppRoutes {
  static final String home = '/';
  static final String dashboard = '/dashboard';
  static final String products = '/products';
  static final String productDetail = '/products/:id';
  static final String loading = '/loading';
  static final String signIn = '/sign-in';

  static final routes = [
    XRoute(path: dashboard, builder: (ctx, params) => DashboardPage()),
    XRoute(path: products, builder: (ctx, params) => ProductsPage()),
    XRoute(
      path: productDetail,
      builder: (ctx, params) => ProductDetailsPage(params['id']),
      resolvers: [productFoundResolver],
    ),
    XRoute(path: loading, builder: (ctx, params) => LoadingPage()),
    XRoute(path: signIn, builder: (ctx, params) => SignInPage()),
  ];
}
