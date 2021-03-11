import 'package:x_router/src/resolver/x_resolver.dart';

class XSimpleResolver with XResolver {
  Future<String> Function(String target) resolver;
  XSimpleResolver(this.resolver);

  @override
  Future<String> resolve(String target) {
    return resolver(target);
  }
}
