import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/events/x_event_emitter.dart';
import 'package:x_router/src/events/x_router_events.dart';

void main() {
  group('Event emitter', () {
    test('Should emit events', () async {
      XEventEmitter emitter = XEventEmitter();
      final activatedRoute = XActivatedRoute.nulled();
      expect(
        emitter.eventStream,
        emitsInOrder([
          const NavigationStart(target: '', params: {}),
          NavigationEnd(
              activatedRoute: activatedRoute,
              target: '',
              previous: activatedRoute),
        ]),
      );
      emitter.addEvent(const NavigationStart(target: '', params: {}));
      emitter.addEvent(NavigationEnd(
          activatedRoute: activatedRoute,
          target: '',
          previous: activatedRoute));
    });
  });
}
