import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

// Note to reader: flutter furnish this class to transform a path
// into an object of your choice.
//
// Internally we use a XActivatedRoute. However transformation is not done
// here (it could though) but instead in the XRouter.
//
// An alternative approach that was taken was to make the XRoute extend RouteInformationParser.
// It worked well, but it might be simpler to just forget about RouteInformationParser
// which is what is essentially done here by just forwarding the location string.
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
