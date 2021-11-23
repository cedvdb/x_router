import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/events/x_router_events.dart';

abstract class BuildEvent extends XRouterEvent {
  const BuildEvent(String target) : super(target);
}

class BuildStart extends BuildEvent {
  const BuildStart({
    required String target,
  }) : super(target);

  @override
  List<Object?> get props => [target];

  @override
  String toString() => '    ActivatedRouteBuildStart(target: $target)';
}

class BuildEnd extends BuildEvent {
  final XActivatedRoute activatedRoute;

  const BuildEnd({
    required this.activatedRoute,
    required String target,
  }) : super(target);

  @override
  String toString() =>
      '    ActivatedRouteBuildEnd(target: $target, activatedRoute: $activatedRoute)';

  @override
  List<Object?> get props => [target, activatedRoute];
}
