import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

/// Tabbed shell: bottom nav over a child route.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = <_TabSpec>[
    _TabSpec(AppRoutes.home, Icons.home_outlined, Icons.home, 'Головна'),
    _TabSpec(AppRoutes.history, Icons.access_time, Icons.access_time_filled,
        'Історія'),
    _TabSpec(AppRoutes.cars, Icons.directions_car_outlined,
        Icons.directions_car, 'Авто'),
    _TabSpec(AppRoutes.profile, Icons.person_outline, Icons.person, 'Профіль'),
  ];

  int _indexFor(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFor(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(_tabs[i].path),
        items: [
          for (final t in _tabs)
            BottomNavigationBarItem(
              icon: Icon(t.icon, semanticLabel: t.semanticLabel),
              activeIcon: Icon(t.activeIcon, semanticLabel: t.semanticLabel),
              label: '',
              tooltip: t.semanticLabel,
            ),
        ],
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.path, this.icon, this.activeIcon, this.semanticLabel);
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String semanticLabel;
}
