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
  NavigationEvent(String target) : super(target);
}

class NavigationStart extends NavigationEvent {
  final Map<String, String>? params;

  NavigationStart({
    required String target,
    required this.params,
  }) : super(target);

  @override
  List<Object?> get props => [target, params];

  @override
  String toString() => '$runtimeType(target: $target, params: $params)';
}

class NavigationReplaceStart extends NavigationStart {
  NavigationReplaceStart({
    required String target,
    required Map<String, String>? params,
  }) : super(target: target, params: params);
}

class NavigationBackStart extends NavigationStart {
  NavigationBackStart({
    required String target,
    required Map<String, String>? params,
  }) : super(target: target, params: params);
}

class NavigationPopStart extends NavigationStart {
  NavigationPopStart({
    required String target,
    required Map<String, String>? params,
  }) : super(target: target, params: params);
}

class NavigationEnd extends NavigationEvent {
  final XActivatedRoute activatedRoute;
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
  UrlParsingEvent(String target) : super(target);
}

class UrlParsingStart extends UrlParsingEvent {
  final Map<String, String>? params;

  UrlParsingStart({
    required String target,
    required this.params,
  }) : super(target);

  @override
  List<Object?> get props => [target, params];

  @override
  String toString() => 'UrlParsingStart(target:$target, params: $params,)';
}

class UrlParsingEnd extends UrlParsingEvent {
  UrlParsingEnd({required String target}) : super(target);
}

// resolving
class ResolvingEvent extends XRouterEvent {
  ResolvingEvent(String target) : super(target);
}

class ResolvingStart extends ResolvingEvent {
  ResolvingStart({required String target}) : super(target);
}

class ResolvingEnd extends ResolvingEvent {
  final XRouterResolveResult result;
  ResolvingEnd(this.result) : super(result.target);
  @override
  List<Object?> get props => [target, result];
}

// build
class BuildEvent extends XRouterEvent {
  BuildEvent(String target) : super(target);
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
