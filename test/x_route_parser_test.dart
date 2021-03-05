import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/parser/x_route_parser.dart';

import 'matchers.dart';

void main() {
  group('Route', () {
    test('should match exact route', () {
      final path = '/test/route';
      expect(XRouteParser(path).parse(path), isMatch());
      expect(XRouteParser('/').parse('/'), isMatch());
      expect(XRouteParser(path).parse('/'), isNotMatch());
      expect(XRouteParser(path).parse('/test/route/longer'), isNotMatch());
      expect(XRouteParser(path).parse('/not/same'), isNotMatch());
      expect(XRouteParser('/').parse('/not'), isNotMatch());
    });

    test('should match exact route with typos', () {
      expect(XRouteParser('/test/route').parse('test/route'), isMatch());
      expect(XRouteParser('/test/route').parse('test/route/'), isMatch());
      expect(XRouteParser('/test/route').parse(' /test/route/  '), isMatch());
      expect(XRouteParser('test/route').parse(' //test/route/ '), isMatch());
    });

    test('should match partial routes', () {
      final path = '/test/route';

      expect(
        XRouteParser('/').parse('/any/route', matchChildren: true),
        isMatch(),
      );

      expect(
        XRouteParser(path).parse('test/route', matchChildren: true),
        isMatch(),
      );
      expect(
        XRouteParser(path).parse('/test/route/more', matchChildren: true),
        isMatch(),
      );
      expect(
        XRouteParser(path).parse('/another/route', matchChildren: true),
        isNotMatch(),
      );
      expect(
        XRouteParser(path).parse('/', matchChildren: true),
        isNotMatch(),
      );
      expect(
        XRouteParser(path).parse('/test', matchChildren: true),
        isNotMatch(),
      );
      expect(
        XRouteParser(path).parse('test/another', matchChildren: true),
        isNotMatch(),
      );
    });

    test('should get arguments', () {
      final path = '/teams/:teamId/users/:userId';
      final params = XRouteParser(path).parse('/teams/x/users/y').parameters;
      expect(params['teamId'], equals('x'));
      expect(params['userId'], equals('y'));
      expect(params.length, equals(2));
    });

    test('result should give result of partial match path', () {
      final path = '/teams/:teamId';
      final result =
          XRouteParser(path).parse('/teams/x/users/y', matchChildren: true);
      expect(result.path, equals('/teams/x/users/y'));
      expect(result.matchingPath, equals('/teams/x'));
      expect(result.patternPath, equals('/teams/:teamId'));
    });

    test('should format silly paths to prevent typos', () {
      final path = '/test/route';
      expect(XRouteParser.sanitize('test/route'), equals(path));
      expect(XRouteParser.sanitize('test/route/'), equals(path));
      expect(XRouteParser.sanitize(' /test/route/ '), equals(path));
      expect(XRouteParser.sanitize('/test/route/'), equals(path));
      expect(XRouteParser.sanitize('test/route '), equals(path));
      expect(XRouteParser.sanitize('//test/route/'), equals(path));
      expect(XRouteParser.sanitize('/not/route'), isNot(path));
      expect(XRouteParser.sanitize(' /not/route'), isNot(path));
    });

    test('Should reverse params', () {
      final params = {'id': '3', 'otherId': '4'};
      expect(XRouteParser('/route/:id').reverse(params), equals('/route/3'));
      expect(XRouteParser('/route/:id/other/:otherId').reverse(params),
          equals('/route/3/other/4'));
      expect(XRouteParser('/route/:id/not/:not').reverse(params),
          equals('/route/3/not/:not'));
      expect(XRouteParser('/').reverse(params), equals('/'));
    });
  });
}
