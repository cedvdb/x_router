import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class XResolver<G> {
  final StreamController<G?> _state$ = StreamController<G?>();
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

/// To proceed to the next resolver
class Next extends XResolverAction with EquatableMixin {
  const Next();

  @override
  List<Object?> get props => [];
}

/// To redirect to a new route
class Redirect extends XResolverAction with EquatableMixin {
  final String target;
  const Redirect(this.target);
  @override
  List<Object?> get props => [target];
}

/// this is useful for not redirecting to a loading page when the state is unknow
/// the canonical example is for authentication status
///
/// The alternative is to redirect to a loading page and pass it the
/// target page as data. Then when the resolver resolves, the data is used
/// to redirect. That process is slightly more involved and error prone
/// than just using Loading
class Loading extends XResolverAction with EquatableMixin {
  final Widget loadingScreen;
  const Loading(this.loadingScreen);
  @override
  List<Object?> get props => [loadingScreen];
}
