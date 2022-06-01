import 'package:example/layout/bottom_nav.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({
    Key? key,
  }) : super(key: const ValueKey('homelayout'));

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
    final routerWidget = Router(
      key: const ValueKey('value'),
      routerDelegate: router.childRouterStore.findDelegate(RouteLocations.home),
    );
    return Scaffold(
      body: LayoutBuilder(builder: (context, _) {
        return Row(
          children: [
            NavigationRail(
              destinations: const [
                NavigationRailDestination(
                    label: Text('dashboard'), icon: Icon(Icons.home)),
                NavigationRailDestination(
                    label: Text('products'), icon: Icon(Icons.shopping_bag)),
                NavigationRailDestination(
                    label: Text('favorites'), icon: Icon(Icons.favorite))
              ],
              selectedIndex: 0,
            ),
            Expanded(child: routerWidget),
          ],
        );
      }),
    );
  }
}
