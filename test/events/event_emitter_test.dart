import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/events/x_event_emitter.dart';
import 'package:x_router/src/events/x_router_events.dart';
import 'package:x_router/src/route/x_route.dart';

void main() {
  group('Router State', () {
    test('Should emit events', () async {
      XEventEmitter state = XEventEmitter.instance;
      final activatedRoute = XActivatedRoute.nulled();
      expect(
        state.eventStream,
        emitsInOrder([
          const NavigationStart(target: '', params: {}),
          NavigationEnd(activatedRoute: activatedRoute),
        ]),
      );
      state.addEvent(NavigationStart(target: '', params: {}));
      state.addEvent(NavigationEnd(activatedRoute: activatedRoute));
    });
    test('Should have the current activated route on navigation end', () {
      XRouterState state = XRouterState.instance;
      final activatedRoute = XActivatedRoute(
        route: XRoute(path: '/test', builder: (_, __) => Container()),
        requestedPath: '/test',
        effectivePath: '/test',
      );
      state.addEvent(NavigationEnd(activatedRoute: activatedRoute));
      expect(state.activatedRoute, equals(activatedRoute));
    });

    test('Should have the current url on navigation end', () {
      XRouterState state = XRouterState.instance;
      final activatedRoute = XActivatedRoute(
        route: XRoute(path: '/test', builder: (_, __) => Container()),
        requestedPath: '/test',
        effectivePath: '/test',
      );
      state.addEvent(NavigationEnd(activatedRoute: activatedRoute));
      expect(state.currentUrl, equals('/test'));
    });
  });
}
