import 'dart:async';

abstract class XResolver<G> {
  StreamController<G?> _state$ = StreamController<G?>();
  Stream<G?> get state$ => _state$.stream;
  G? _state;
  G? get state => _state;
  set state(G? state) {
    _state = state;
    _state$.add(_state);
  }

  XResolver({G? initialState}) : _state = initialState;

  /// resolve a route with the current state
  Future<String> resolve(String target);
}
