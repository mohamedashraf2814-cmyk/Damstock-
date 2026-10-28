import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ar = app.isAr;
    final items = app.compareIds.map(app.propertyById).whereType<Property>().toList();

    void goExplore() {
      app.setTab(1);
      AppRouter.toShell(context);
    }

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('compare_title'))),
        body: EmptyState(
          icon: Icons.compare_arrows_rounded,
          title: context.tr('compare_empty'),
          subtitle: context.tr('compare_empty_sub'),
          actionLabel: context.tr('start_exploring'),
          onAction: goExplore,
        ),
      );
    }

    final bestPpm = items.map((p) => p.pricePerMeter).reduce((a, b) => a < b ? a : b);
    final lowestPrice = items.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    final biggest = items.map((p) => p.area).reduce((a, b) => a > b ? a : b);
    final lowestMonthly = items.where((p) => p.monthly != null).map((p) => p.monthly!).fold<int?>(null, (m, v) => m == null || v < m ? v : m);

    const labelW = 104.0;
    final colW = ((MediaQuery.sizeOf(context).width - 32 - labelW) / 3).clamp(112.0, 200.0);

    final rows = <(String, String Function(Property), bool Function(Property))>[
      (context.tr('listing_kind'), (p) => kindLabel(p.kind, ar), (_) => false),
      (context.tr('type'), (p) => typeLabel(p.type, ar), (_) => false),
      (context.tr('price'), (p) => fmtPrice(p.price, ar), (p) => p.price == lowestPrice && items.length > 1),
      (context.tr('price_per_m'), (p) => fmtFull(p.pricePerMeter, ar), (p) => p.pricePerMeter == bestPpm && items.length > 1),
      (context.tr('area'), (p) => '${p.area} ${context.tr('sqm')}', (p) => p.area == biggest && items.length > 1),
      (context.tr('beds'), (p) => p.beds == 0 ? '—' : '${p.beds}', (_) => false),
      (context.tr('baths'), (p) => '${p.baths}', (_) => false),
      (context.tr('finishing'), (p) => finishLabel(p.finish, ar), (_) => false),
      (context.tr('delivery'), (p) => p.isReady ? context.tr('ready_now') : '${p.deliveryYear}', (p) => p.isReady && items.length > 1),
      (context.tr('down_payment'), (p) => p.downPayment == null ? context.tr('cash') : fmtPrice(p.downPayment!, ar), (_) => false),
      (context.tr('monthly'), (p) => p.monthly == null ? '—' : fmtPrice(p.monthly!, ar), (p) => p.monthly != null && p.monthly == lowestMonthly && items.length > 1),
      (context.tr('city'), (p) => p.city.of(ar), (_) => false),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('compare_title')),
        actions: [
          TextButton(
            onPressed: app.clearCompare,
            child: Text(context.tr('clear_all'), style: ts(context, 13.5, w: FontWeight.w700, color: AppColors.danger)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Tag.gold(context.tr('best_value'), icon: Icons.workspace_premium_rounded),
            const SizedBox(width: 8),
            Expanded(child: Text('${items.length}/3', style: ts(context, 12.5, color: AppColors.muted))),
          ]),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: cardDeco(),
              clipBehavior: Clip.antiAlias,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: labelW, height: 172),
                  for (final p in items)
                    SizedBox(
                      width: colW,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Stack(children: [
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, Routes.property, arguments: PropertyArgs(p.id)),
                              child: NetImg(p.cover, height: 96, width: colW, radius: BorderRadius.circular(14)),
                            ),
                            PositionedDirectional(
                              top: 6,
                              end: 6,
                              child: GestureDetector(
                                onTap: () => app.toggleCompare(p.id),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.o(.15), blurRadius: 6)]),
                                  child: const Icon(Icons.close_rounded, size: 16),
                                ),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Text(p.title.of(ar), maxLines: 2, overflow: TextOverflow.ellipsis, style: ts(context, 12.5, w: FontWeight.w800, height: 1.3)),
                        ]),
                      ),
                    ),
                  if (items.length < 3)
                    SizedBox(
                      width: colW,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Pressable(
                          onTap: goExplore,
                          child: Container(
                            height: 96,
                            decoration: BoxDecoration(
                              color: AppColors.sand,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.gold.o(.5)),
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Icon(Icons.add_circle_outline_rounded, color: AppColors.goldDeep),
                              const SizedBox(height: 4),
                              Text(context.tr('add_more'), style: ts(context, 12, w: FontWeight.w800, color: AppColors.goldDeep)),
                            ]),
                          ),
                        ),
                      ),
                    ),
                ]),
                for (var r = 0; r < rows.length; r++)
                  Container(
                    color: r.isEven ? AppColors.ivory : AppColors.white,
                    child: Row(children: [
                      SizedBox(
                        width: labelW,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 12, top: 12, bottom: 12, end: 4),
                          child: Text(rows[r].$1, style: ts(context, 12, w: FontWeight.w700, color: AppColors.muted)),
                        ),
                      ),
                      for (final p in items)
                        SizedBox(
                          width: colW,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            child: Row(children: [
                              Flexible(
                                child: Text(
                                  rows[r].$2(p),
                                  style: ts(context, 12.5, w: FontWeight.w800, color: rows[r].$3(p) ? AppColors.forest : AppColors.ink),
                                ),
                              ),
                              if (rows[r].$3(p)) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.workspace_premium_rounded, size: 15, color: AppColors.gold),
                              ],
                            ]),
                          ),
                        ),
                      if (items.length < 3) SizedBox(width: colW),
                    ]),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          Text(context.tr('calc_note'), style: ts(context, 11.5, color: AppColors.muted)),
        ]),
      ),
    );
  }
}
