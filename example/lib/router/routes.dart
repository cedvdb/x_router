import 'package:example/pages/dashboard_page.dart';
import 'package:example/pages/loading_page.dart';
import 'package:example/pages/product_details_page.dart';
import 'package:example/pages/products_page.dart';
import 'package:example/pages/sign_in_page.dart';
import 'package:example/router/product_found_resolver.dart';
import 'package:x_router/x_router.dart';

class AppRoutes {
  static const home = '/';
  static const dashboard = '/dashboard';
  static const products = '/products';
  static const productDetail = '/products/:id';
  static const productDetailInfo = '$productDetail/info';
  static const productDetailComments = '$productDetail/comments';
  static const loading = '/loading';
  static const signIn = '/sign-in';

  static final routes = [
    XRoute(path: loading, builder: (ctx, params) => LoadingPage()),
    XRoute(path: signIn, builder: (ctx, params) => SignInPage()),
    XRoute(
      path: home,
      builder: null,
      resolvers: [
        XRedirectResolver(from: home, to: dashboard),
      ],
      matchChildren: false,
    ),
    XRoute(path: dashboard, builder: (ctx, params) => DashboardPage()),
    XRoute(path: products, builder: (ctx, params) => ProductsPage()),
    XRoute(
      path: productDetail,
      builder: (ctx, params) => ProductDetailsPage(params['id']!),
      resolvers: [
        productFoundResolver,
        XRedirectResolver(from: '/products/:id', to: '/products/:id/info'),
      ],
    ),
    XRoute(
      path: productDetailInfo,
      builder: (_, __) => ProductInfo(),
    ),
    XRoute(
      path: productDetailComments,
      builder: (_, __) => ProductComments(),
    ),
  ];
}
