import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/history/router_history.dart';

void main() {
  group('Router history', () {
    late XRouterHistory history;
    XActivatedRoute mockRoute = XActivatedRoute.nulled();

    setUp(() => history = XRouterHistory());

    test('should add', () {
      history.add(mockRoute);
      expect(history.length, equals(1));
      history.add(mockRoute);
      expect(history.length, equals(2));
      history.add(mockRoute);
      expect(history.length, equals(3));
    });

    test('should replace last', () {
      history.add(mockRoute);
      expect(history.length, equals(1));
      history.replaceLast(mockRoute);
      expect(history.length, equals(1));
      history.replaceLast(mockRoute);
      expect(history.length, equals(1));
    });

    test('should remove last', () {
      history.add(mockRoute);
      expect(history.length, equals(1));
      history.add(mockRoute);
      expect(history.length, equals(2));
      history.removeLast();
      expect(history.length, equals(1));
    });
  });
}
