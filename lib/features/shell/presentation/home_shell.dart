import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../biomarkers/presentation/biomarkers_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../timeline/presentation/timeline_screen.dart';
import '../../twin/presentation/twin_profile_screen.dart';
import '../application/shell_tab.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final ShellTab tab = ref.watch(shellTabProvider);

    return Scaffold(
      body: IndexedStack(index: tab.index, children: _tabs),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: tab.index,
          onTap: (int index) => ref
              .read(shellTabProvider.notifier)
              .select(ShellTab.values[index]),
          items: _items,
        ),
      ),
    );
  }
}
