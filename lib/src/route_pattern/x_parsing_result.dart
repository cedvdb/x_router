import 'package:equatable/equatable.dart';

/// The result of trying to match a path against a route.
class XParsingResult with EquatableMixin {
  const XParsingResult({
    required this.matches,
    required this.path,
    required this.patternPath,
    required this.matchingPath,
    required this.pathParameters,
    required this.queryParameters,
  });

  /// The route path that was matched
  ///
  /// ie `/route/123/something-else`
  final String path;

  /// The part of the path that is matching the patternPath
  ///
  /// ie `/route/123` when the path is `/route/123/foo` and the route pattern is `/route/:id`
  final String matchingPath;

  /// The route path being matched onto
  ///
  /// ie `/route/:id`
  final String patternPath;

  /// If the [path] matches the [route]
  final bool matches;

  /// The parameters extracted from route wildcards
  ///
  /// ie `{'foo': 'hey'}` from `/route/:foo => /route/hey`
  final Map<String, String> pathParameters;

  /// The query parameters from route query
  ///
  /// ie `{'foo': 'hey'}` from `/route?foo=hey`
  final Map<String, String> queryParameters;

  @override
  String toString() {
    return 'ParsingResult(path: $path, pattern: $patternPath, matches: $matches, pathParameters: $pathParameters)';
  }

  @override
  List<Object?> get props => [
        matches,
        path,
        patternPath,
        matchingPath,
        pathParameters,
        queryParameters,
      ];
}
