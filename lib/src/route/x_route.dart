import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:x_router/src/route_pattern/x_parsing_result.dart';
import 'package:x_router/src/route_pattern/x_route_pattern.dart';

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
/// children if [isAddedToDownStack] is true.
/// {@endtemplate}
///
/// {@template isAddedToDownStack}
/// The [isAddedToDownStack] represents whether the route will be added to
/// the downStack when accessing longer paths.
///
/// By default isAddedToDownStack is true, meaning that when we go to:
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

  /// {@macro isAddedToDownStack}
  final bool isAddedToDownStack;

  /// browser tab title
  final XTitleBuilder? titleBuilder;

  /// for nested routers
  final List<XRoute> children;

  final XRoutePattern _parser;

  XRoute({
    required this.path,
    required this.builder,
    this.children = const [],
    this.pageKey,
    this.titleBuilder,
    this.isAddedToDownStack = true,
  }) : _parser = XRoutePattern(path);

  /// given a path, computes the depest match that could be found
  /// on this route or any of its children
  String computeDeepestMatchingPath(String path) {
    final parseResult = parse(path);
    var effectivePath = parseResult.matchingPath;

    final hasChildRoutes = children != null;
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
    final childRoutes = children;
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
    return _parser.match(path, matchChildren: isAddedToDownStack);
  }

  /// parses a path against this route
  /// the [path] is the path to be matched against this route
  XParsingResult parse(String path) {
    return _parser.parse(path, matchChildren: isAddedToDownStack);
  }

  @override
  String toString() {
    return 'XRoute(path: $path, matchChildren: $isAddedToDownStack, $builder: ${builder.runtimeType})';
  }

  XRoute copyWithBuilder({
    XPageBuilder? builder,
  }) {
    return XRoute(
      pageKey: null,
      path: path,
      builder: builder ?? this.builder,
      isAddedToDownStack: isAddedToDownStack,
      children: children,
      titleBuilder: titleBuilder,
    );
  }
}
