import 'package:example/pages/home_layout.dart';
import 'package:example/pages/product_details_page.dart';
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
      pageKey: const ValueKey('Home'),
      path: dashboard,
      builder: (ctx, params) => HomeLayout(
        key: const ValueKey('home_layout'),
        index: 0,
        title: 'dashboard',
      ),
    ),
    XRoute(
      path: products,
      pageKey: const ValueKey('Home'),
      builder: (ctx, params) => HomeLayout(
        key: const ValueKey('home_layout'),
        index: 1,
        title: 'products',
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
