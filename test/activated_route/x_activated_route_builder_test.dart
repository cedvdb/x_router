import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/x_router.dart';

void main() {
  group('Activated Route Builder', () {
    late XActivatedRouteBuilder activatedRouteBuilder;
    late XActivatedRoute activatedNoMatchDown;
    late XActivatedRoute activatedMatchDown;
    late XActivatedRoute activatedWithStack;
    late XActivatedRoute activatedWithChildRouter;

    setUp(() {
      activatedRouteBuilder = XActivatedRouteBuilder(
        routes: [
          XRoute(
            path: '/',
            builder: (_, __) => Container(),
            isAddedToUpstack: false,
          ),
          XRoute(
            path: '/products',
            builder: (_, __) => Container(),
          ),
          XRoute(
            path: '/products/:id',
            builder: (_, __) => Container(),
            childRouterConfig: XChildRouterConfig(
              routes: [
                XRoute(
                  path: '/products/:id/info',
                  builder: (_, __) => Container(),
                ),
                XRoute(
                  path: '/products/:id/comments',
                  builder: (_, __) => Container(),
                ),
              ],
            ),
          ),
          XRoute(
            path: '/preferences',
            builder: (_, __) => Container(),
          ),
        ],
      );
      activatedNoMatchDown = activatedRouteBuilder.build('/');
      activatedMatchDown = activatedRouteBuilder.build('/products');
      activatedWithStack =
          activatedRouteBuilder.build('/products/123/an-unknown-route');
      activatedWithChildRouter =
          activatedRouteBuilder.build('/products/123/an-unknown-route');
    });

    group('build', () {
      test('should have the correct requested path', () {
        expect(activatedNoMatchDown.requestedPath, equals('/'));
        expect(activatedMatchDown.requestedPath, equals('/products'));
        expect(activatedWithStack.requestedPath,
            equals('/products/123/an-unknown-route'));
      });

      test(
        'should have the correct matching path',
        () {
          expect(activatedNoMatchDown.matchingPath, equals('/'));
          expect(activatedMatchDown.matchingPath, equals('/products'));
          expect(activatedWithStack.matchingPath, equals('/products/123'));
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
        expect(activatedNoMatchDown.upstack.length, equals(0));
        expect(activatedMatchDown.upstack.length, equals(0));
        expect(activatedWithStack.upstack.length, equals(1));
      });
    });
  });
}
