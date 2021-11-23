import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/history/router_history.dart';

void main() {
  group('Router history', () {
    late XRouterHistory history;

    setUp(() => history = XRouterHistory());

    test('should add', () {
      history.add(XActivatedRoute.forPath('/home'));
      expect(history.length, equals(1));
      history.add(XActivatedRoute.forPath('/preferences'));
      expect(history.length, equals(2));
      history.add(XActivatedRoute.forPath('/products'));
      expect(history.length, equals(3));
    });

    test('should not add if same as previous route', () {
      history.add(XActivatedRoute.forPath('/home'));
      expect(history.length, equals(1));
      history.add(XActivatedRoute.forPath('/home'));
      expect(history.length, equals(1));
      history.add(XActivatedRoute.forPath('/home'));
      expect(history.length, equals(1));
    });

    test('should remove from', () {
      history.add(XActivatedRoute.forPath('/home'));
      history.add(XActivatedRoute.forPath('/products'));
      history.add(XActivatedRoute.forPath('/preferences'));
      history.add(XActivatedRoute.forPath('/settings'));
      expect(history.length, equals(4));
      history.removeFrom(history.currentRoute);
      expect(history.currentRoute.effectivePath, equals('/preferences'));
      // history.removeFrom(history.currentRoute);
      // expect(history.currentRoute.effectivePath, equals('/home'));
    });

    test('should tell if it has previous route', () {
      expect(history.hasPreviousRoute, isFalse);
      history.add(XActivatedRoute.forPath('/home'));
      expect(history.hasPreviousRoute, isFalse);
      history.add(XActivatedRoute.forPath('/products'));
      expect(history.hasPreviousRoute, isTrue);
    });
  });
}
