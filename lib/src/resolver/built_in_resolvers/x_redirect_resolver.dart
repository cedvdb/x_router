import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/route_pattern/x_route_pattern.dart';

class XRedirectResolver implements XResolver {
  final XRoutePattern from;
  final XRoutePattern to;
  final bool matchChildren;

  /// when this is true the redirect happens
  final bool Function()? when;

  XRedirectResolver({
    required String from,
    required String to,
    this.when,
    this.matchChildren = false,
  })  : to = XRoutePattern(to),
        from = XRoutePattern(from);

  @override
  XResolverAction resolve(String target) {
    final parsed = from.parse(target, matchChildren: matchChildren);
    if (parsed.matches && (when == null || when!() == true)) {
      // we add the params to the redirect
      // so if we are on /products/1234 and want to redirect to /products/1234/info
      // the parameters are added
      return Redirect(to.addParameters(parsed.pathParameters));
    }
    return const Next();
  }
}
