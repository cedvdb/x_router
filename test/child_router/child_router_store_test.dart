import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/child_router/x_child_router_store.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/route/x_children_routes.dart';
import 'package:x_router/src/route/x_route.dart';

void main() {
  group('XChildRouterStore', () {
    test('router delegates should be findable', () {
      final store = XChildRouterStore(
        routes: [
          XRoute(path: '/not_parent', builder: (_, __) => Container()),
          XRoute(
            path: '/parent',
            builder: (_, __) => Container(),
            childRouterConfig: XChildRouterConfig(
              routes: [
                XRoute(
                  path: '/parent/child',
                  builder: (_, __) => Container(),
                )
              ],
            ),
          ),
        ],
      );
      expect(store.findDelegate('/parent'), isA<XRouterDelegate>());
      expect(() => store.findDelegate('/not_parent'), throwsException);
      expect(() => store.findDelegate('/child'), throwsException);
      expect(() => store.findDelegate('/parent/child'), throwsException);
    });
  });
}
