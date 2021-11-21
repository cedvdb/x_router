import 'package:x_router/src/resolver/x_resolver.dart';

class XSimpleResolver extends XResolver {
  XResolverAction Function(String target) resolver;
  XSimpleResolver(this.resolver);

  @override
  XResolverAction resolve(String target) {
    return resolver(target);
  }
}
