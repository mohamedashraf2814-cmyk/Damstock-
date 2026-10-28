import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import 'filter_sheet.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _search = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final q = context.app.filter.query;
    if (_search.text != q) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _search.text != q) _search.text = q;
      });
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _update(AppState app, void Function(PropertyFilter f) fn) {
    final f = app.filter.clone();
    fn(f);
    app.setFilter(f);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ar = app.isAr;
    final f = app.filter;
    final results = app.filtered;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(children: [
                Expanded(child: Text(context.tr('explore_title'), style: ts(context, 24, w: FontWeight.w800))),
                CircleBtn(Icons.map_outlined, onTap: () => Navigator.pushNamed(context, Routes.map)),
                const SizedBox(width: 8),
                CircleBtn(Icons.compare_arrows_rounded, badge: app.compareIds.length, onTap: () => Navigator.pushNamed(context, Routes.compare)),
              ]),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onChanged: (v) => _update(app, (f) => f.query = v),
                    decoration: InputDecoration(
                      hintText: context.tr('search_hint'),
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () {
                                _search.clear();
                                _update(app, (f) => f.query = '');
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Pressable(
                  onTap: () => showFilterSheet(context),
                  child: Stack(clipBehavior: Clip.none, children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.tune_rounded, color: AppColors.gold),
                    ),
                    if (f.activeCount > 0)
                      PositionedDirectional(
                        top: -5,
                        end: -5,
                        child: CircleAvatar(radius: 10, backgroundColor: AppColors.gold, child: Text('${f.activeCount}', style: ts(context, 11, w: FontWeight.w800, color: AppColors.forestDark))),
                      ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Pill(context.tr('all'), selected: f.kind == null, onTap: () => _update(app, (f) => f.kind = null)),
                  for (final k in ListingKind.values) ...[
                    const SizedBox(width: 8),
                    Pill(kindLabel(k, ar), selected: f.kind == k, onTap: () => _update(app, (f) => f.kind = k)),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
              child: Row(children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text('${results.length} ${context.tr('results')}', key: ValueKey(results.length), style: ts(context, 13.5, w: FontWeight.w700, color: AppColors.muted)),
                ),
                if (f.activeCount > 0 || f.kind != null || f.query.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Pressable(
                    onTap: () {
                      _search.clear();
                      app.resetFilter();
                    },
                    child: Text(context.tr('clear_filters'), style: ts(context, 13, w: FontWeight.w700, color: AppColors.danger)),
                  ),
                ],
                const Spacer(),
                PopupMenuButton<SortBy>(
                  initialValue: f.sort,
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (s) => _update(app, (f) => f.sort = s),
                  itemBuilder: (_) => [
                    for (final s in SortBy.values)
                      PopupMenuItem(value: s, child: Text(sortLabel(s, ar), style: ts(context, 14, w: s == f.sort ? FontWeight.w800 : FontWeight.w500))),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(children: [
                      const Icon(Icons.swap_vert_rounded, size: 18, color: AppColors.forest),
                      const SizedBox(width: 4),
                      Text(sortLabel(f.sort, ar), style: ts(context, 13, w: FontWeight.w700, color: AppColors.forest)),
                    ]),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: results.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off_rounded,
                      title: context.tr('no_results'),
                      subtitle: context.tr('no_results_sub'),
                      actionLabel: context.tr('clear_filters'),
                      onAction: () {
                        _search.clear();
                        app.resetFilter();
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, kNavSpace),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) => FadeSlideIn(
                        key: ValueKey('${results[i].id}-${f.sort.name}'),
                        delayMs: i > 6 ? 360 : i * 60,
                        child: PropertyCard(results[i], heroPrefix: 'explore'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
