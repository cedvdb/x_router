import 'package:flutter/widgets.dart';
import 'package:route_parser/route_parser.dart';

typedef XPageBuilder = Widget Function(
    BuildContext context, Map<String, String> params);
typedef XRedirect = String Function(String target);

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
/// {@template redirectTo}
/// If [redirect] is specified, accessing the route [path] will redirect to another route.
/// That other route path must be a valid [Route].
/// If [redirect] is specified, the [builder] has no effects. Only the builder of the target
/// route will be used to build the page.
/// {@endtemplate}
///
/// {@template matchType}
/// The [MatchType] specify which path will match this one.
///
/// It can be:
///   - `MatchType.partial`
///   - `MatchType.exact`
///
/// By default a route is MatchType.partial, meaning that when we go to:
/// `/products/:id`, the routes `/`, `/products` and `/products/:id` will be in the navigator
/// stack when displaying `/products/123`. A little arrow ⬅ will be displayed in the app bar
/// to go up the stack to `/products` then `/`.
///
/// If `MatchType.exact` was added to the `/` route then the stack would be `/products`, `/products/:id`.
/// If it was specified for both `/` and `/products`, the stack would only be `/products/:id`
/// when accessing `/products/123` and no little arrow ⬅ would be in the appbar
/// {@end template}
class XRoute {
  /// {@macro path}
  final String path;

  /// {@macro builder}
  final XPageBuilder builder;

  /// {@macro redirectTo}
  final XRedirect redirect;

  /// {@macro matchType}
  final MatchType matchType;

  final RouteParser _parser;

  XRoute({
    this.path,
    this.builder,
    this.redirect,
    this.matchType = MatchType.partial,
  }) : _parser = RouteParser(path);

  XRoute.notFound(String target)
      : this(builder: (ctx, target) => Text('route $target not found'));

  /// matches a path against this route
  /// the [path] is the path to be matched against this route
  /// if [matchType] isn't specified the matchType of this route is used, which is partial by default
  /// {@macro matchType}
  match(String path, [MatchType matchType]) {
    if (matchType == null) {
      matchType = this.matchType;
    }
    _parser.match(path, matchType);
  }

  /// parses a path against this route
  /// the [path] is the path to be matched against this route
  /// if [matchType] isn't specified the matchType of this route is used, which is partial by default
  /// {@macro matchType}
  parse(String path, [MatchType matchType]) {
    if (matchType == null) {
      matchType = this.matchType;
    }
    _parser.parse(path, MatchType.exact);
  }

  @override
  String toString() {
    return 'XRoute(path: $path, redirectTo: $redirect, mathType: $matchType, $builder: ${builder.runtimeType})';
  }
}
