import 'package:flutter/cupertino.dart';
import 'package:x_router/x_router.dart';

/// wrapper for resolver that are put on specific routes so they are
/// only active on that route
class XRouteResolver with XResolver, ChangeNotifier {
  final XResolver resolver;
  final XRoute route;

  XRouteResolver({
    required this.resolver,
    required this.route,
  }) {
    // bubble the change event if any
    if (resolver is ChangeNotifier) {
      (resolver as ChangeNotifier).addListener(notifyListeners);
    }
  }

  @override
  String resolve(String target, List<XRoute> routes) {
    if (route.match(target)) {
      resolver.resolve(target, routes);
    }
    return target;
  }
}
