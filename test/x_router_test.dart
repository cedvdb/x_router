import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/x_router.dart';

import 'mock_app.dart';

void main() {
  group('XRouter', () {
    testWidgets('Should render initial page', (tester) async {
      await tester.pumpWidget(MockApp(resolvers: const []));
      // await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey(AppRoutes.home)), findsOneWidget);
    });
    group('goTo', () {});
    group('replace', () {});

    group('pop', () {});

    group('back', () {});

    group('redirects', () {});
  });
}
