import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/x_router.dart';

class ReactiveResolver extends ValueNotifier<bool> with XResolver {
  ReactiveResolver() : super(false);

  @override
  XResolverAction resolve(String target) {
    return const Next();
  }
}

void main() {
  group('NotFoundResolver', () {
    final routes = [
      XRoute(
        path: '/dashboard',
        builder: (context, params) => Container(),
      ),
      XRoute(
        path: '/redirected',
        builder: (context, params) => Container(),
      ),
    ];

    test('should resolve to the route specified when not found', () async {
      final notFoundResolver =
          XNotFoundResolver(redirectTo: '/redirected', routes: routes);
      // found
      expect(
        notFoundResolver.resolve('/dashboard'),
        equals(const Next()),
      );
      // not found
      expect(
        notFoundResolver.resolve('/'),
        equals(const Redirect('/redirected')),
      );
      expect(
        notFoundResolver.resolve('/redirected'),
        equals(const Next()),
      );
      expect(
        notFoundResolver.resolve('/not-found'),
        equals(const Redirect('/redirected')),
      );
    });
  });
}
