import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/x_router.dart';

void main() {
  group('Activated Route Builder', () {
    final activatedRouteBuilder = XActivatedRouteBuilder(
      routes: [
        XRoute(
          path: '/',
          builder: (_, __) => Container(),
          matchChildren: false,
        ),
        XRoute(
          path: '/products',
          builder: (_, __) => Container(),
        ),
        XRoute(
          path: '/products/:id',
          builder: (_, __) => Container(),
        ),
        XRoute(
          path: '/preferences',
          builder: (_, __) => Container(),
        ),
      ],
    );

    group('build', () {
      final activated = activatedRouteBuilder.build('/');
      final activated2 =
          activatedRouteBuilder.build('/products?orderBy=creationDate');
      final activated3 =
          activatedRouteBuilder.build('/products/123/an-unknown-route');

      test('should have the correct path', () {
        expect(activated.effectivePath, equals('/'));
        expect(activated2.effectivePath, equals('/products'));
        expect(
            activated3.effectivePath, equals('/products/123/an-unknown-route'));
      });

      test(
        'should have the correct effective path',
        () {
          expect(activated.effectivePath, equals('/'));
          expect(activated2.effectivePath, equals('/products'));
          expect(activated3.effectivePath, equals('/products/123'));
        },
      );

      test('should have the correct parameters', () {
        expect(activated3.pathParameters['id'], equals('123'));
      });

      test('should have the correct query parameters', () {
        expect(activated3.queryParameters['orderBy'], equals('creationDate'));
      });

      test('should have the correct upstack', () {
        expect(activated.upstack.length, equals(0));
        expect(activated2.upstack.length, equals(0));
        expect(activated3.upstack.length, equals(1));
      });
    });

    group('add', () {
      test('should add to the upstack', () => null);
    });
  });
}
