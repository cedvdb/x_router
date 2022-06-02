import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/exceptions/x_router_exception.dart';
import 'package:x_router/src/router/base_router.dart';
import 'package:x_router/src/router/x_child_router_store.dart';
import 'package:x_router/x_router.dart';

void main() {
  group('XChildRouterStore', () {
    final store = XChildRouterStore.forParent(
      XRouter(
        routes: [
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
      ),
    );

    group('findDelegates', () {
      test('should find child router', () {
        expect(store.findChild('/parent'), isA<BaseRouter>());
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
