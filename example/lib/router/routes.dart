import 'package:example/pages/dashboard_page.dart';
import 'package:example/pages/home_layout.dart';
import 'package:example/pages/loading_page.dart';
import 'package:example/pages/product_details_page.dart';
import 'package:example/pages/products_page.dart';
import 'package:example/pages/sign_in_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:x_router/x_router.dart';

class AppRoutes {
  static const home = '/app';
  static const dashboard = '$home/dashboard';
  static const products = '$home/products';
  static const productDetail = '$home/products/:id';
  static const productDetailInfo = '$productDetail/info';
  static const productDetailComments = '$productDetail/comments';
  static const loading = '/loading';
  static const signIn = '/sign-in';

  static final routes = [
    XRoute(
        title: 'sign in !',
        path: signIn,
        builder: (ctx, params) => SignInPage()),
    XRoute(
      path: home,
      builder: (ctx, params) => Container(),
      matchChildren: false,
    ),
    XRoute(
      title: 'dashboard',
      path: dashboard,
      builder: (ctx, params) =>
          HomeLayout(title: 'Dashboard', child: DashboardPage()),
    ),
    XRoute(
      path: products,
      builder: (ctx, params) => HomeLayout(
        title: 'products',
        child: ProductsPage(),
      ),
    ),
    XRoute(
      path: productDetail,
      builder: (ctx, params) => ProductDetailsPage(params['id']!),
      resolvers: [
        // productFoundResolver,
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
