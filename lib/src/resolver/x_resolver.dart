import 'package:x_router/src/resolver/x_resolver_actions.dart';

/// mixin to
abstract class XResolver<T> {
  /// resolve a route with the current state
  Future<XResolverAction> resolve(String target);
}
