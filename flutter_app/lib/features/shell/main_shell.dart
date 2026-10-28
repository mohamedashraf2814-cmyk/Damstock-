import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../developers/developers_screen.dart';
import '../explore/explore_screen.dart';
import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../resale/resale_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _tabs = <Widget>[
    HomeScreen(),
    ExploreScreen(),
    DevelopersScreen(),
    ResaleScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return PopScope(
      canPop: app.tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) app.setTab(0);
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(index: app.tab, children: _tabs),
        bottomNavigationBar: const _NavBar(),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar();

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'tab_home'),
    (Icons.travel_explore_outlined, Icons.travel_explore_rounded, 'tab_explore'),
    (Icons.domain_outlined, Icons.domain_rounded, 'tab_developers'),
    (Icons.swap_horiz_rounded, Icons.swap_horiz_rounded, 'tab_resale'),
    (Icons.favorite_border_rounded, Icons.favorite_rounded, 'tab_favorites'),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 4),
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.forestDark,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(color: AppColors.forestDark.o(.35), blurRadius: 30, offset: const Offset(0, 14))],
        ),
        child: Row(
          children: List.generate(_items.length, (i) {
            final active = app.tab == i;
            final it = _items[i];
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  app.setTab(i);
                },
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? AppColors.gold.o(.14) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(clipBehavior: Clip.none, children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                            child: Icon(active ? it.$2 : it.$1, key: ValueKey(active), size: 23, color: active ? AppColors.gold : AppColors.white.o(.6)),
                          ),
                          if (i == 4 && app.favCount > 0)
                            PositionedDirectional(
                              top: -3,
                              end: -6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)),
                                child: Text('${app.favCount}', style: ts(context, 9, w: FontWeight.w800, color: AppColors.forestDark, height: 1.2)),
                              ),
                            ),
                        ]),
                        const SizedBox(height: 3),
                        Text(
                          context.tr(it.$3),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: ts(context, 10.5, w: active ? FontWeight.w800 : FontWeight.w600, color: active ? AppColors.gold : AppColors.white.o(.6), height: 1.1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
