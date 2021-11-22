import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';
import 'package:x_router/src/state/x_router_events.dart' as ev;

void main() {
  group('Event', () {
    test('Should have simple equality', () {
      final activatedRoute = XActivatedRoute.nulled();
      expect(
        ev.NavigationStart(target: 'target', params: const {'param': '1'}),
        equals(
            ev.NavigationStart(target: 'target', params: const {'param': '1'})),
      );
      expect(
        ev.NavigationEnd(activatedRoute: activatedRoute),
        equals(ev.NavigationEnd(activatedRoute: activatedRoute)),
      );
      expect(
        ev.UrlParsingStart(currentUrl: '', params: const {}, target: ''),
        equals(
            ev.UrlParsingStart(currentUrl: '', params: const {}, target: '')),
      );
      expect(
        ev.UrlParsingEnd(target: ''),
        equals(ev.UrlParsingEnd(target: '')),
      );

      expect(
        ev.ResolvingStart(target: ''),
        equals(ev.ResolvingStart(target: '')),
      );
      expect(
        ev.ResolvingEnd(XRouterResolveResult(origin: '', target: '')),
        equals(ev.ResolvingEnd(XRouterResolveResult(origin: '', target: ''))),
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
