import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/x_router.dart';

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
        await notFoundResolver.resolve('/dashboard'),
        equals(const Next()),
      );
      // not found
      expect(
        await notFoundResolver.resolve('/'),
        equals(const Redirect('/redirected')),
      );
      expect(
        await notFoundResolver.resolve('/redirected'),
        equals(const Next()),
      );
      expect(
        await notFoundResolver.resolve('/not-found'),
        equals(const Redirect('/redirected')),
      );
    });
  });
}
