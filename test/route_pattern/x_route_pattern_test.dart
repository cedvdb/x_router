import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/route_pattern/x_route_pattern.dart';

import 'matchers.dart';

void main() {
  group('Route Pattern', () {
    test('should format silly paths to prevent typos', () {
      const pattern = '/test/route';
      expect(XRoutePattern('test/route').path, equals(pattern));
      expect(XRoutePattern('test/route/').path, equals(pattern));
      expect(XRoutePattern(' /test/route/ ').path, equals(pattern));
      expect(XRoutePattern('/test/route/').path, equals(pattern));
      expect(XRoutePattern('test/route ').path, equals(pattern));
      expect(XRoutePattern('//test/route/').path, equals(pattern));
      expect(XRoutePattern('/not/route').path, isNot(pattern));
      expect(XRoutePattern(' /not/route').path, isNot(pattern));
    });

    test('should create path with relative url', () {
      expect(XRoutePattern.maybeRelative('./rel', '/home/route/third').path,
          equals('/home/route/rel'));
      expect(XRoutePattern.maybeRelative('../rel', '/home/route/third').path,
          equals('/home/rel'));
      expect(XRoutePattern.maybeRelative('../../rel', '/home/route/third').path,
          equals('/rel'));
      expect(XRoutePattern.maybeRelative('/rel', '/home/route').path,
          equals('/rel'));
      expect(
          XRoutePattern.maybeRelative('./rel', '/home').path, equals('/rel'));
    });

    group('parse', () {
      test('should match exact route', () {
        const pattern = '/test/route';
        expect(XRoutePattern(pattern).parse(pattern), const IsMatch());
        expect(XRoutePattern('/').parse('/'), const IsMatch());
        expect(XRoutePattern(pattern).parse('/'), const IsNotMatch());
        expect(XRoutePattern(pattern).parse('/test/route/longer'),
            const IsNotMatch());
        expect(XRoutePattern(pattern).parse('/not/same'), const IsNotMatch());
        expect(XRoutePattern('/').parse('/not'), const IsNotMatch());
      });

      test('should match exact route with typos', () {
        expect(
            XRoutePattern('/test/route').parse('test/route'), const IsMatch());
        expect(
            XRoutePattern('/test/route').parse('test/route/'), const IsMatch());
        expect(XRoutePattern('/test/route').parse(' /test/route/  '),
            const IsMatch());
        expect(XRoutePattern('test/route').parse(' //test/route/ '),
            const IsMatch());
      });

      test('should match children', () {
        const pattern = '/test/route';

        expect(
          XRoutePattern('/').parse('/any/route', matchChildren: true),
          const IsMatch(),
        );

        expect(
          XRoutePattern(pattern).parse('test/route', matchChildren: true),
          const IsMatch(),
        );
        expect(
          XRoutePattern(pattern).parse('/test/route/more', matchChildren: true),
          const IsMatch(),
        );
        expect(
          XRoutePattern(pattern).parse('/another/route', matchChildren: true),
          const IsNotMatch(),
        );
        expect(
          XRoutePattern(pattern).parse('/', matchChildren: true),
          const IsNotMatch(),
        );
        expect(
          XRoutePattern(pattern).parse('/test', matchChildren: true),
          const IsNotMatch(),
        );
        expect(
          XRoutePattern(pattern).parse('test/another', matchChildren: true),
          const IsNotMatch(),
        );
      });

      test('should generate path parameters', () {
        const pattern = '/teams/:teamId/users/:userId';
        final params =
            XRoutePattern(pattern).parse('/teams/x/users/y').pathParameters;
        expect(params['teamId'], equals('x'));
        expect(params['userId'], equals('y'));
        expect(params.length, equals(2));
      });

      test('should generate query parameters', () {
        const pattern = '/teams/:teamId/users/:userId';
        final params = XRoutePattern(pattern)
            .parse('/teams/x/users/y?sortBy=creationDate')
            .queryParameters;
        expect(params['sortBy'], equals('creationDate'));
        expect(params.length, equals(1));
      });

      test('result should give result of partial match path', () {
        const pattern = '/teams/:teamId';
        final result = XRoutePattern(pattern)
            .parse('/teams/x/users/y', matchChildren: true);
        expect(result.path, equals('/teams/x/users/y'));
        expect(result.matchingPath, equals('/teams/x'));
        expect(result.patternPath, equals('/teams/:teamId'));
        expect(result.matches, equals(true));
      });

      test('result should give result matching path for incomplete paths', () {
        const pattern = '/teams/:teamId';
        final result =
            XRoutePattern(pattern).parse('/teams', matchChildren: true);
        expect(result.path, equals('/teams'));
        expect(result.matchingPath, equals('/teams'));
        expect(result.patternPath, equals('/teams/:teamId'));
        expect(result.matches, equals(false));
      });
    });

    test('Should be a match despite query params', () {
      expect(XRoutePattern('/test').parse('/test?sort=creationDate'),
          const IsMatch());
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
