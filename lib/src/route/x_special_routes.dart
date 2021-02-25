import 'package:flutter/material.dart';

import 'x_route.dart';

/// Special routes used internally by this package
class XSpecialRoutes {
// special route used for initialization, before we know the url
// the path doesn't matter
  static final initializationRoute = XRoute(
    path: '',
    builder: (ctx, params) => Center(
      child: CircularProgressIndicator(),
    ),
  );

  static final notFoundRoute = XRoute(path: '/not-found', redirect: (_) => '/');

  // static final notFoundRoute = XRoute(
  //     path: '/not-found',
  //     builder: (ctx, params) => Scaffold(
  //           appBar: AppBar(),
  //           body: Text('''
  //                 route not found, consider using redirection to get the user to a known page.
  //                 You can achieve it with:

  //                 XRouter(
  //                   notFound: XRoute(redirect: (_) => '/dashboard'),
  //                   routes: [
  //                     XRoute(path: '/dashboard', builder: (_, __) => DashboardPage())
  //                   ]
  //                 )
  //                 '''),
  //         ));
}
