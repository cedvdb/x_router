import 'package:flutter/widgets.dart';
import 'package:x_router/src/navigated_route/x_navigated_route.dart';

/// used to render a page on screen
typedef XPageBuilder = Widget Function(
  BuildContext context,
  XNavigatedRoute activatedRoute,
);

/// used to build the title in browser tabs, a builder is used mainly
/// for localization support
typedef XTitleBuilder = String Function(
  BuildContext context,
);
