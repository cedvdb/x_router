import 'package:flutter/foundation.dart';
import 'package:x_router/x_router.dart';

/// wrapper for resolver that are put on specific routes so they are
/// only active on that route
class XRouteResolver extends XResolver {
  final XResolver resolver;
  final XRoute route;

  XRouteResolver({
    required this.resolver,
    required this.route,
  }) : super(initialState: resolver.state) {
    // bubble the change event if any
    resolver.state$.listen((s) => state = s);
  }

  @override
  Future<String> resolve(String target) {
    if (route.match(target)) {
      return resolver.resolve(target);
    }
    return SynchronousFuture(target);
  }
}
