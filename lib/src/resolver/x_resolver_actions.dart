import 'package:equatable/equatable.dart';
import 'package:x_router/src/route/x_page_builder.dart';

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

/// To stop the resolving process and access the target without going to
/// the next resolver
class ByPass extends XResolverAction with EquatableMixin {
  const ByPass();
  @override
  List<Object?> get props => [];
}

/// this is useful for not redirecting to a loading page when the state is unknow
/// the canonical example is for authentication status
///
/// The alternative is to redirect to a loading page and pass it the
/// target page as data. Then when the resolver resolves, the data is used
/// to redirect. That process is slightly more involved and error prone
/// than just using Loading
class Loading extends XResolverAction with EquatableMixin {
  final XPageBuilder loadingScreenBuilder;
  const Loading(this.loadingScreenBuilder);
  @override
  List<Object?> get props => [loadingScreenBuilder];
}