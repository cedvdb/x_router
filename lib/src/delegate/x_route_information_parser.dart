import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

// Note flutter furnish this class to transform a path
// into an object of your choice.
//
// internally we use a XActivatedRoute. However it is not really used here.
//
// to use the logic that is inside the router should move here
//

class XRouteInformationParser extends RouteInformationParser<String> {
  // resolvers
  // re
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture(routeInformation.location ?? '');
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(location: configuration);
  }
}
