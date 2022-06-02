import 'package:x_router/src/exceptions/x_router_exception.dart';
import 'package:x_router/src/router/base_router.dart';

import 'x_child_router.dart';

/// holds child routers to access their delegate easily
/// if a route has children routes then it is a child router
class XChildRouterStore {
  final Map<String, BaseRouter> _childRouters;

  XChildRouterStore._(this._childRouters);

  factory XChildRouterStore.forParent(
    BaseRouter parent,
  ) {
    final childRouters = <String, BaseRouter>{};
    _computeChildRoutersMap(parent, childRouters);
    return XChildRouterStore._(childRouters);
  }

  static _computeChildRoutersMap(
    BaseRouter parent,
    Map<String, BaseRouter> childRoutersMap,
  ) {
    for (final route in parent.routes) {
      final hasChildren = route.children.isNotEmpty;
      if (hasChildren) {
        final childRouter = XChildRouter(
          parent: parent,
          routes: route.children,
        );
        childRoutersMap[route.path] = childRouter;
      }
    }
  }

  BaseRouter findChild(String routePath) {
    final childRouter = _childRouters[routePath];
    if (childRouter == null) {
      throw XRouterException(
          description: 'The route $routePath does not contain a child router');
    }
    return childRouter;
  }
}
