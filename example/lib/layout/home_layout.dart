import 'package:example/layout/nav_rail.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout>
    with SingleTickerProviderStateMixin {
  late Widget child;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(HomeLayout old) {
    super.didUpdateWidget(old);
  }

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
