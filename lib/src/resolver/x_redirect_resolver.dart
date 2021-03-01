import 'package:flutter/foundation.dart';
import 'package:route_parser/route_parser.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/route/x_route.dart';

class XRedirectResolver with XRouteResolver {
  final RouteParser from;
  final String to;
  final bool matchChildren;

  XRedirectResolver({
    @required String from,
    @required String to,
    this.matchChildren = false,
  })  : to = RouteParser.sanitize(to),
        from = RouteParser(from);

  @override
  String resolve(String target, List<XRoute> routes) {
    if (from.match(target, matchChildren: matchChildren)) {
      return to;
    }
    return target;
  }
}
