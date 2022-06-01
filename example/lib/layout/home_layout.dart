import 'package:example/layout/nav_rail.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const NavRail(),
        Expanded(
          child: Router(
            routerDelegate:
                router.childRouterStore.findDelegate(RouteLocations.app),
          ),
        ),
      ],
    );
  }
}
