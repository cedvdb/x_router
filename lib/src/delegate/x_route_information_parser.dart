import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

// flutter furnish this class that you need to extend to transform a path
// into an object of your choice. However the way it works is just not
// pratical. Therefor we use a string routeInformation and forget about this class

// the main issue is that parseRouteInfo is called on application startup for a browser
// then no subsequent call are made there. It means the logic to build XActivatedRoute
// needs to be somewhere else.

class XRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture(routeInformation.location ?? '');
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(location: configuration);
  }
}
