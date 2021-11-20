import 'package:flutter/foundation.dart';
import 'package:x_router/src/parser/x_route_parser.dart';
import 'package:x_router/src/resolver/x_resolver.dart';

class XRedirectResolver extends XResolver {
  final XRoutePattern from;
  final XRoutePattern to;
  final bool matchChildren;

  XRedirectResolver({
    required String from,
    required String to,
    this.matchChildren = false,
  })  : to = XRoutePattern(to),
        from = XRoutePattern(from);

  @override
  Future<String> resolve(String target) {
    final parsed = from.parse(target, matchChildren: matchChildren);
    if (parsed.matches) {
      // we add the params to the redirect
      return SynchronousFuture(to.addParameters(parsed.parameters));
    }
    return SynchronousFuture(target);
  }
}
