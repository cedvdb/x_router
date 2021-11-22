import 'package:equatable/equatable.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';

abstract class XRouterEvent with EquatableMixin {
  final String target;

  const XRouterEvent(this.target);

  @override
  List<Object?> get props => [target];

  @override
  String toString() => '$runtimeType(target: $target)';
}

// navigation
class NavigationEvent extends XRouterEvent {
  const NavigationEvent(String target) : super(target);
}

class NavigationStart extends NavigationEvent {
  final Map<String, String>? params;
  final bool forcePush;

  const NavigationStart({
    required String target,
    required this.params,
    this.forcePush = false,
  }) : super(target);

  @override
  List<Object?> get props => [target, params, forcePush];

  @override
  String toString() =>
      'NavigationStart(target: $target, params: $params, forcePush: $forcePush)';
}

class NavigationEnd extends NavigationEvent {
  XActivatedRoute activatedRoute;
  NavigationEnd({
    required this.activatedRoute,
  }) : super(activatedRoute.effectivePath);

  @override
  List<Object?> get props => [target, activatedRoute];

  @override
  String toString() => 'NavigationEnd(activatedRoute: $activatedRoute)';
}

// url parsing
class UrlParsingEvent extends XRouterEvent {
  const UrlParsingEvent(String target) : super(target);
}

class UrlParsingStart extends UrlParsingEvent {
  final Map<String, String>? params;
  final String currentUrl;

  const UrlParsingStart({
    required String target,
    required this.params,
    required this.currentUrl,
  }) : super(target);

  @override
  List<Object?> get props => [target, params, currentUrl];

  @override
  String toString() =>
      'UrlParsingStart(target:$target, params: $params, currentUrl: $currentUrl)';
}

class UrlParsingEnd extends UrlParsingEvent {
  const UrlParsingEnd({required String target}) : super(target);
}

// resolving
class ResolvingEvent extends XRouterEvent {
  const ResolvingEvent(String target) : super(target);
}

class ResolvingStart extends ResolvingEvent {
  const ResolvingStart({required String target}) : super(target);
}

class ResolvingEnd extends ResolvingEvent {
  final XRouterResolveResult result;
  ResolvingEnd(this.result) : super(result.target);
  @override
  List<Object?> get props => [target, result];
}

// build
class BuildEvent extends XRouterEvent {
  const BuildEvent(String target) : super(target);
}

class BuildStart extends BuildEvent {
  BuildStart({required String target}) : super(target);
}

class BuildEnd extends BuildEvent {
  XActivatedRoute activatedRoute;
  BuildEnd({
    required String target,
    required this.activatedRoute,
  }) : super(target);

  @override
  String toString() =>
      'BuildEnd(target: $target, activatedRoute: $activatedRoute)';
  @override
  List<Object?> get props => [target, activatedRoute];
}
