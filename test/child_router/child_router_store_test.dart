import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/child_router/x_child_router_store.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/exceptions/x_router_exception.dart';
import 'package:x_router/src/route/x_route.dart';

void main() {
  group('XChildRouterStore', () {
    final store = XChildRouterStore.fromRootRoutes(
      [
        XRoute(path: '/not_parent', builder: (_, __) => Container()),
        XRoute(
          path: '/parent',
          builder: (_, __) => Container(),
          children: [
            XRoute(
              path: '/parent/child',
              builder: (_, __) => Container(),
            )
          ],
        ),
      ],
    );

    group('findDelegates', () {
      test('should find router delegates', () {
        expect(store.findChild('/parent'), isA<XRouterDelegate>());
      });

      test('should throw when none is found', () {
        expect(() => store.findChild('/not_parent'),
            throwsA(isA<XRouterException>()));
        expect(
            () => store.findChild('/child'), throwsA(isA<XRouterException>()));
        expect(() => store.findChild('/parent/child'),
            throwsA(isA<XRouterException>()));
      });
    });
  });
}
