import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/x_router.dart';

import 'mock_app.dart';

void main() {
  group('router', () {
    late XRouter router;
    setUp(() => router = createTestRouter());
    group('initialization', () {
      testWidgets('should render initial page', (tester) async {
        await tester.pumpWidget(TestApp(router: router));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(RouteLocation.home)), findsOneWidget);
      });
      testWidgets('should have history of one', (tester) async {
        await tester.pumpWidget(TestApp(router: router));
        expect(router.history.length, equals(1));
        expect(router.history.currentRoute.effectivePath,
            equals(RouteLocation.home));
      });
    });

    group('goTo', () {
      testWidgets('should render next page', (tester) async {
        await tester.pumpWidget(TestApp(router: router));
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.products);
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey(RouteLocation.products)), findsOneWidget);
      });

      testWidgets('should use parameters', (tester) async {
        await tester.pumpWidget(TestApp(router: router));
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.productDetails, params: {'id': '123'});
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey('${RouteLocation.productDetails}-123')),
            findsOneWidget);
      });
      testWidgets('should add to history', (tester) async {
        await tester.pumpWidget(TestApp(router: router));
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
        // 1
        await tester.pumpWidget(TestApp(router: router));
        await tester.pumpAndSettle();
        // 2
        router.goTo(RouteLocation.productDetailsComments, params: {'id': '5'});
        await tester.pumpAndSettle();
        // 3
        router.goTo('./info');

        expect(router.history.length, equals(3));
        expect(router.history.currentRoute.effectivePath,
            equals('/products/5/info'));
        expect(router.history.currentRoute.pathParams['id'], equals('5'));
      });
    });

    group('replace', () {
      testWidgets('Should render next page', (tester) async {
        await tester.pumpWidget(TestApp(router: router));
        await tester.pumpAndSettle();
        router.replace(RouteLocation.products);
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey(RouteLocation.products)), findsOneWidget);
      });
      testWidgets('should replace in history', (tester) async {
        await tester.pumpWidget(TestApp(router: router));
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
        await tester.pumpWidget(TestApp(router: router));
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.productDetails);
        await tester.pumpAndSettle();
        router.pop();
        await tester.pumpAndSettle();
        // products is above in poppableStack
        expect(
            find.byKey(const ValueKey(RouteLocation.products)), findsOneWidget);
      });
      testWidgets('should add in history', (tester) async {
        await tester.pumpWidget(TestApp(router: router));
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
        await tester.pumpWidget(TestApp(router: router));
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.products);
        await tester.pumpAndSettle();
        router.back();
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(RouteLocation.home)), findsOneWidget);
      });
      testWidgets('should remove in history', (tester) async {
        await tester.pumpWidget(TestApp(router: router));
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
        await tester.pumpWidget(TestApp(router: router));
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
        router = createTestRouter(
          resolvers: [authResolver],
        );
        await tester.pumpWidget(TestApp(router: router));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('loading-screen')), findsOneWidget);
      });

      testWidgets('should redirect if redirector state changed',
          (tester) async {
        final authResolver = MockAuthResolver();
        router = createTestRouter(
          resolvers: [authResolver],
        );
        await tester.pumpWidget(TestApp(router: router));
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
        await tester.pumpWidget(TestApp(router: router));
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

        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(router.history.length, equals(3));
        expect(router.history.currentRoute.effectivePath,
            equals('/products/id/comments'));
        expect(find.byKey(const ValueKey('${RouteLocation.productDetails}-id')),
            findsOneWidget);
        expect(find.byKey(const ValueKey(RouteLocation.productDetailsComments)),
            findsOneWidget);
        expect(find.byKey(const ValueKey(RouteLocation.productDetailsInfo)),
            findsNothing);
      });
    });
  });
}
