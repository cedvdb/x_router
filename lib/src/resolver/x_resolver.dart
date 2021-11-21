import 'dart:async';

import 'package:flutter/widgets.dart';

abstract class XResolver<G> {
  StreamController<G?> _state$ = StreamController<G?>();
  late final Stream<G?> state$ = _state$.stream.asBroadcastStream();
  G? _state;
  G? get state => _state;
  set state(G? state) {
    _state = state;
    _state$.add(_state);
  }

  XResolver({G? initialState}) : _state = initialState;

  /// resolve a route with the current state
  XResolverAction resolve(String target);
}

abstract class XResolverAction {
  const XResolverAction();
}

class Next extends XResolverAction {
  const Next();
}

class Redirect extends XResolverAction {
  final String target;
  const Redirect(this.target);
}

class End extends XResolverAction {
  final String target;
  const End(this.target);
}

/// this is useful for not redirecting to a loading page when the state is unknow
/// the alternative being Redirect to a loading page then when the state is known
/// redirect back to the original requested page. However that process is slightly
/// more involved as it requires to add informations to the loading page
/// regarding the return Url
class Loading extends XResolverAction {
  final Widget loadingScreen;
  const Loading(this.loadingScreen);
}
