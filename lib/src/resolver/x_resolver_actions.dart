import 'package:equatable/equatable.dart';

abstract class XResolverAction {
  const XResolverAction();
}

/// To proceed to the next resolver
class Next extends XResolverAction with EquatableMixin {
  const Next();

  @override
  List<Object?> get props => [];
}

/// To redirect to a new route, will start the resolving process for that new route
class Redirect extends XResolverAction with EquatableMixin {
  final String target;
  const Redirect(this.target);
  @override
  List<Object?> get props => [target];
}
