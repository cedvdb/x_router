import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/navigated_route/x_navigated_route.dart';
import 'package:x_router/src/history/router_history.dart';
import 'package:x_router/x_router.dart';

void main() {
  group('Router history', () {
    late XRouterHistory history;

    setUp(() => history = XRouterHistory());

    test('should add', () {
      history.add(XNavigatedRoute.forPath('/home'));
      expect(history.length, equals(1));
      history.add(XNavigatedRoute.forPath('/preferences'));
      expect(history.length, equals(2));
      history.add(XNavigatedRoute.forPath('/products'));
      expect(history.length, equals(3));
    });

    test('should not add if same as previous route', () {
      history.add(XNavigatedRoute.forPath('/home'));
      expect(history.length, equals(1));
      history.add(XNavigatedRoute.forPath('/home'));
      expect(history.length, equals(1));
      history.add(XNavigatedRoute.forPath('/home'));
      expect(history.length, equals(1));
      // only the effective path matters
      history.add(
        XNavigatedRoute(
          route: XRoute(path: '', builder: (_, __) => Container()),
          requestedPath: '/path/to/resource/with-gibberish-end',
          matchingPath: '/path',
          effectivePath: '/path/to/resource',
        ),
      );
      expect(history.length, equals(2));
      history.add(
        XNavigatedRoute(
          route: XRoute(path: '', builder: (_, __) => Container()),
          requestedPath: '/path/to/resource',
          matchingPath: '/path/to',
          effectivePath: '/path/to/resource',
        ),
      );
      expect(history.length, equals(2));
    });

    test('should remove from', () {
      history.add(XNavigatedRoute.forPath('/home'));
      history.add(XNavigatedRoute.forPath('/products'));
      history.add(XNavigatedRoute.forPath('/preferences'));
      history.add(XNavigatedRoute.forPath('/settings'));
      expect(history.length, equals(4));
      history.removeThrough(history.currentRoute);
      expect(history.currentRoute.matchingPath, equals('/preferences'));
      // history.removeFrom(history.currentRoute);
      // expect(history.currentRoute.effectivePath, equals('/home'));
    });

    test('should tell if it has previous route', () {
      expect(history.hasPreviousRoute, isFalse);
      history.add(XNavigatedRoute.forPath('/home'));
      expect(history.hasPreviousRoute, isFalse);
      history.add(XNavigatedRoute.forPath('/products'));
      expect(history.hasPreviousRoute, isTrue);
    });
  });
}
