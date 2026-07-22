import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../biomarkers/presentation/biomarkers_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../timeline/presentation/timeline_screen.dart';
import '../../twin/presentation/twin_profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = widget.initialIndex;

  static const List<Widget> _tabs = <Widget>[
    DashboardScreen(),
    TimelineScreen(),
    BiomarkersScreen(),
    TwinProfileScreen(),
  ];

  static const List<BottomNavigationBarItem> _items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard_rounded),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.timeline_outlined),
      activeIcon: Icon(Icons.timeline_rounded),
      label: 'Timeline',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.monitor_heart_outlined),
      activeIcon: Icon(Icons.monitor_heart_rounded),
      label: 'Vitals',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      activeIcon: Icon(Icons.person_rounded),
      label: 'Twin',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (int index) => setState(() => _index = index),
          items: _items,
        ),
      ),
    );
  }
}
