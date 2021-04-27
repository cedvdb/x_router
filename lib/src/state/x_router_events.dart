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

class ResolvingStart extends XRouterEvent {
  final List<XResolver> resolvers;
  ResolvingStart({
    required String target,
    required this.resolvers,
  }) : super(target);

  @override
  String toString() =>
      'ResolvingStart($target: target, resolvers: ${resolvers.map((r) => r.runtimeType)})';
}

class ResolvingEnd extends XRouterEvent {
  ResolvingEnd({required String target}) : super(target);
}

class ResolverResolveStart extends XRouterEvent {
  final XResolver resolver;

  ResolverResolveStart({
    required this.resolver,
    required String target,
  }) : super(target);

  @override
  String toString() =>
      '    ${resolver.runtimeType} ResolveStart(target: $target, state: ${resolver.state})';
}

class ResolverResolveEnd extends XRouterEvent {
  final XResolver resolver;
  final String resolved;

  ResolverResolveEnd({
    required this.resolver,
    required this.resolved,
    required String target,
  }) : super(target);

  @override
  String toString() =>
      '    ${resolver.runtimeType} ResolveEnd(resolved: $resolved, target: $target, state: ${resolver.state})';
}

// build

class BuildStart extends XRouterEvent {
  BuildStart({required String target}) : super(target);
}

class BuildEnd extends XRouterEvent {
  BuildEnd({required String target}) : super(target);
}

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
