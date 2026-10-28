import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

class ResaleScreen extends StatefulWidget {
  const ResaleScreen({super.key});

  @override
  State<ResaleScreen> createState() => _ResaleScreenState();
}

class _ResaleScreenState extends State<ResaleScreen> {
  int _seg = 0;
  bool _infoOpen = false;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ar = app.isAr;
    final list = app.marketProperties.where((p) {
      if (p.kind == ListingKind.primary) return false;
      if (_seg == 1) return p.kind == ListingKind.resale;
      if (_seg == 2) return p.kind == ListingKind.assignment;
      return true;
    }).toList()
      ..sort((a, b) => b.listedAt.compareTo(a.listedAt));

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.forestDark, AppColors.forest]),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(context.tr('resale_title'), style: ts(context, 24, w: FontWeight.w800, color: AppColors.white))),
                    CircleBtn(Icons.help_outline_rounded, dark: true, onTap: () => setState(() => _infoOpen = !_infoOpen)),
                  ]),
                  const SizedBox(height: 4),
                  Text(context.tr('resale_sub'), style: ts(context, 13, color: AppColors.white.o(.75))),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: _infoOpen
                        ? Container(
                            margin: const EdgeInsets.only(top: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: AppColors.white.o(.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gold.o(.3))),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.gold, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(context.tr('resale_info_t'), style: ts(context, 14, w: FontWeight.w800, color: AppColors.gold)),
                                  const SizedBox(height: 4),
                                  Text(context.tr('resale_info_b'), style: ts(context, 12.5, color: AppColors.white.o(.85), height: 1.6)),
                                ]),
                              ),
                            ]),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                  const SizedBox(height: 16),
                  Segmented(
                    dark: true,
                    labels: [context.tr('all'), kindLabel(ListingKind.resale, ar), kindLabel(ListingKind.assignment, ar)],
                    index: _seg,
                    onChanged: (i) => setState(() => _seg = i),
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    context.tr('sell_your_unit'),
                    icon: Icons.add_home_work_rounded,
                    style: BtnStyle.gold,
                    height: 50,
                    onTap: () => Navigator.pushNamed(context, Routes.addProperty),
                  ),
                ]),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, kNavSpace),
          sliver: list.isEmpty
              ? SliverToBoxAdapter(child: EmptyState(icon: Icons.search_off_rounded, title: context.tr('no_results'), subtitle: context.tr('no_results_sub')))
              : SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) => FadeSlideIn(key: ValueKey('${list[i].id}-$_seg'), delayMs: i * 60, child: PropertyCard(list[i], heroPrefix: 'resale')),
                ),
        ),
      ]),
    );
  }
}
