import 'package:example/pages/product_details_page.dart';
import 'package:example/router/routes.dart';
import 'package:x_router/x_router.dart';

import 'auth_resolver.dart';

final router = XRouter(
  resolvers: [
    XNotFoundResolver(redirectTo: '/', routes: AppRoutes.routes),
    AuthResolver(),
    XRedirectResolver(from: '/', to: AppRoutes.dashboard),
  ],
  routes: AppRoutes.routes,
  onRouterStateChanges: (s) => print(s),
)..addChildren([productDetailsRouter]);
