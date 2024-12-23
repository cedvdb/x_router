import 'dart:async';

import 'package:equatable/equatable.dart';

import 'package:x_router/src/navigated_route/x_navigated_route.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';

/// Keeps track of the router state
class EventEmitter {
  EventEmitter._();

  // not a fan of singleton pattern but since this is kind of a logger it works well
  /// singleton
  static final EventEmitter instance = EventEmitter._();

  /// Streams all router events
  late final Stream<RouterEvent> eventStream =
      _eventController.stream.asBroadcastStream();
  final StreamController<RouterEvent> _eventController = StreamController();

  /// adds an event to the event stream
  void emit(RouterEvent event) => _eventController.add(event);
}

sealed class RouterEvent with EquatableMixin {
  final String target;
  const RouterEvent({required this.target});

  @override
  String toString() => '$runtimeType(target: $target)';

  @override
  List<Object?> get props => [target];
}

// navigation events
abstract class NavigationEvent extends RouterEvent {
  const NavigationEvent({required super.target});
}

class NavigationStart extends NavigationEvent {
  final Map<String, String>? params;
  final NavigatedRoute? removeHistoryThrough;

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
  final NavigatedRoute navigatedRoute;
  final NavigatedRoute? previous;
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

abstract class ChildNavigationEvent extends RouterEvent {
  const ChildNavigationEvent({required super.target});
}

class ChildNavigationStart extends RouterEvent {
  const ChildNavigationStart({required super.target});
}

class ChildNavigationEnd extends RouterEvent {
  final NavigatedRoute navigatedRoute;
  const ChildNavigationEnd(
      {required super.target, required this.navigatedRoute});
  @override
  String toString() =>
      'ChildNavigationEnd(target: $target, activatedRoute: $navigatedRoute)';
}

// url parsing events

abstract class UrlParsingEvent extends RouterEvent {
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

abstract class ResolvingEvent extends RouterEvent {
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

abstract class BuildEvent extends RouterEvent {
  const BuildEvent({required super.target});
}

class BuildStart extends BuildEvent {
  const BuildStart({
    required super.target,
  });
}

class BuildEnd extends BuildEvent {
  final NavigatedRoute activatedRoute;

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
