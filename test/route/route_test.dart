import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/x_router.dart';

void main() {
  group('XRoute', () {
    test('should compute effective path', () {
      final route = XRoute(
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
      );
      expect(
        route.computeEffectivePath('/parent'),
        equals('/parent'),
      );
      expect(
        route.computeEffectivePath('/parent/not_route'),
        equals('/parent'),
      );
      expect(
        route.computeEffectivePath('/parent/child'),
        equals('/parent/child'),
      );
      expect(
        route.computeEffectivePath('/parent/child/not_route'),
        equals('/parent/child'),
      );
    });
  });
}
