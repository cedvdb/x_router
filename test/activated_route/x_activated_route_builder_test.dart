import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/x_router.dart';

void main() {
  group('Activated Route Builder', () {
    late XActivatedRouteBuilder activatedRouteBuilder;
    late XActivatedRoute activatedNoMatchChild;
    late XActivatedRoute activatedMatchChild;
    late XActivatedRoute activatedWithStack;

    setUp(() {
      activatedRouteBuilder = XActivatedRouteBuilder(
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
      activatedNoMatchChild = activatedRouteBuilder.build('/');
      activatedMatchChild = activatedRouteBuilder.build('/products');
      activatedWithStack =
          activatedRouteBuilder.build('/products/123/an-unknown-route');
    });

    group('build', () {
      test('should have the correct requested path', () {
        expect(activatedNoMatchChild.requestedPath, equals('/'));
        expect(activatedMatchChild.requestedPath, equals('/products'));
        expect(activatedWithStack.requestedPath,
            equals('/products/123/an-unknown-route'));
      });

      test(
        'should have the correct effective path',
        () {
          expect(activatedNoMatchChild.effectivePath, equals('/'));
          expect(activatedMatchChild.effectivePath, equals('/products'));
          expect(activatedWithStack.effectivePath, equals('/products/123'));
        },
      );

      test('should have the correct parameters', () {
        expect(activatedWithStack.pathParams['id'], equals('123'));
      });

      test('should have the correct query parameters', () {
        final route =
            activatedRouteBuilder.build('/products?orderBy=creationDate');
        expect(route.queryParams['orderBy'], equals('creationDate'));
      });

      test('should have the correct upstack', () {
        expect(activatedNoMatchChild.upstack.length, equals(0));
        expect(activatedMatchChild.upstack.length, equals(0));
        expect(activatedWithStack.upstack.length, equals(1));
      });
    });
  });
}
