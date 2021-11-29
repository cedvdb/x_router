// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:x_router/x_router.dart';

// import '../main.dart';

// class TabBuilder extends StatefulWidget {
//   final 
//   final Map<String, int> tabIndexes;

//   const TabBuilder({
//     Key? key,
//     required this.tabIndexes,
//   }) : super(key: key);

//   @override
//   State<TabBuilder> createState() => _TabBuilderState();
// }

// class _TabBuilderState extends State<TabBuilder> {
//   StreamSubscription? navSubscription;

//   int _selectedTab = 0;

//   @override
//   void initState() {
//     _selectedTab = _findTabIndex(router.history.currentUrl) ?? 0;
//     navSubscription = router.eventStream
//         .where((event) => event is NavigationEnd)
//         .listen((nav) => _refreshBottomBar());
//     super.initState();
//   }

//   @override
//   dispose() {
//     navSubscription?.cancel();
//     super.dispose();
//   }

//   /// changes the selected tab when the url changes
//   _refreshBottomBar() {
//     final foundIndex = _findTabIndex(router.history.currentUrl);
//     if (foundIndex != null) {
//       setState(() => _selectedTab = foundIndex);
//     }
//   }

//   /// when a tab is clicked, navigate to the target location
//   _navigate(int index) {
//     router.goTo(_findRoutePath(index));
//   }

//   /// finds the tab index associated with a path
//   int? _findTabIndex(String path) {
//     try {
//       return _tabsIndex.entries
//           .firstWhere((entry) => path.startsWith(entry.key))
//           .value;
//     } catch (e) {
//       return null;
//     }
//   }

//   /// finds the url path given a tab index
//   String _findRoutePath(int index) {
//     return _tabsIndex.entries.firstWhere((entry) => entry.value == index).key;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
