import 'package:x_router/src/parser/x_route_parser.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/route/x_route.dart';

class XRedirectResolver with XResolver {
  final XRouteParser from;
  final XRouteParser to;
  final bool matchChildren;

  XRedirectResolver({
    required String from,
    required String to,
    this.matchChildren = false,
  })  : to = XRouteParser(to),
        from = XRouteParser(from);

  @override
  String resolve(String target, List<XRoute> routes) {
    print('redirect $target');
    final parsed = from.parse(target, matchChildren: matchChildren);
    if (parsed.matches) {
      // we add the params to the redirect
      return to.reverse(parsed.parameters);
    }
    return target;
  }
}
