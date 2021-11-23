import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';
import 'package:x_router/src/events/x_router_events.dart' as ev;

void main() {
  group('Event', () {
    test('Should have simple equality', () {
      final activatedRoute = XActivatedRoute.nulled();
      expect(
        const ev.NavigationStart(
          target: 'target',
          params: {'param': '1'},
        ),
        equals(
          const ev.NavigationStart(
            target: 'target',
            params: {'param': '1'},
          ),
        ),
      );
      expect(
        ev.NavigationEnd(activatedRoute: activatedRoute, target: ''),
        equals(ev.NavigationEnd(activatedRoute: activatedRoute, target: '')),
      );
      expect(
        const ev.UrlParsingStart(params: {}, target: ''),
        equals(const ev.UrlParsingStart(params: {}, target: '')),
      );
      expect(
        const ev.UrlParsingEnd(target: '', parsed: ''),
        equals(const ev.UrlParsingEnd(target: '', parsed: '')),
      );

      expect(
        const ev.ResolvingStart(target: ''),
        equals(const ev.ResolvingStart(target: '')),
      );
      expect(
        const ev.ResolvingEnd(
            result: XRouterResolveResult(target: ''), target: ''),
        equals(const ev.ResolvingEnd(
            result: XRouterResolveResult(target: ''), target: '')),
      );
    });
  });
}
