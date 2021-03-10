import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/route/x_route.dart';

class XSimpleResolver with XResolver {
  String Function(String target, List<XRoute> routes) resolver;
  XSimpleResolver(this.resolver);

  @override
  String resolve(String target, List<XRoute> routes) {
    return resolver(target, routes);
  }
}
