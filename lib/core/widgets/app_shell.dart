import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n_extension.dart';
import '../router/app_router.dart';

/// Tabbed shell: bottom nav over a child route.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = <_TabSpec>[
    _TabSpec(AppRoutes.home, Icons.home_outlined, Icons.home),
    _TabSpec(AppRoutes.history, Icons.access_time, Icons.access_time_filled),
    _TabSpec(
        AppRoutes.cars, Icons.directions_car_outlined, Icons.directions_car),
    _TabSpec(AppRoutes.profile, Icons.person_outline, Icons.person),
  ];

  int _indexFor(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final labels = [l.navHome, l.navHistory, l.navCars, l.navProfile];
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFor(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(_tabs[i].path),
        items: [
          for (var i = 0; i < _tabs.length; i++)
            BottomNavigationBarItem(
              icon: Icon(_tabs[i].icon, semanticLabel: labels[i]),
              activeIcon: Icon(_tabs[i].activeIcon, semanticLabel: labels[i]),
              label: '',
              tooltip: labels[i],
            ),
        ],
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.path, this.icon, this.activeIcon);
  final String path;
  final IconData icon;
  final IconData activeIcon;
}
