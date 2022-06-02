import 'package:example/layout/nav_rail.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final childRouter = router.childRouterStore.findChild(RouteLocations.app);
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Scaffold(
          body: Row(
            children: [
              const NavRail(),
              Expanded(
                child: Router(
                  routerDelegate: childRouter.delegate,
                  routeInformationParser: childRouter.informationParser,
                  // routeInformationProvider: childRouter.informationProvider,
                  // backButtonDispatcher: childRouter.backButtonDispatcher,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
