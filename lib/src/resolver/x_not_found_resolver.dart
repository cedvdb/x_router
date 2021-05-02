import 'package:flutter/foundation.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/route/x_route.dart';

class XNotFoundResolver extends XResolver {
  final String redirectTo;
  final List<XRoute> routes;

  XNotFoundResolver({
    this.redirectTo = '/',
    required this.routes,
  });

  @override
  Future<String> resolve(String target) {
    try {
      routes.firstWhere(
        (r) => r.match(target),
      );
      return SynchronousFuture(target);
    } catch (e) {
      return SynchronousFuture(redirectTo);
    }
  }
}
