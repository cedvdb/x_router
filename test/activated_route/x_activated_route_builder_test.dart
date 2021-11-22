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
      activatedMatchChild =
          activatedRouteBuilder.build('/products?orderBy=creationDate');
      activatedWithStack =
          activatedRouteBuilder.build('/products/123/an-unknown-route');
    });

    group('build', () {
      test('should have the correct path', () {
        expect(activatedNoMatchChild.effectivePath, equals('/'));
        expect(activatedMatchChild.effectivePath, equals('/products'));
        expect(activatedWithStack.effectivePath,
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
        expect(
            activatedWithStack.queryParams['orderBy'], equals('creationDate'));
      });

      test('should have the correct upstack', () {
        expect(activatedNoMatchChild.upstack.length, equals(0));
        expect(activatedMatchChild.upstack.length, equals(0));
        expect(activatedWithStack.upstack.length, equals(1));
      });
    });

    group('add', () {
      test('should add to the upstack', () {
        final added = activatedRouteBuilder.add('/preferences',
            [activatedWithStack, ...activatedWithStack.upstack]);
        expect(added.upstack.length, equals(2));
      });
    });
  });
}
