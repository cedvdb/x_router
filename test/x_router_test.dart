import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/x_router.dart';

import 'mock_app.dart';

void main() {
  group('router', () {
    setUp(() => createTestRouter());
    group('initialization', () {
      testWidgets('should render initial page', (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(RouteLocation.home)), findsOneWidget);
      });
      testWidgets('should have history of one', (tester) async {
        await tester.pumpWidget(const TestApp());
        expect(router.history.length, equals(1));
        expect(router.history.currentRoute.effectivePath,
            equals(RouteLocation.home));
      });
    });

    group('goTo', () {
      testWidgets('should render next page', (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.products);
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey(RouteLocation.products)), findsOneWidget);
      });

      testWidgets('should use parameters', (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.productDetails, params: {'id': '123'});
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey('${RouteLocation.productDetails}-123')),
            findsOneWidget);
      });
      testWidgets('should add to history', (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.products);
        await tester.pumpAndSettle();
        expect(router.history.length, equals(2));
        expect(router.history.currentRoute.effectivePath,
            equals(RouteLocation.products));
        expect(router.history.previousRoute?.effectivePath,
            equals(RouteLocation.home));
      });

      testWidgets('should navigate relatively', (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.productDetailsComments, params: {'id': '3'});
        await tester.pumpAndSettle();
        router.goTo('./info');

        expect(router.history.length, equals(3));
        expect(router.history.currentRoute.effectivePath,
            equals('/products/3/info'));
        expect(router.history.currentRoute.pathParams['id'], equals('3'));
      });
    });
    group('replace', () {
      testWidgets('Should render next page', (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        router.replace(RouteLocation.products);
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey(RouteLocation.products)), findsOneWidget);
      });
      testWidgets('should replace in history', (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        router.replace(RouteLocation.products);
        await tester.pumpAndSettle();
        expect(router.history.length, equals(1));
        expect(router.history.currentRoute.effectivePath,
            equals(RouteLocation.products));
      });
    });

    group('pop', () {
      testWidgets('Should render next page', (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.productDetails);
        await tester.pumpAndSettle();
        router.pop();
        await tester.pumpAndSettle();
        // products is above in upstack
        expect(
            find.byKey(const ValueKey(RouteLocation.products)), findsOneWidget);
      });
      testWidgets('should add in history', (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.products);
        await tester.pumpAndSettle();
        router.pop();
        await tester.pumpAndSettle();
        expect(router.history.length, equals(3));
        expect(router.history.currentRoute.effectivePath,
            equals(RouteLocation.home));
      });
    });

    group('back', () {
      testWidgets('Should render next page', (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.products);
        await tester.pumpAndSettle();
        router.back();
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(RouteLocation.home)), findsOneWidget);
      });
      testWidgets('should remove in history', (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.products);
        await tester.pumpAndSettle();
        router.back();
        await tester.pumpAndSettle();
        expect(router.history.length, equals(1));
        expect(router.history.currentRoute.effectivePath,
            equals(RouteLocation.home));
      });
    });

    group('refresh', () {
      testWidgets('should stay on current route if no redirection',
          (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.products);
        await tester.pumpAndSettle();
        router.refresh();
        await tester.pumpAndSettle();
        expect(router.history.currentRoute.effectivePath,
            equals(RouteLocation.products));
      });

      testWidgets('history does not increase', (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.products);
        await tester.pumpAndSettle();
        expect(router.history.length, equals(2));
        router.refresh();
        await tester.pumpAndSettle();
        expect(router.history.length, equals(2));
      });
    });

    group('resolvers', () {
      testWidgets('Should render with redirect', (tester) async {
        final router = createTestRouter(
          resolvers: [
            XRedirectResolver(
                from: RouteLocation.home, to: RouteLocation.products),
            XRedirectResolver(
                from: RouteLocation.preferences, to: RouteLocation.home),
          ],
        );
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        expect(router.history.length, equals(1));
        expect(router.history.currentRoute.effectivePath,
            equals(RouteLocation.products));
        // goes back to first redirect
        router.goTo(RouteLocation.preferences);
        expect(router.history.length, equals(1));
        expect(router.history.currentRoute.effectivePath,
            equals(RouteLocation.products));
      });

      testWidgets('Should display loading if resolver is not ready',
          (tester) async {
        final authResolver = MockAuthResolver();
        final router = createTestRouter(
          resolvers: [authResolver],
        );
        authResolver.router = router;
        await tester.pumpWidget(const TestApp());

        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('loading-screen')), findsOneWidget);
      });

      testWidgets('should redirect after refresh if redirector state changed',
          (tester) async {
        final authResolver = MockAuthResolver();
        final router = createTestRouter(
          resolvers: [authResolver],
        );
        authResolver.router = router;
        await tester.pumpWidget(const TestApp());

        await tester.pumpAndSettle();
        authResolver.signIn();
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('loading-screen')), findsNothing);
        expect(find.byKey(const ValueKey(RouteLocation.home)), findsOneWidget);
        expect(find.byKey(const ValueKey(RouteLocation.signIn)), findsNothing);

        authResolver.signOut();
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey(RouteLocation.signIn)), findsOneWidget);
      });

      testWidgets('should access child router page', (tester) async {
        await tester.pumpWidget(const TestApp());
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.productDetailsInfo, params: {'id': 'id'});
        await tester.pumpAndSettle();
        expect(router.history.length, equals(2));
        expect(find.byKey(const ValueKey('${RouteLocation.productDetails}-id')),
            findsOneWidget);
        expect(find.byKey(const ValueKey(RouteLocation.productDetailsInfo)),
            findsOneWidget);
        expect(find.byKey(const ValueKey(RouteLocation.productDetailsComments)),
            findsNothing);
        router.goTo(RouteLocation.productDetailsComments, params: {'id': 'id'});
        // router.ewd(RouteLocation.productDetailsComments, params: {'id': 'id'});

        await tester.pumpAndSettle();
        // await tester.pump(const Duration(days: 1));
        // await tester.pumpAndSettle();

        expect(router.history.length, equals(3));
        expect(router.history.currentRoute.effectivePath,
            equals('/products/id/comments'));
        expect(find.byKey(const ValueKey('${RouteLocation.productDetails}-id')),
            findsOneWidget);
        // expect(find.byKey(const ValueKey(RouteLocation.productDetailsComments)),
        //     findsOneWidget);
        // expect(find.byKey(const ValueKey(RouteLocation.productDetailsInfo)),
        //     findsNothing);
      });
    });
  });
}
