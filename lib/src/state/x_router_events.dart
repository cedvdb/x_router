import 'package:x_router/src/activated_route/x_activated_route.dart';

abstract class XRouterEvent {
  final String target;

  const XRouterEvent(this.target);

  @override
  String toString() => '$runtimeType(target: $target)';
}

// navigation
class NavigationEvent extends XRouterEvent {
  const NavigationEvent(String target) : super(target);
}

class NavigationStart extends NavigationEvent {
  final Map<String, String>? params;

  const NavigationStart({
    required String target,
    required this.params,
  }) : super(target);

  @override
  String toString() => 'NavigationStart(target: $target, params: $params)';
}

class NavigationEnd extends NavigationEvent {
  const NavigationEnd({
    required String target,
  }) : super(target);
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
  const ResolvingEnd({required String target}) : super(target);
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
}
