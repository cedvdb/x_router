import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:x_router/src/parser/x_parsing_result.dart';
import 'package:x_router/src/parser/x_route_parser.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';

typedef XPageBuilder = Widget Function(
    BuildContext context, Map<String, String> params);

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
/// children if [matchChildren] is true.
/// {@endtemplate}
///
/// {@template matchChildren}
/// The [matchChildren] whether the path will match the child paths.
///
/// By default matchChildren is true, meaning that when we go to:
/// `/products/:id`, the routes `/`, `/products` and `/products/:id` will be in the navigator
/// stack when displaying `/products/123`. A little arrow ⬅ will be displayed in the app bar
/// to go up the stack to `/products` then `/`.
///
/// If `matchChildren: false` was added to the `/` route then the stack would be `/products`, `/products/:id`.
/// If it was specified for both `/` and `/products`, the stack would only be `/products/:id`
/// when accessing `/products/123` and no little arrow ⬅ would be in the appbar
/// {@end template}
class XRoute {
  /// {@macro path}
  final String path;

  /// {@macro builder}
  final XPageBuilder? builder;

  /// {@macro matchChildren}
  final bool matchChildren;

  /// {@macro resolvers}
  final List<XResolver> resolvers;

  final XRouteParser _parser;

  XRoute({
    required this.path,
    required this.builder,
    this.resolvers = const [],
    this.matchChildren = true,
  }) : _parser = XRouteParser(path);

  /// matches a path against this route
  /// the [path] is the path to be matched against this route
  /// if [matchChildren] isn't specified the matchChildren of property this route is used, which is true by default
  /// {@macro matchType}
  bool match(String path, {bool? matchChildren}) {
    if (matchChildren == null) {
      matchChildren = this.matchChildren;
    }
    return _parser.match(path, matchChildren: matchChildren);
  }

  /// parses a path against this route
  /// the [path] is the path to be matched against this route
  /// if [matchChildren] isn't specified the matchChildren of this route is used, which is true by default
  /// {@macro matchType}
  XParsingResult parse(String path, {bool? matchChildren}) {
    if (matchChildren == null) {
      matchChildren = this.matchChildren;
    }
    return _parser.parse(path, matchChildren: matchChildren);
  }

  @override
  String toString() {
    return 'XRoute(path: $path, matchChildren: $matchChildren, $builder: ${builder.runtimeType})';
  }
}
