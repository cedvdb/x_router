import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/events/x_event_emitter.dart';
import 'package:x_router/src/events/x_router_events.dart';
import 'package:x_router/src/route/x_route.dart';

void main() {
  group('Event emitter', () {
    test('Should emit events', () async {
      XEventEmitter state = XEventEmitter.instance;
      final activatedRoute = XActivatedRoute.nulled();
      expect(
        state.eventStream,
        emitsInOrder([
          NavigationStart(target: '', params: {}),
          NavigationEnd(activatedRoute: activatedRoute),
        ]),
      );
      state.addEvent(NavigationStart(target: '', params: {}));
      state.addEvent(NavigationEnd(activatedRoute: activatedRoute));
    });
  });
}
