import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/x_router.dart';

import 'mock_app.dart';

void main() {
  group('router', () {
    late XRouter router;

    setUp(() => router = getTestRouter());
    group('initialization', () {
      testWidgets('should render initial page', (tester) async {
        await tester.pumpWidget(TestApp(router));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(RouteLocation.home)), findsOneWidget);
      });
      testWidgets('should have history of one', (tester) async {
        await tester.pumpWidget(TestApp(router));
        expect(router.history.length, equals(1));
        expect(router.history.currentRoute.effectivePath,
            equals(RouteLocation.home));
      });
    });

    group('goTo', () {
      testWidgets('should render next page', (tester) async {
        await tester.pumpWidget(TestApp(router));
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.products);
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey(RouteLocation.products)), findsOneWidget);
      });

      testWidgets('should use parameters', (tester) async {
        await tester.pumpWidget(TestApp(router));
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.productDetail, params: {'id': '123'});
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('${RouteLocation.productDetail}-123')),
            findsOneWidget);
      });
      testWidgets('should add to history', (tester) async {
        await tester.pumpWidget(TestApp(router));
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.products);
        await tester.pumpAndSettle();
        expect(router.history.length, equals(2));
        expect(router.history.currentRoute.effectivePath,
            equals(RouteLocation.products));
        expect(router.history.previousRoute?.effectivePath,
            equals(RouteLocation.home));
      });
    });
    group('replace', () {
      testWidgets('Should render next page', (tester) async {
        await tester.pumpWidget(TestApp(router));
        await tester.pumpAndSettle();
        router.replace(RouteLocation.products);
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey(RouteLocation.products)), findsOneWidget);
      });
      testWidgets('should replace in history', (tester) async {
        await tester.pumpWidget(TestApp(router));
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
        await tester.pumpWidget(TestApp(router));
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.productDetail);
        await tester.pumpAndSettle();
        router.pop();
        await tester.pumpAndSettle();
        // products is above in upstack
        expect(
            find.byKey(const ValueKey(RouteLocation.products)), findsOneWidget);
      });
      testWidgets('should add in history', (tester) async {
        await tester.pumpWidget(TestApp(router));
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
        await tester.pumpWidget(TestApp(router));
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.products);
        await tester.pumpAndSettle();
        router.back();
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(RouteLocation.home)), findsOneWidget);
      });
      testWidgets('should remove in history', (tester) async {
        await tester.pumpWidget(TestApp(router));
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
        await tester.pumpWidget(TestApp(router));
        await tester.pumpAndSettle();
        router.goTo(RouteLocation.products);
        await tester.pumpAndSettle();
        router.refresh();
        await tester.pumpAndSettle();
        expect(router.history.currentRoute.effectivePath,
            equals(RouteLocation.products));
      });

      testWidgets('history does not increase', (tester) async {
        await tester.pumpWidget(TestApp(router));
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
        final router = getTestRouter(
          resolvers: [
            XRedirectResolver(
                from: RouteLocation.home, to: RouteLocation.products),
            XRedirectResolver(
                from: RouteLocation.preferences, to: RouteLocation.home),
          ],
        );
        await tester.pumpWidget(TestApp(router));
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
        final router = getTestRouter(
          resolvers: [MockAuthResolver()],
        );
        await tester.pumpWidget(TestApp(router));

        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('loading-screen')), findsOneWidget);
      });

      testWidgets('should redirect after refresh if redirector state changed',
          (tester) async {
        final authResolver = MockAuthResolver();
        final router = getTestRouter(
          resolvers: [authResolver],
        );
        await tester.pumpWidget(TestApp(router));

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
    });
  });
}
