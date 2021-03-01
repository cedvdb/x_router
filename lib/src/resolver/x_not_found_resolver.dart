import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/route/x_route.dart';

class XNotFoundResolver with XRouteResolver {
  final String redirectTo;

  XNotFoundResolver({this.redirectTo = '/'});

  @override
  String resolve(String target, List<XRoute> routes) {
    final found = routes.firstWhere(
      (r) => r.match(target),
      orElse: () => null,
    );
    if (found != null) {
      return target;
    }
    return redirectTo;
  }
}
