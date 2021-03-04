import 'package:route_parser/route_parser.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/route/x_route.dart';

class XRedirectResolver with XRouteResolver {
  final RouteParser from;
  final RouteParser to;
  final bool matchChildren;

  XRedirectResolver({
    required String from,
    required String to,
    this.matchChildren = false,
  })  : to = RouteParser(to),
        from = RouteParser(from);

  @override
  String resolve(String target, List<XRoute> routes) {
    final parsed = from.parse(target, matchChildren: matchChildren);
    if (parsed.matches) {
      // we add the params to the redirect
      return to.reverse(parsed.parameters);
    }
    return target;
  }
}
