import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/state/x_router_state.dart';
import 'package:x_router/src/state/x_router_state_notifier.dart';

class XRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  final XRouterStateNotifier routingStateNotifier;
  XRouterState get state => routingStateNotifier.value;
  String currentConfiguration;

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  XRouterDelegate({this.routingStateNotifier}) {
    routingStateNotifier.addListener(_onRoutingStateChanges);
  }

  _onRoutingStateChanges() {
    if (state.status == XStatus.resolved) {
      // this will make the build method rerun and change the url if needed
      currentConfiguration = state.resolved;
      notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        // parents
        ...state.current.upstack.map((r) => _buildPage(context, r)),
        // top
        _buildPage(context, state.current)
      ],
      onPopPage: (route, res) {
        _goUp();
        return route.didPop(res);
      },
    );
  }

  _buildPage(BuildContext context, XActivatedRoute activatedRoute) {
    final builder = activatedRoute.matchingRoute.builder;
    return MaterialPage(child: builder(context, activatedRoute.parameters));
  }

  _goUp() {
    setNewRoutePath(state.current.upstack.last.effectivePath);
  }

  @override
  Future<void> setNewRoutePath(String target) {
    routingStateNotifier.startResolving(target);
    return SynchronousFuture(null);
  }
}
