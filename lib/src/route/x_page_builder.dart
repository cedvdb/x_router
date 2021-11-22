import 'package:flutter/widgets.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';

typedef XPageBuilder = Widget Function(
    BuildContext context, XActivatedRoute activatedRoute);
