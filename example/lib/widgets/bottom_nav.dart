import 'package:flutter/material.dart';

import '../main.dart';

class BottomNav extends StatelessWidget {
  final _tabsIndex = <String, int>{
    RouteLocations.dashboard: 0,
    RouteLocations.products: 1,
    RouteLocations.favorites: 2,
  };
  final int tabIndex;

  BottomNav({Key? key, required this.tabIndex}) : super(key: key);

  /// when a tab is clicked, navigate to the target location
  _navigate(int index) {
    router.goTo(_findRoutePath(index));
  }

  /// finds the url path given a tab index
  String _findRoutePath(int index) {
    return _tabsIndex.entries.firstWhere((entry) => entry.value == index).key;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: _navigate,
      selectedIndex: tabIndex,
      destinations: const [
        // material you
        NavigationDestination(label: 'dashboard', icon: Icon(Icons.home)),
        NavigationDestination(
            label: 'products', icon: Icon(Icons.shopping_bag)),
        NavigationDestination(label: 'favorites', icon: Icon(Icons.favorite))
      ],
    );
  }
}
