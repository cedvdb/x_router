import 'package:equatable/equatable.dart';

import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';

abstract class XRouterEvent with EquatableMixin {
  final String target;
  const XRouterEvent(this.target);

  @override
  String toString() => '$runtimeType(target: $target)';
}

// navigation

class NavigationEvent extends XRouterEvent {
  const NavigationEvent(String target) : super(target);
  @override
  List<Object?> get props => [target];
}

class NavigationStart extends NavigationEvent {
  final Map<String, String>? params;

  const NavigationStart({
    required String target,
    required this.params,
  }) : super(target);

  @override
  List<Object?> get props => [target, params];

  @override
  String toString() => '$runtimeType(target: $target, params: $params)';
}

class NavigationReplaceStart extends NavigationStart {
  const NavigationReplaceStart({
    required String target,
    required Map<String, String>? params,
  }) : super(target: target, params: params);
}

class NavigationBackStart extends NavigationStart {
  const NavigationBackStart({
    required String target,
    required Map<String, String>? params,
  }) : super(target: target, params: params);
}

class NavigationPopStart extends NavigationStart {
  const NavigationPopStart({
    required String target,
    required Map<String, String>? params,
  }) : super(target: target, params: params);
}

class NavigationEnd extends NavigationEvent {
  final XActivatedRoute activatedRoute;
  const NavigationEnd({
    required String target,
    required this.activatedRoute,
  }) : super(target);

  @override
  List<Object?> get props => [target, activatedRoute];

  @override
  String toString() =>
      'NavigationEnd(target: $target, activatedRoute: $activatedRoute)';
}

// url parsing
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

// resolving
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
}
