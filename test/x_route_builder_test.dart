import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/x_router.dart';

void main() {
  group('Activated Route Builder', () {
    final routeBuilder = XActivatedRouteBuilder(routes: [
      XRoute(path: '/', builder: (_, __) => Container(), matchChildren: false),
      XRoute(path: '/products', builder: (_, __) => Container()),
      XRoute(path: '/products/:id', builder: (_, __) => Container())
    ], isRoot: true);

    test('should start build when routing state says so', () {});

    test(
      'should build activated route',
      () {
        final activated = routeBuilder.build('/');
        final activated2 = routeBuilder.build('/products');
        final activated3 = routeBuilder.build('/products/123');

        expect(activated.effectivePath, equals('/'));
        expect(activated2.effectivePath, equals('/products'));
        expect(activated3.effectivePath, equals('/products/123'));
        expect(activated.upstack.length, equals(0));
        expect(activated2.upstack.length, equals(0));
        expect(activated3.upstack.length, equals(1));
      },
    );

    test('should build activated route with not found', () {
      final notFound1 = routeBuilder.build('/not-found');
      final shouldFindChild = routeBuilder.build('/products/123/not-found');

      expect(notFound1.effectivePath, equals('/not-found'));
      expect(shouldFindChild.effectivePath, equals('/products/123'));
    });
  });
}
