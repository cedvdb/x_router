import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/x_router.dart';

class XNotFoundResolver with XResolver {
  final String redirectTo;
  List<XRoute> routes;

  XNotFoundResolver({
    required this.redirectTo,
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
