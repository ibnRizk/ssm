import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/utils/values/strings.dart';

/// Bottom-navigation shell for the 5 main tabs.
///
/// Built on [StatefulNavigationShell] (via `StatefulShellRoute.indexedStack`
/// in [AppRoutes]) rather than a plain `ShellRoute`: each branch keeps its own
/// navigation stack and state when the user switches tabs, instead of being
/// torn down and rebuilt.
///
/// Tab order matches the design spec — Home, Orders, Parcels, Subscriptions,
/// Profile — and needs no manual RTL handling: `BottomNavigationBar` mirrors
/// this logical order automatically under the ambient RTL `Directionality`
/// when the active locale is Arabic, so item 1 ("الرئيسية") lands on the
/// right without the list being reversed in code.
class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => navigationShell.goBranch(
          index,
          // Re-tapping the already-active tab pops it back to its root
          // instead of leaving it mid-stack.
          initialLocation: index == navigationShell.currentIndex,
        ),
        // Selected/unselected colours (orange / muted gray) come from
        // `bottomNavigationBarTheme` in app_theme.dart — not repeated here.
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: Strings.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
            label: Strings.navOrders,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            activeIcon: const Icon(Icons.inventory_2),
            label: Strings.navParcels,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.star_outline),
            activeIcon: const Icon(Icons.star),
            label: Strings.navSubscriptions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: Strings.navProfile,
          ),
        ],
      ),
    );
  }
}

/// Temporary body for a shell tab. Swap it for the real feature screen when
/// that tab is built — only the route `builder` in [AppRoutes] needs to
/// change, [MainScaffold] and the routing stay the same.
class ShellTabPlaceholder extends StatelessWidget {
  final String label;

  const ShellTabPlaceholder({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text(label, style: AppTextStyles.h2())),
    );
  }
}
