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

  // static final notFoundRoute = XRoute(path: '/not-found', redirect: (_) => '/');

  static final notFoundRoute = XRoute(
    path: '/not-found',
    builder: (ctx, params) => Text('''

        Route path not found. 
        Consider using a XNotFoundResolver resolver to get the user to a known page.
        You can achieve it with:

        XRouter(
          resolvers: [XNotFoundResolver(redirectTo: '/dashboard')],
          routes: [
            XRoute(path: '/dashboard', builder: (_, __) => DashboardPage())
          ]
        )

        If you are using XNotFoundResolver and still see this message it means
        that another resolver down the pipeline is resolving to a wrong path.
      '''),
  );
}
