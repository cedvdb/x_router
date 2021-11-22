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

    test('should replace last', () {
      history.add(XActivatedRoute.forPath('/home'));
      expect(history.length, equals(1));
      history.replaceLast(XActivatedRoute.forPath('/products'));
      expect(history.length, equals(1));
      expect(history.currentRoute?.effectivePath, equals('/products'));
    });

    test('should remove last', () {
      history.add(XActivatedRoute.forPath('/home'));
      expect(history.length, equals(1));
      history.add(XActivatedRoute.forPath('/products'));
      expect(history.length, equals(2));
      history.removeLast();
      expect(history.length, equals(1));
      expect(history.currentRoute?.effectivePath, equals('/home'));
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
