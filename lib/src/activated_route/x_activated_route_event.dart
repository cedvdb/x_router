import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/state/x_router_events.dart';

class ActivatedRouteBuildStart extends XRouterEvent {
  final bool isRoot;
  ActivatedRouteBuildStart({
    required this.isRoot,
    required String target,
  }) : super(target);

  @override
  String toString() =>
      '    ActivatedRouteBuildStart(target: $target, isRoot: $isRoot)';
}

class ActivatedRouteBuildEnd extends XRouterEvent {
  final bool isRoot;
  final XActivatedRoute activatedRoute;

  ActivatedRouteBuildEnd({
    required this.isRoot,
    required this.activatedRoute,
    required String target,
  }) : super(target);

  @override
  String toString() =>
      '    ActivatedRouteBuildEnd(target: $target, isRoot: $isRoot, activatedRoute: $activatedRoute)';
}
