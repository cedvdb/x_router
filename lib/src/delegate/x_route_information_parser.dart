import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

// Note to reader: flutter furnish this class to transform a path
// into an object of your choice.
//
// Internally we use a XActivatedRoute. However transformation is not done
// here (it could though) but instead in the XRouter.
//
// However the processus is buggy especially with back press
//
// An alternative approach that was taken was to make the XRoute extend RouteInformationParser.
// It worked somewhat but the approach chosen was to ditch this class until the bugs are resolved.
//
// Therefor the reader can do as this file did not exist (until further changes).

class XRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    // read comment above
    return SynchronousFuture(routeInformation.location ?? '');
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(location: configuration);
  }
}
