import 'package:equatable/equatable.dart';

import 'package:x_router/src/navigated_route/x_navigated_route.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';

abstract class XRouterEvent with EquatableMixin {
  final String target;
  const XRouterEvent({required this.target});

  @override
  String toString() => '$runtimeType(target: $target)';

  @override
  List<Object?> get props => [target];
}

// navigation events

class NavigationEvent extends XRouterEvent {
  const NavigationEvent({required super.target});
}

class NavigationStart extends NavigationEvent {
  final Map<String, String>? params;
  final XNavigatedRoute? removeHistoryThrough;

  const NavigationStart({
    required super.target,
    this.params = const {},
    this.removeHistoryThrough,
  });

  @override
  List<Object?> get props => [target, params];

  @override
  String toString() => '$runtimeType(target: $target, params: $params)';
}

class NavigationEnd extends NavigationEvent {
  final XNavigatedRoute navigatedRoute;
  final XNavigatedRoute? previous;
  const NavigationEnd({
    required super.target,
    required this.navigatedRoute,
    required this.previous,
  });

  @override
  List<Object?> get props => [target, navigatedRoute, previous];

  @override
  String toString() =>
      'NavigationEnd(target: $target, activatedRoute: $navigatedRoute, previousRoute: $previous)';
}

abstract class ChildNavigationEvent extends XRouterEvent {
  const ChildNavigationEvent({required super.target});
}

class ChildNavigationStart extends XRouterEvent {
  const ChildNavigationStart({required super.target});
}

class ChildNavigationEnd extends XRouterEvent {
  final XNavigatedRoute navigatedRoute;
  const ChildNavigationEnd(
      {required super.target, required this.navigatedRoute});
  @override
  String toString() =>
      'ChildNavigationEnd(target: $target, activatedRoute: $navigatedRoute)';
}

// url parsing events

abstract class UrlParsingEvent extends XRouterEvent {
  const UrlParsingEvent({required super.target});
}

class UrlParsingStart extends UrlParsingEvent {
  final Map<String, String>? params;

  const UrlParsingStart({
    required super.target,
    required this.params,
  });

  @override
  List<Object?> get props => [target, params];

  @override
  String toString() => 'UrlParsingStart(target:$target, params: $params,)';
}

class UrlParsingEnd extends UrlParsingEvent {
  final String parsed;
  const UrlParsingEnd({required this.parsed, required super.target});
}

// resolving event

abstract class ResolvingEvent extends XRouterEvent {
  const ResolvingEvent({required super.target});
}

class ResolvingStart extends ResolvingEvent {
  const ResolvingStart({required super.target});
}

class ResolvingEnd extends ResolvingEvent {
  final XRouterResolveResult result;
  const ResolvingEnd({required this.result, required super.target});
  @override
  List<Object?> get props => [target, result];

  @override
  String toString() => 'ResolvingEnd(target: $target, result: $result)';
}

// build events

abstract class BuildEvent extends XRouterEvent {
  const BuildEvent({required super.target});
}

class BuildStart extends BuildEvent {
  const BuildStart({
    required super.target,
  });
}

class BuildEnd extends BuildEvent {
  final XNavigatedRoute activatedRoute;

  const BuildEnd({
    required this.activatedRoute,
    required super.target,
  });

  @override
  String toString() =>
      'BuildEnd(target: $target, activatedRoute: $activatedRoute)';

  @override
  List<Object?> get props => [target, activatedRoute];
}
