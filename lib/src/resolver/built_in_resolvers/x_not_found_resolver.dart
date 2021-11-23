import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/route/x_route.dart';

class XNotFoundResolver with XResolver {
  final String redirectTo;
  final List<XRoute> routes;

  XNotFoundResolver({
    this.redirectTo = '/',
    required this.routes,
  });

  @override
  XResolverAction resolve(String target) {
    try {
      routes.firstWhere(
        (r) => r.match(target),
      );
      return const Next();
    } catch (e) {
      return Redirect(redirectTo);
    }
  }
}
