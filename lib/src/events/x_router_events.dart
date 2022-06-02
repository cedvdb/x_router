import 'package:equatable/equatable.dart';

import 'package:x_router/src/navigated_route/x_navigated_route.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';

abstract class XRouterEvent with EquatableMixin {
  final String target;
  const XRouterEvent(this.target);

  @override
  String toString() => '$runtimeType(target: $target)';
}

// navigation events

class NavigationEvent extends XRouterEvent {
  const NavigationEvent(String target) : super(target);
  @override
  List<Object?> get props => [target];
}

class NavigationStart extends NavigationEvent {
  final Map<String, String>? params;
  final XNavigatedRoute? removeHistoryThrough;

  const NavigationStart({
    required String target,
    this.params = const {},
    this.removeHistoryThrough,
  }) : super(target);

  @override
  List<Object?> get props => [target, params];

  @override
  String toString() => '$runtimeType(target: $target, params: $params)';
}

class NavigationEnd extends NavigationEvent {
  final XNavigatedRoute activatedRoute;
  final XNavigatedRoute? previous;
  const NavigationEnd({
    required String target,
    required this.activatedRoute,
    required this.previous,
  }) : super(target);

  @override
  List<Object?> get props => [target, activatedRoute, previous];

  @override
  String toString() =>
      'NavigationEnd(target: $target, activatedRoute: $activatedRoute, previousRoute: $previous)';
}

// url parsing events

abstract class UrlParsingEvent extends XRouterEvent {
  const UrlParsingEvent(String target) : super(target);

  @override
  List<Object?> get props => [target];
}

class UrlParsingStart extends UrlParsingEvent {
  final Map<String, String>? params;

  const UrlParsingStart({
    required String target,
    required this.params,
  }) : super(target);

  @override
  List<Object?> get props => [target, params];

  @override
  String toString() => 'UrlParsingStart(target:$target, params: $params,)';
}

class UrlParsingEnd extends UrlParsingEvent {
  final String parsed;
  const UrlParsingEnd({required this.parsed, required String target})
      : super(target);
}

// resolving event

abstract class ResolvingEvent extends XRouterEvent {
  const ResolvingEvent(String target) : super(target);
}

class ResolvingStart extends ResolvingEvent {
  const ResolvingStart({required String target}) : super(target);

  @override
  List<Object?> get props => [target];
}

class ResolvingEnd extends ResolvingEvent {
  final XRouterResolveResult result;
  const ResolvingEnd({required this.result, required String target})
      : super(target);
  @override
  List<Object?> get props => [target, result];

  @override
  String toString() => 'ResolvingEnd(target: $target, result: $result)';
}

// build events

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
  String toString() => 'BuildStart(target: $target)';
}

class BuildEnd extends BuildEvent {
  final XNavigatedRoute activatedRoute;

  const BuildEnd({
    required this.activatedRoute,
    required String target,
  }) : super(target);

  @override
  String toString() =>
      'BuildEnd(target: $target, activatedRoute: $activatedRoute)';

  @override
  List<Object?> get props => [target, activatedRoute];
}
