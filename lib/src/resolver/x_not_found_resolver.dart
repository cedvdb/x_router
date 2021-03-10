import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/route/x_route.dart';

class XNotFoundResolver with XResolver {
  final String redirectTo;

  XNotFoundResolver({this.redirectTo = '/'});

  @override
  String resolve(String target, List<XRoute> routes) {
    try {
      routes.firstWhere(
        (r) => r.match(target),
      );
      return target;
    } catch (e) {
      return redirectTo;
    }
  }
}
