import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final favs = app.favorites;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(context.tr('favorites_title'), style: ts(context, 24, w: FontWeight.w800)),
                  if (favs.isNotEmpty) Text('${favs.length} ${context.tr('units_count')}', style: ts(context, 13, color: AppColors.muted)),
                ]),
              ),
              CircleBtn(Icons.compare_arrows_rounded, badge: app.compareIds.length, onTap: () => Navigator.pushNamed(context, Routes.compare)),
            ]),
          ),
          if (favs.length >= 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: AppButton(
                context.tr('compare_selected'),
                icon: Icons.compare_arrows_rounded,
                style: BtnStyle.outline,
                height: 46,
                onTap: () {
                  app.clearCompare();
                  for (final p in favs.take(AppState.maxCompare)) {
                    app.toggleCompare(p.id);
                  }
                  Navigator.pushNamed(context, Routes.compare);
                },
              ),
            ),
          Expanded(
            child: favs.isEmpty
                ? EmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: context.tr('fav_empty'),
                    subtitle: context.tr('fav_empty_sub'),
                    actionLabel: context.tr('start_exploring'),
                    onAction: () => app.setTab(1),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, kNavSpace),
                    itemCount: favs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) => FadeSlideIn(
                      key: ValueKey(favs[i].id),
                      delayMs: i * 50,
                      child: PropertyCard(favs[i], heroPrefix: 'fav'),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}
