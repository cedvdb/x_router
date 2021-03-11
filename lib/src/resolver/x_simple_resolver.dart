import 'package:x_router/src/resolver/x_resolver.dart';

class XSimpleResolver with XResolver {
  String Function(String target) resolver;
  XSimpleResolver(this.resolver);

  @override
  String resolve(String target) {
    return resolver(target);
  }
}
