import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/navigated_route/x_navigated_route.dart';
import 'package:x_router/src/navigated_route/x_navigated_route_builder.dart';
import 'package:x_router/x_router.dart';

void main() {
  group('Activated Route Builder', () {
    late XNavigatedRouteBuilder activatedRouteBuilder;
    late XNavigatedRoute activatedNoMatchDown;
    late XNavigatedRoute activatedMatchDown;
    late XNavigatedRoute activatedWithPoppableStack;
    late XNavigatedRoute activatedWithChildRouter;

    setUp(() {
      activatedRouteBuilder = XNavigatedRouteBuilder(
        routes: [
          XRoute(
            path: '/',
            builder: (_, __) => Container(),
            isAddedToPoppableStack: false,
          ),
          XRoute(
            path: '/products',
            builder: (_, __) => Container(),
          ),
          XRoute(
            path: '/products/create',
            builder: (_, __) => Container(),
          ),
          XRoute(
            path: '/products/:id',
            builder: (_, __) => Container(),
          ),
          XRoute(
            path: '/products/:id/info',
            builder: (_, __) => Container(),
          ),
          XRoute(
            path: '/products/:id/comments',
            builder: (_, __) => Container(),
          ),
          XRoute(
            path: '/products/:id/info/longer',
            builder: (_, __) => Container(),
          ),
          XRoute(
            path: '/preferences',
            builder: (_, __) => Container(),
          ),
        ],
      );
      activatedNoMatchDown = activatedRouteBuilder.build('/');
      activatedMatchDown = activatedRouteBuilder.build('/products');
      activatedWithPoppableStack = activatedRouteBuilder.build('/products/123');
    });

    group('build', () {
      test('should have the correct requested path', () {
        expect(activatedNoMatchDown.requestedPath, equals('/'));
        expect(activatedMatchDown.requestedPath, equals('/products'));
      });

      test(
        'should have the correct matching path',
        () {
          expect(activatedNoMatchDown.matchingPath, equals('/'));
          expect(activatedMatchDown.matchingPath, equals('/products'));
          expect(
              activatedWithPoppableStack.matchingPath, equals('/products/123'));
        },
      );

      test('should match the longest route first', () {
        expect(
          activatedRouteBuilder.build('/products/create').effectivePath,
          equals('/products/create'),
        );
        expect(
          activatedRouteBuilder
              .build('/products/123/info/longer')
              .effectivePath,
          equals('/products/123/info/longer'),
        );
      });

      test('should have the correct parameters', () {
        expect(activatedWithPoppableStack.pathParams['id'], equals('123'));
      });

      test('should have the correct query parameters', () {
        final route =
            activatedRouteBuilder.build('/products?orderBy=creationDate');
        expect(route.queryParams['orderBy'], equals('creationDate'));
      });

      test('should have the correct poppableStack', () {
        expect(activatedNoMatchDown.poppableStack.length, equals(0));
        expect(activatedMatchDown.poppableStack.length, equals(0));
        expect(activatedWithPoppableStack.poppableStack.length, equals(1));
      });
    });
  });
}
