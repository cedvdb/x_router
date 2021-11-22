import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';
import 'package:x_router/src/state/x_router_events.dart' as ev;

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
        const ev.NavigationBackStart(
          target: 'target',
          params: {'param': '1'},
        ),
        equals(
          const ev.NavigationBackStart(
            target: 'target',
            params: {'param': '1'},
          ),
        ),
      );

      expect(
        const ev.NavigationReplaceStart(
          target: 'target',
          params: {'param': '1'},
        ),
        equals(
          const ev.NavigationReplaceStart(
            target: 'target',
            params: {'param': '1'},
          ),
        ),
      );
      expect(
        ev.NavigationEnd(activatedRoute: activatedRoute),
        equals(ev.NavigationEnd(activatedRoute: activatedRoute)),
      );
      expect(
        const ev.UrlParsingStart(currentUrl: '', params: {}, target: ''),
        equals(
            const ev.UrlParsingStart(currentUrl: '', params: {}, target: '')),
      );
      expect(
        const ev.UrlParsingEnd(target: ''),
        equals(const ev.UrlParsingEnd(target: '')),
      );

      expect(
        const ev.ResolvingStart(target: ''),
        equals(const ev.ResolvingStart(target: '')),
      );
      expect(
        ev.ResolvingEnd(const XRouterResolveResult(origin: '', target: '')),
        equals(ev.ResolvingEnd(
            const XRouterResolveResult(origin: '', target: ''))),
      );

      expect(
        ev.BuildStart(target: ''),
        equals(ev.BuildStart(target: '')),
      );
      expect(
        ev.BuildEnd(activatedRoute: activatedRoute, target: ''),
        equals(
          ev.BuildEnd(activatedRoute: activatedRoute, target: ''),
        ),
      );
    });
  });
}
