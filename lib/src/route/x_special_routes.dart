import 'package:flutter/material.dart';

import 'x_route.dart';

/// Special routes used internally by this package
class XSpecialRoutes {
  // static final notFoundRoute = XRoute(path: '/not-found', redirect: (_) => '/');

  static final notFoundRoute = XRoute(
    path: '/not-found',
    builder: (ctx, params) => Text('''

        Route path not found. 
        Consider using a XNotFoundResolver resolver to get the user to a known page.
        Read the documentation for more info.
      '''),
  );
}
