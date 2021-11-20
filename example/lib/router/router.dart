import 'package:example/router/routes.dart';
import 'package:x_router/x_router.dart';

import 'auth_resolver.dart';

final router = XRouter(
  resolvers: [
    XNotFoundResolver(redirectTo: AppRoutes.home, routes: AppRoutes.routes),
    AuthResolver(),
  ],
  routes: AppRoutes.routes,
  onEvent: (s) => print(s),
);
