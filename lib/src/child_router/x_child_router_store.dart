import 'package:x_router/src/child_router/x_child_router.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/exceptions/x_router_exception.dart';
import 'package:x_router/x_router.dart';

/// holds child routers to access their delegate easily
class XChildRouterStore {
  final Map<String, XChildRouter> _childRouters = {};

  XChildRouterStore({
    required List<XRoute> routes,
  }) {
    _storeChildRouters(routes);
  }

  _storeChildRouters(List<XRoute> routes) {
    for (final route in routes) {
      final children = route.childRouterConfig;
      if (children != null) {
        _childRouters[route.path] = XChildRouter(
          basePath: route.path,
          routes: children.routes,
        );
        _storeChildRouters(children.routes);
      }
    }
  }

  XRouterDelegate findDelegate(String path) {
    final childRouter = _childRouters[path];
    if (childRouter == null) {
      throw XRouterException(
          description:
              'The path $path has not been configured as a child router');
    }
    return childRouter.delegate;
  }
}
