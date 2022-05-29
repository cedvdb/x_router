import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/route_pattern/x_parsing_result.dart';
import 'package:x_router/src/route_pattern/x_route_pattern.dart';

import 'x_child_router_config.dart';
import 'x_page_builder.dart';

/// An XRoute represents a route that can be accessed by the user
///
/// {@template path}
/// The [path] specifies wich path will match this route. It can be of different forms:
///   - `'/route'` : simple path
///   - `'/route/:id` : path with params
/// {@endtemplate}
///
/// {@template builder}
/// The [builder] role is to the page with the params it might receive as arguments.
/// {@endtemplate}
///
/// {@template resolvers}
/// The list of [resolvers] that are active for this specific route.
/// In those resolvers, the target will always be matching the route and
/// children if [isAddedToUpstack] is true.
/// {@endtemplate}
///
/// {@template isAddedToUpstack}
/// The [isAddedToUpstack] represents whether the route will be added to
/// the upstack when accessing longer paths.
///
/// By default isAddedToUpstack is true, meaning that when we go to:
/// `/products/:id`, the routes `/`, `/products` and `/products/:id` will be in the navigator
/// up stack when displaying `/products/123`. A little arrow ⬅ will be displayed in the app bar
/// to go up the stack to `/products` then `/`.
///
/// If `matchChildren: false` was added to the `/` route then the stack would be `/products`, `/products/:id`.
/// If it was specified for both `/` and `/products`, the stack would only be `/products/:id`
/// when accessing `/products/123` and no little arrow ⬅ would be in the appbar
/// {@end template}
class XRoute {
  final LocalKey? pageKey;

  /// {@macro path}
  final String path;

  /// {@macro builder}
  final XPageBuilder builder;

  /// {@macro isAddedToUpstack}
  final bool isAddedToUpstack;

  /// browser tab title
  final XTitleBuilder? titleBuilder;

  /// for nested routing
  final XChildRouterConfig? childRouterConfig;

  final XRoutePattern _parser;

  XRoute({
    required this.path,
    required this.builder,
    this.childRouterConfig,
    this.pageKey,
    this.titleBuilder,
    this.isAddedToUpstack = true,
  }) : _parser = XRoutePattern(path);

  /// given a path, computes the depest match that could be found
  /// on this route or any of its children
  String computeDeepestMatchingPath(String path) {
    final parseResult = parse(path);
    var effectivePath = parseResult.matchingPath;

    final childRoutes = childRouterConfig?.routes;
    final hasChildRoutes = childRoutes != null;
    final isSamePath = path == this.path;
    // we need to find the longest path that matches
    // so if there is no child route or the path is the same as this one there
    // is no need to keep going
    if (!hasChildRoutes || isSamePath) {
      return effectivePath;
    }
    // if a child route match then the effective path will be longer
    XRoute? childMatch = _getChildMatch(path);
    // if there are child match we get their effective path path
    if (childMatch != null) {
      effectivePath = childMatch.computeDeepestMatchingPath(path);
    }
    return effectivePath;
  }

  XRoute? _getChildMatch(String path) {
    final childRoutes = childRouterConfig?.routes ?? [];
    // check if there is a match in childs
    try {
      // sort longest first
      childRoutes.sort((a, b) => b.path.compareTo(a.path));
      return childRoutes.firstWhere((route) => route.match(path));
    } catch (e) {
      return null;
    }
  }

  /// matches a path against this route
  /// the [path] is the path to be matched against this route
  bool match(String path) {
    return _parser.match(path, matchChildren: isAddedToUpstack);
  }

  /// parses a path against this route
  /// the [path] is the path to be matched against this route
  XParsingResult parse(String path) {
    return _parser.parse(path, matchChildren: isAddedToUpstack);
  }

  @override
  String toString() {
    return 'XRoute(path: $path, matchChildren: $isAddedToUpstack, $builder: ${builder.runtimeType})';
  }

  XRoute copyWithBuilder({
    XPageBuilder? builder,
  }) {
    return XRoute(
      pageKey: null,
      path: path,
      builder: builder ?? this.builder,
      isAddedToUpstack: isAddedToUpstack,
    );
  }

  /// finds resolvers present in child routes
  List<XResolver> findChildResolvers() =>
      childRouterConfig?.findAllResolvers() ?? [];
}
