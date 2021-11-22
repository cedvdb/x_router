import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/events/x_router_events.dart';

class ActivatedRouteBuildStart extends BuildEvent {
  ActivatedRouteBuildStart({
    required String target,
  }) : super(target);

  @override
  String toString() => '    ActivatedRouteBuildStart(target: $target)';
}

class ActivatedRouteBuildEnd extends BuildEvent {
  final XActivatedRoute activatedRoute;

  ActivatedRouteBuildEnd({
    required this.activatedRoute,
    required String target,
  }) : super(target);

  @override
  String toString() =>
      '    ActivatedRouteBuildEnd(target: $target, activatedRoute: $activatedRoute)';
}
