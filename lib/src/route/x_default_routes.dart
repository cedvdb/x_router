import 'package:flutter/material.dart';

import 'x_route.dart';

/// When no matching route was found
class XNotFoundRoute extends XRoute {
  XNotFoundRoute(String path)
      : super(
          path: path,
          builder: (ctx, params) => const Text('''
        Route path not found. 
        Consider using a XNotFoundResolver resolver to get the user to a known page.
        Read the documentation for more info.
      '''),
        );
}
