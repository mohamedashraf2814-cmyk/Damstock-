import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

class DeveloperDetailsScreen extends StatelessWidget {
  final String id;
  const DeveloperDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ar = app.isAr;
    final dev = MockData.developer(id);
    if (dev == null) {
      return Scaffold(appBar: AppBar(), body: EmptyState(icon: Icons.domain_disabled_rounded, title: context.tr('no_results'), subtitle: ''));
    }
    final projects = MockData.projectsOf(dev.id);
    final units = app.marketProperties.where((p) => p.developerId == dev.id).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.forestDark,
            foregroundColor: AppColors.white,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: CircleBtn(Icons.arrow_back_rounded, dark: true, onTap: () => Navigator.pop(context)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(fit: StackFit.expand, children: [
                NetImg(MockData.developerCover(dev)),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.forestDark.o(.3), AppColors.forestDark.o(.95)]),
                  ),
                ),
                PositionedDirectional(
                  start: 20,
                  end: 20,
                  bottom: 22,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    DeveloperLogo(dev, size: 76),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Tag.gold(dev.rating.toStringAsFixed(1), icon: Icons.star_rounded),
                        const SizedBox(height: 6),
                        Text(dev.name.of(ar), style: ts(context, 22, w: FontWeight.w800, color: AppColors.white, height: 1.2)),
                        Text(dev.tagline.of(ar), style: ts(context, 13, color: AppColors.white.o(.8))),
                      ]),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(children: [
                _Stat(Icons.location_city_rounded, '${dev.projectsCount}', context.tr('projects')),
                const SizedBox(width: 10),
                _Stat(Icons.key_rounded, '${fmtNum(dev.deliveredUnits)}+', context.tr('delivered_units')),
                const SizedBox(width: 10),
                _Stat(Icons.event_rounded, '${dev.founded}', context.tr('founded')),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(context.tr('about_dev'), style: ts(context, 18, w: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(dev.about.of(ar), style: ts(context, 14, color: AppColors.muted, height: 1.75)),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.location_on_rounded, size: 17, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text('${context.tr('hq')}: ${dev.hq.of(ar)}', style: ts(context, 13, w: FontWeight.w700)),
                ]),
              ]),
            ),
          ),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 26, bottom: 12), child: SectionHeader(context.tr('dev_projects')))),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => ProjectTile(projects[i]),
            ),
          ),
          if (units.isNotEmpty) ...[
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 26, bottom: 12), child: SectionHeader(context.tr('available_units')))),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 348,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  itemCount: units.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) => PropertyCard(units[i], heroPrefix: 'dev', width: 272, imageHeight: 170),
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: AppButton(
            context.tr('contact_dev'),
            icon: Icons.support_agent_rounded,
            style: BtnStyle.gold,
            onTap: () => Navigator.pushNamed(context, Routes.inquiryNew, arguments: InquiryArgs(type: InquiryType.callback, developerId: dev.id)),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: cardDeco(r: 18),
          child: Column(children: [
            Icon(icon, color: AppColors.gold, size: 22),
            const SizedBox(height: 6),
            Text(value, style: ts(context, 16, w: FontWeight.w800, color: AppColors.forest)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 11, color: AppColors.muted)),
          ]),
        ),
      );
}
