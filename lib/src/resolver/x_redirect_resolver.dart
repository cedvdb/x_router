import 'package:flutter/foundation.dart';
import 'package:route_parser/route_parser.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/route/x_route.dart';

class XRedirect with XRouteResolver {
  final String from;
  final String to;
  final bool matchChildren;

  XRedirect({
    @required this.from,
    @required String to,
    this.matchChildren = false,
  }) : to = RouteParser.sanitize(to);

  @override
  String resolve(String target, List<XRoute> routes) {
    if (RouteParser(from).match(to, matchChildren)) {
      return RouteParser.sanitize(to);
    }
  }
}
