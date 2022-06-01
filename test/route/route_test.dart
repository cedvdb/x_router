import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/x_router.dart';

void main() {
  group('XRoute', () {
    test('should compute effective path', () {
      final route = XRoute(
        path: '/parent',
        builder: (_, __) => Container(),
        children: [
          XRoute(
            path: '/parent/child',
            builder: (_, __) => Container(),
          )
        ],
      );
      expect(
        route.computeDeepestMatchingPath('/parent'),
        equals('/parent'),
      );
      expect(
        route.computeDeepestMatchingPath('/parent/not_route'),
        equals('/parent'),
      );
      expect(
        route.computeDeepestMatchingPath('/parent/child'),
        equals('/parent/child'),
      );
      expect(
        route.computeDeepestMatchingPath('/parent/child/not_route'),
        equals('/parent/child'),
      );
    });
  });
}
