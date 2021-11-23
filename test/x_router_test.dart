import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/x_router.dart';

import 'mock_app.dart';

void main() {
  group('XRouter', () {
    setUp(() {
      XRouter.history.clear();
    });
    group('initialization', () {
      testWidgets('should render initial page', (tester) async {
        await tester.pumpWidget(MockApp(resolvers: const []));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(AppRoutes.home)), findsOneWidget);
      });
      testWidgets('should have history of one', (tester) async {
        await tester.pumpWidget(MockApp(resolvers: const []));
        await tester.pumpAndSettle();
        expect(XRouter.history.length, equals(1));
        expect(
            XRouter.history.currentRoute.effectivePath, equals(AppRoutes.home));
      });
    });

    group('goTo', () {
      testWidgets('should render next page', (tester) async {
        await tester.pumpWidget(MockApp(resolvers: const []));
        await tester.pumpAndSettle();
        XRouter.goTo(AppRoutes.products);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(AppRoutes.products)), findsOneWidget);
      });

      testWidgets('should use parameters', (tester) async {
        await tester.pumpWidget(MockApp(resolvers: const []));
        await tester.pumpAndSettle();
        XRouter.goTo(AppRoutes.productDetail, params: {'id': '123'});
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('${AppRoutes.productDetail}-123')),
            findsOneWidget);
      });
      testWidgets('should add to history', (tester) async {
        await tester.pumpWidget(MockApp(resolvers: const []));
        await tester.pumpAndSettle();
        XRouter.goTo(AppRoutes.products);
        await tester.pumpAndSettle();
        expect(XRouter.history.length, equals(2));
        expect(XRouter.history.currentRoute.effectivePath,
            equals(AppRoutes.products));
        expect(XRouter.history.previousRoute?.effectivePath,
            equals(AppRoutes.home));
      });
    });
    group('replace', () {
      testWidgets('Should render next page', (tester) async {
        await tester.pumpWidget(MockApp(resolvers: const []));
        await tester.pumpAndSettle();
        XRouter.replace(AppRoutes.products);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(AppRoutes.products)), findsOneWidget);
      });
      testWidgets('should replace in history', (tester) async {
        await tester.pumpWidget(MockApp(resolvers: const []));
        await tester.pumpAndSettle();
        XRouter.replace(AppRoutes.products);
        await tester.pumpAndSettle();
        expect(XRouter.history.length, equals(1));
        expect(XRouter.history.currentRoute.effectivePath,
            equals(AppRoutes.products));
      });
    });

    group('pop', () {
      testWidgets('Should render next page', (tester) async {
        await tester.pumpWidget(MockApp(resolvers: const []));
        await tester.pumpAndSettle();
        XRouter.goTo(AppRoutes.productDetail);
        await tester.pumpAndSettle();
        XRouter.pop();
        await tester.pumpAndSettle();
        // products is above in upstack
        expect(find.byKey(const ValueKey(AppRoutes.products)), findsOneWidget);
      });
      testWidgets('should add in history', (tester) async {
        await tester.pumpWidget(MockApp(resolvers: const []));
        await tester.pumpAndSettle();
        XRouter.goTo(AppRoutes.products);
        await tester.pumpAndSettle();
        XRouter.pop();
        await tester.pumpAndSettle();
        expect(XRouter.history.length, equals(3));
        expect(
            XRouter.history.currentRoute.effectivePath, equals(AppRoutes.home));
      });
    });

    group('back', () {
      testWidgets('Should render next page', (tester) async {
        await tester.pumpWidget(MockApp(resolvers: const []));
        await tester.pumpAndSettle();
        XRouter.goTo(AppRoutes.products);
        await tester.pumpAndSettle();
        XRouter.back();
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(AppRoutes.home)), findsOneWidget);
      });
      testWidgets('should remove in history', (tester) async {
        await tester.pumpWidget(MockApp(resolvers: const []));
        await tester.pumpAndSettle();
        XRouter.goTo(AppRoutes.products);
        await tester.pumpAndSettle();
        XRouter.back();
        await tester.pumpAndSettle();
        expect(XRouter.history.length, equals(1));
        expect(
            XRouter.history.currentRoute.effectivePath, equals(AppRoutes.home));
      });
    });

    group('refresh', () {
      testWidgets('should stay on current route if no redirection',
          (tester) async {
        await tester.pumpWidget(MockApp(resolvers: const []));
        await tester.pumpAndSettle();
        XRouter.goTo(AppRoutes.products);
        await tester.pumpAndSettle();
        XRouter.refresh();
        await tester.pumpAndSettle();
        expect(XRouter.history.currentRoute.effectivePath,
            equals(AppRoutes.products));
      });

      testWidgets('history does not increase', (tester) async {
        await tester.pumpWidget(MockApp(resolvers: const []));
        await tester.pumpAndSettle();
        XRouter.goTo(AppRoutes.products);
        await tester.pumpAndSettle();
        expect(XRouter.history.length, equals(2));
        XRouter.refresh();
        await tester.pumpAndSettle();
        expect(XRouter.history.length, equals(2));
      });
    });

    group('resolvers', () {
      testWidgets('Should render with redirect', (tester) async {
        await tester.pumpWidget(MockApp(
          resolvers: [
            XRedirectResolver(from: AppRoutes.home, to: AppRoutes.products)
          ],
        ));
        await tester.pumpAndSettle();
        expect(XRouter.history.length, equals(2));
        expect(XRouter.history.currentRoute.effectivePath,
            equals(AppRoutes.products));
      });

      testWidgets('Should display loading if resolver is not ready',
          (tester) async {
        await tester.pumpWidget(MockApp(
          resolvers: [MockAuthResolver()],
        ));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('loading-screen')), findsOneWidget);
      });

      testWidgets('should redirect after refresh if redirector state changed',
          (tester) async {
        final authResolver = MockAuthResolver();
        await tester.pumpWidget(MockApp(
          resolvers: [authResolver],
        ));
        await tester.pumpAndSettle();
        authResolver.signIn();
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('loading-screen')), findsNothing);
        expect(find.byKey(const ValueKey(AppRoutes.home)), findsOneWidget);
        expect(find.byKey(const ValueKey(AppRoutes.signIn)), findsNothing);

        authResolver.signOut();
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(AppRoutes.signIn)), findsOneWidget);
      });
    });
  });
}
