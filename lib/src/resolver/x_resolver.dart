import 'package:x_router/x_router.dart';

/// mixin to
abstract class XResolver<T> {
  /// resolve a route with the current state
  XResolverAction resolve(String target);
}
