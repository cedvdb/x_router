import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/resolver/x_resolver.dart';

abstract class XRouterEvent {
  final String target;

  XRouterEvent(this.target);

  @override
  String toString() => '$runtimeType(target: $target)';
}

// navigation

class NavigationStart extends XRouterEvent {
  final Map<String, String>? params;

  NavigationStart({
    required String target,
    required this.params,
  }) : super(target);

  @override
  String toString() => 'NavigationStart(target: $target, params: $params)';
}

class NavigationEnd extends XRouterEvent {
  NavigationEnd({
    required String target,
  }) : super(target);
}

class Pop extends XRouterEvent {
  Pop({
    required String target,
  }) : super(target);
}

// url parsing

class UrlParsingStart extends XRouterEvent {
  final Map<String, String>? params;
  final String currentUrl;

  UrlParsingStart({
    required String target,
    required this.params,
    required this.currentUrl,
  }) : super(target);

  @override
  String toString() =>
      'UrlParsingStart(target:$target, params: $params, currentUrl: $currentUrl)';
}

class UrlParsingEnd extends XRouterEvent {
  UrlParsingEnd({required String target}) : super(target);
}

// resolving
// build

class BuildStart extends XRouterEvent {
  BuildStart({required String target}) : super(target);
}

class BuildEnd extends XRouterEvent {
  XActivatedRoute activatedRoute;
  BuildEnd({
    required String target,
    required this.activatedRoute,
  }) : super(target);

  @override
  String toString() =>
      'BuildEnd(target: $target, activatedRoute: $activatedRoute)';
}
