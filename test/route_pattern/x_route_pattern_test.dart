import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/route_pattern/route_pattern.dart';

import 'matchers.dart';

void main() {
  group('Route Pattern', () {
    test('should format silly paths to prevent typos', () {
      const pattern = '/test/route';
      expect(RoutePattern('test/route').path, equals(pattern));
      expect(RoutePattern('test/route/').path, equals(pattern));
      expect(RoutePattern(' /test/route/ ').path, equals(pattern));
      expect(RoutePattern('/test/route/').path, equals(pattern));
      expect(RoutePattern('test/route ').path, equals(pattern));
      expect(RoutePattern('//test/route/').path, equals(pattern));
      expect(RoutePattern('/not/route').path, isNot(pattern));
      expect(RoutePattern(' /not/route').path, isNot(pattern));
    });

    test('should create path with relative url', () {
      expect(RoutePattern.maybeRelative('./rel', '/home/route/third').path,
          equals('/home/route/rel'));
      expect(RoutePattern.maybeRelative('../rel', '/home/route/third').path,
          equals('/home/rel'));
      expect(RoutePattern.maybeRelative('../../rel', '/home/route/third').path,
          equals('/rel'));
      expect(RoutePattern.maybeRelative('/rel', '/home/route').path,
          equals('/rel'));
      expect(RoutePattern.maybeRelative('./rel', '/home').path, equals('/rel'));
    });

    group('parse', () {
      test('should match exact route', () {
        const pattern = '/test/route';
        expect(RoutePattern(pattern).parse(pattern), const IsMatch());
        expect(RoutePattern('/').parse('/'), const IsMatch());
        expect(RoutePattern(pattern).parse('/'), const IsNotMatch());
        expect(RoutePattern(pattern).parse('/test/route/longer'),
            const IsNotMatch());
        expect(RoutePattern(pattern).parse('/not/same'), const IsNotMatch());
        expect(RoutePattern('/').parse('/not'), const IsNotMatch());
      });

      test('should match exact route with typos', () {
        expect(
            RoutePattern('/test/route').parse('test/route'), const IsMatch());
        expect(
            RoutePattern('/test/route').parse('test/route/'), const IsMatch());
        expect(RoutePattern('/test/route').parse(' /test/route/  '),
            const IsMatch());
        expect(RoutePattern('test/route').parse(' //test/route/ '),
            const IsMatch());
      });

      test('should match children', () {
        const pattern = '/test/route';

        expect(
          RoutePattern('/').parse('/any/route', matchChildren: true),
          const IsMatch(),
        );

        expect(
          RoutePattern(pattern).parse('test/route', matchChildren: true),
          const IsMatch(),
        );
        expect(
          RoutePattern(pattern).parse('/test/route/more', matchChildren: true),
          const IsMatch(),
        );
        expect(
          RoutePattern(pattern).parse('/another/route', matchChildren: true),
          const IsNotMatch(),
        );
        expect(
          RoutePattern(pattern).parse('/', matchChildren: true),
          const IsNotMatch(),
        );
        expect(
          RoutePattern(pattern).parse('/test', matchChildren: true),
          const IsNotMatch(),
        );
        expect(
          RoutePattern(pattern).parse('test/another', matchChildren: true),
          const IsNotMatch(),
        );
      });

      test('should generate path parameters', () {
        const pattern = '/teams/:teamId/users/:userId';
        final params =
            RoutePattern(pattern).parse('/teams/x/users/y').pathParameters;
        expect(params['teamId'], equals('x'));
        expect(params['userId'], equals('y'));
        expect(params.length, equals(2));
      });

      test('should generate query parameters', () {
        const pattern = '/teams/:teamId/users/:userId';
        final params = RoutePattern(pattern)
            .parse('/teams/x/users/y?sortBy=creationDate')
            .queryParameters;
        expect(params['sortBy'], equals('creationDate'));
        expect(params.length, equals(1));
      });

      test('result should give result of partial match path', () {
        const pattern = '/teams/:teamId';
        final result = RoutePattern(pattern)
            .parse('/teams/x/users/y', matchChildren: true);
        expect(result.path, equals('/teams/x/users/y'));
        expect(result.matchingPath, equals('/teams/x'));
        expect(result.patternPath, equals('/teams/:teamId'));
        expect(result.matches, equals(true));
      });

      test('result should give result matching path for incomplete paths', () {
        const pattern = '/teams/:teamId';
        final result =
            RoutePattern(pattern).parse('/teams', matchChildren: true);
        expect(result.path, equals('/teams'));
        expect(result.matchingPath, equals('/teams'));
        expect(result.patternPath, equals('/teams/:teamId'));
        expect(result.matches, equals(false));
      });
    });

    test('Should be a match despite query params', () {
      expect(RoutePattern('/test').parse('/test?sort=creationDate'),
          const IsMatch());
    });

    test('Should reverse params', () {
      const params = {'id': '3', 'otherId': '4'};
      expect(
          RoutePattern('/route/:id').addParameters(params), equals('/route/3'));
      expect(RoutePattern('/route/:id/other/:otherId').addParameters(params),
          equals('/route/3/other/4'));
      expect(RoutePattern('/route/:id/not/:not').addParameters(params),
          equals('/route/3/not/:not'));
      expect(RoutePattern('/').addParameters(params), equals('/'));
    });
  });
}
