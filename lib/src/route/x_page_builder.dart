import 'package:flutter/widgets.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';

/// used to render a page on screen
typedef XPageBuilder = Widget Function(
  BuildContext context,
  XActivatedRoute activatedRoute,
);

/// used to build the title in browser tabs, a builder is used mainly
/// for localization support
typedef XTitleBuilder = String Function(
  BuildContext context,
  XActivatedRoute activatedRoute,
);
