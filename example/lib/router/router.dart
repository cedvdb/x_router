import 'package:example/router/routes.dart';
import 'package:x_router/x_router.dart';

import 'auth_resolver.dart';

final router = XRouter(
  resolvers: [
    AuthResolver(),
    XRedirectResolver(from: AppRoutes.home, to: AppRoutes.dashboard),
    XNotFoundResolver(redirectTo: AppRoutes.home, routes: AppRoutes.routes),
  ],
  routes: AppRoutes.routes,
  onEvent: (s) => print(s),
);
