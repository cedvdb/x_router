import 'package:x_router/src/router/x_base_router.dart';

import '../../x_router.dart';

class XChildRouter extends XRouterBase {
  final String basePath;

  XChildRouter({
    required this.basePath,
    required List<XRoute> routes,
    List<XResolver> resolvers = const [],
  }) : super(isRoot: false, resolvers: resolvers, routes: routes) {
    childRouters.add(this);
  }
}
