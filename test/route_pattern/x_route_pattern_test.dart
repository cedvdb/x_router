import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/route_pattern/x_route_pattern.dart';

import '../matchers.dart';

void main() {
  group('Route', () {
    test('should format silly paths to prevent typos', () {
      const path = '/test/route';
      expect(XRoutePattern('test/route').path, equals(path));
      expect(XRoutePattern('test/route/').path, equals(path));
      expect(XRoutePattern(' /test/route/ ').path, equals(path));
      expect(XRoutePattern('/test/route/').path, equals(path));
      expect(XRoutePattern('test/route ').path, equals(path));
      expect(XRoutePattern('//test/route/').path, equals(path));
      expect(XRoutePattern('/not/route').path, isNot(path));
      expect(XRoutePattern(' /not/route').path, isNot(path));
    });

    test('should create path with relative url', () {
      expect(XRoutePattern.maybeRelative('./rel', '/home/route').path,
          equals('/home/rel'));
      expect(XRoutePattern.maybeRelative('./rel', 'home/route').path,
          equals('/home/rel'));
      expect(XRoutePattern.maybeRelative('/rel', '/home/route').path,
          equals('/rel'));
      expect(
          XRoutePattern.maybeRelative('./rel', '/home').path, equals('/rel'));
    });

    test('should match exact route', () {
      const path = '/test/route';
      expect(XRoutePattern(path).parse(path), const IsMatch());
      expect(XRoutePattern('/').parse('/'), const IsMatch());
      expect(XRoutePattern(path).parse('/'), const IsNotMatch());
      expect(
          XRoutePattern(path).parse('/test/route/longer'), const IsNotMatch());
      expect(XRoutePattern(path).parse('/not/same'), const IsNotMatch());
      expect(XRoutePattern('/').parse('/not'), const IsNotMatch());
    });

    test('should match exact route with typos', () {
      expect(XRoutePattern('/test/route').parse('test/route'), const IsMatch());
      expect(
          XRoutePattern('/test/route').parse('test/route/'), const IsMatch());
      expect(XRoutePattern('/test/route').parse(' /test/route/  '),
          const IsMatch());
      expect(XRoutePattern('test/route').parse(' //test/route/ '),
          const IsMatch());
    });

    test('should match children', () {
      const path = '/test/route';

      expect(
        XRoutePattern('/').parse('/any/route', matchChildren: true),
        const IsMatch(),
      );

      expect(
        XRoutePattern(path).parse('test/route', matchChildren: true),
        const IsMatch(),
      );
      expect(
        XRoutePattern(path).parse('/test/route/more', matchChildren: true),
        const IsMatch(),
      );
      expect(
        XRoutePattern(path).parse('/another/route', matchChildren: true),
        const IsNotMatch(),
      );
      expect(
        XRoutePattern(path).parse('/', matchChildren: true),
        const IsNotMatch(),
      );
      expect(
        XRoutePattern(path).parse('/test', matchChildren: true),
        const IsNotMatch(),
      );
      expect(
        XRoutePattern(path).parse('test/another', matchChildren: true),
        const IsNotMatch(),
      );
    });

    test('should get arguments', () {
      const path = '/teams/:teamId/users/:userId';
      final params = XRoutePattern(path).parse('/teams/x/users/y').parameters;
      expect(params['teamId'], equals('x'));
      expect(params['userId'], equals('y'));
      expect(params.length, equals(2));
    });

    test('result should give result of partial match path', () {
      const path = '/teams/:teamId';
      final result =
          XRoutePattern(path).parse('/teams/x/users/y', matchChildren: true);
      expect(result.path, equals('/teams/x/users/y'));
      expect(result.matchingPath, equals('/teams/x'));
      expect(result.patternPath, equals('/teams/:teamId'));
    });

    test('Should reverse params', () {
      const params = {'id': '3', 'otherId': '4'};
      expect(XRoutePattern('/route/:id').addParameters(params),
          equals('/route/3'));
      expect(XRoutePattern('/route/:id/other/:otherId').addParameters(params),
          equals('/route/3/other/4'));
      expect(XRoutePattern('/route/:id/not/:not').addParameters(params),
          equals('/route/3/not/:not'));
      expect(XRoutePattern('/').addParameters(params), equals('/'));
    });
  });
}
