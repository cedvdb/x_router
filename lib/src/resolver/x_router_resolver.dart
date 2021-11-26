import 'package:x_router/src/events/x_router_events.dart';
import 'package:x_router/src/exceptions/x_router_exception.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';

import 'x_resolver_event.dart';

class XRouterResolver {
  // singleton

  final List<XResolver> _resolvers = [];
  Function(XRouterEvent) onEvent;

  XRouterResolver({required this.onEvent});

  addResolvers(List<XResolver> resolvers) {
    _resolvers.addAll(resolvers);
  }

  /// resolve target path against the list of resolvers
  ///
  /// [calls] since this can easily lead to infinite loop by user error
  /// the calls attribute is to keep track of the number of times this fn
  /// was called recursively
  XRouterResolveResult resolve(
    String path, {
    bool isRedirect = false,
    int calls = 0,
  }) {
    _checkInfiniteLoop(calls);
    var next = path;

    for (final resolver in _resolvers) {
      final resolved = _useResolver(resolver, next);

      if (resolved is Loading) {
        // if it is loading we need to wait for an effective result
        // so this is the end, but we override the builder
        // so the client can display a loading screen
        return XRouterResolveResult(
          builderOverride: resolved.loadingScreenBuilder,
          target: next,
        );
      }

      // if it is a redirect then we start the resolving process over
      if (resolved is Redirect) {
        return resolve(
          resolved.target,
          isRedirect: true,
          calls: calls + 1,
        );
      }
    }
    // if we reach here we have resolved the final route
    return XRouterResolveResult(target: next);
  }

  /// resolve path against a specific resolver
  XResolverAction _useResolver(
    XResolver resolver,
    String path,
  ) {
    onEvent(ResolverResolveStart(resolver: resolver, target: path));

    final resolved = resolver.resolve(path);
    onEvent(ResolverResolveEnd(
        resolver: resolver, target: path, resolved: resolved));
    return resolved;
  }

  /// checks if the number of redirects passes over a threshold
  void _checkInfiniteLoop(int redirectAmount) {
    // 10 is arbitrary here, it's the max number of redirects before
    // we decide it's an infinite loop
    if (redirectAmount > 10) {
      throw XRouterException(
        description: 'XRouter error: infinite resolver loop detected. '
            'This is likely because you have resolvers doing ping pong with each others, '
            'where resolver A is resolving to a route with resolver B and '
            'resolver B is resolving to a route with resolver A',
      );
    }
  }
}
