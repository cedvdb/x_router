import 'package:example/layout/bottom_nav.dart';
import 'package:flutter/material.dart';

class HomeLayout extends StatefulWidget {
  final Widget child;
  const HomeLayout({
    Key? key,
    required this.child,
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
    child = widget.child;
  }

  @override
  void didUpdateWidget(HomeLayout old) {
    child = widget.child;
    super.didUpdateWidget(old);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNav(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: child,
      ),
    );
  }
}
