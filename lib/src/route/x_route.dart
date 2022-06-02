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
/// children if [isAddedToPoppableStack] is true.
/// {@endtemplate}
///
/// {@template isAddedToPoppableStack}
/// The [isAddedToPoppableStack] represents whether the route will be added to
/// the poppableStack when accessing longer paths.
///
/// By default isAddedToPoppableStack is true, meaning that when we go to:
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

  /// {@macro isAddedToPoppableStack}
  final bool isAddedToPoppableStack;

  /// browser tab title
  final XTitleBuilder? titleBuilder;

  /// for nested routers
  final List<XRoute> children;

  final XRoutePattern _pattern;

  XRoute({
    required this.path,
    required this.builder,
    this.children = const [],
    this.pageKey,
    this.titleBuilder,
    this.isAddedToPoppableStack = true,
  }) : _pattern = XRoutePattern(path);

  /// matches a path against this route
  /// the [path] is the path to be matched against this route
  bool match(String path) {
    return _pattern.match(path, matchChildren: isAddedToPoppableStack);
  }

  /// parses a path against this route
  /// the [path] is the path to be matched against this route
  XParsingResult parse(String path) {
    return _pattern.parse(path, matchChildren: isAddedToPoppableStack);
  }

  @override
  String toString() {
    return 'XRoute(path: $path, matchChildren: $isAddedToPoppableStack, $builder: ${builder.runtimeType})';
  }

  XRoute copyWithBuilder({
    XPageBuilder? builder,
  }) {
    return XRoute(
      pageKey: null,
      path: path,
      builder: builder ?? this.builder,
      isAddedToPoppableStack: isAddedToPoppableStack,
      children: children,
      titleBuilder: titleBuilder,
    );
  }
}
