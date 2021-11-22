import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';

/// flutter furnish this class that you need to extend to transform a path
/// into an object of your choice. However the way it works is not convenient
/// to build on top (an example is our redirects)

class XRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    // we can
    return SynchronousFuture(routeInformation.location ?? '');
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(location: configuration);
  }
}
