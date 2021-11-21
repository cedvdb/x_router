import 'x_parsing_result.dart';
import 'dart:math';

/// Representation of a route that can then be parsed and matched
/// example
class XRoutePattern {
  final String path;
  late final Uri _uri = Uri(path: sanitize(path));

  List<String> get _segments => _uri.pathSegments;

  XRoutePattern(String path) : path = sanitize(path);

  /// creates a route pattern relative to another if the path starts with ./
  XRoutePattern.relative(String path, String relativeTo)
      : path = sanitize(getRelativePath(path, relativeTo));

  /// matches a path against this route.
  bool match(String path, {bool matchChildren = false}) {
    return parse(path, matchChildren: matchChildren).matches;
  }

  /// adds params to a route.
  ///
  /// eg: /path/:id with params { 'id' : '123'} becomes /path/123
  String addParameters(Map<String, String>? params) {
    if (params == null) {
      return path;
    }
    final segments = _uri.pathSegments.map((segment) {
      if (segment.startsWith(':')) {
        final key = segment.replaceFirst(':', '');
        final param = params[key];
        if (param != null) {
          return Uri.encodeComponent(param);
        }
      }
      return segment;
    });
    return '/' + segments.join('/');
  }

  /// parses path against this route
  XParsingResult parse(String path, {bool matchChildren = false}) {
    final toMatch = XRoutePattern(path);
    final matches = <bool>[];
    final params = <String, String>{};
    final matchingSegments = [];
    final toMatchIsShorter = toMatch._segments.length < _segments.length;
    final toMatchIsLonger = toMatch._segments.length > _segments.length;
    final minLength = min(_segments.length, toMatch._segments.length);

    // if toMatch is shorter it's defacto not a match
    if (toMatchIsShorter) {
      matches.add(false);
    }

    // if toMatch is longer and we can match children, it could it still be matching
    if (matchChildren == false && toMatchIsLonger) {
      matches.add(false);
    }

    for (var i = 0; i < minLength; i++) {
      final patternSegment = _segments[i];
      final toMatchSegment = toMatch._segments[i];

      // we extract the param
      if (patternSegment.startsWith(':')) {
        final key = patternSegment.replaceFirst(':', '');
        params[key] = toMatchSegment;
        matchingSegments.add(toMatchSegment);
        matches.add(true);
        continue;
      }

      // Exact segment match
      if (toMatchSegment == patternSegment) {
        matches.add(true);
        matchingSegments.add(toMatchSegment);
        continue;
      } else {
        matches.add(false);
        break;
      }
    }

    return XParsingResult(
      matches: matches.every((m) => m),
      pathParameters: params,
      path: path,
      patternPath: _uri.path,
      matchingPath: '/' + matchingSegments.join('/'),
    );
  }

  /// sanitize path by removing leading and trailing spaces and backslashes
  static String sanitize(String path) {
    path = '/' +
        path
            // remove leading and trailing spaces
            .replaceAll(RegExp(r'^\s+|\s+$'), '')
            // remove leading and trailing slashes
            .replaceAll(RegExp(r'^\/+|\/+$'), '');
    return Uri.encodeFull(path);
  }

  /// gets the url relative to the current route if the url starts with ./
  static String getRelativePath(String target, String relativeTo) {
    // relative to current route
    if (target.startsWith('./')) {
      var resolvedParts = relativeTo.split('/');
      resolvedParts.removeLast();
      target = resolvedParts.join('/') + target.substring(1);
    }
    return target;
  }
}
