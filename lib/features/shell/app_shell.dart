import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/hud_scaffold.dart';
import 'glass_nav_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  static const _destinations = [
    NavDestination(
      'Home',
      Icons.space_dashboard_outlined,
      Icons.space_dashboard_rounded,
    ),
    NavDestination('Licence', Icons.verified_outlined, Icons.verified_rounded),
    NavDestination('CME', Icons.school_outlined, Icons.school_rounded),
    NavDestination(
      'Library',
      Icons.auto_stories_outlined,
      Icons.auto_stories_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const HudBackground(),
          shell,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassNavBar(
              index: shell.currentIndex,
              destinations: _destinations,
              onSelect: (i) =>
                  shell.goBranch(i, initialLocation: i == shell.currentIndex),
            ),
          ),
        ],
      ),
    );
  }
}
