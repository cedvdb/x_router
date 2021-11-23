import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/events/x_event_emitter.dart';
import 'package:x_router/src/events/x_router_events.dart';

void main() {
  group('Event emitter', () {
    test('Should emit events', () async {
      XEventEmitter state = XEventEmitter.instance;
      final activatedRoute = XActivatedRoute.nulled();
      expect(
        state.eventStream,
        emitsInOrder([
          const NavigationStart(target: '', params: {}),
          NavigationEnd(activatedRoute: activatedRoute, target: ''),
        ]),
      );
      state.addEvent(const NavigationStart(target: '', params: {}));
      state.addEvent(NavigationEnd(activatedRoute: activatedRoute, target: ''));
    });
  });
}
