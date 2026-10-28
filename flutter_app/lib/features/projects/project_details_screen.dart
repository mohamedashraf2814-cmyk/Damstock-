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
import '../../widgets/map_canvas.dart';
import '../../widgets/payment_calculator.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String id;
  const ProjectDetailsScreen({super.key, required this.id});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  int _img = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ar = app.isAr;
    final project = MockData.project(widget.id);
    if (project == null) {
      return Scaffold(appBar: AppBar(), body: EmptyState(icon: Icons.location_city_rounded, title: context.tr('no_results'), subtitle: ''));
    }
    final dev = MockData.developer(project.developerId);
    final units = app.marketProperties.where((p) => p.projectId == project.id).toList();
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 380,
              child: Stack(children: [
                Positioned.fill(
                  child: PageView.builder(
                    itemCount: project.images.length,
                    onPageChanged: (i) => setState(() => _img = i),
                    itemBuilder: (context, i) => i == 0
                        ? Hero(tag: 'project-${project.id}-250', child: NetImg(project.images[i]))
                        : NetImg(project.images[i]),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.o(.35), Colors.transparent, AppColors.forestDark.o(.92)],
                          stops: const [0, .4, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: top + 8,
                  start: 16,
                  end: 16,
                  child: Row(children: [
                    CircleBtn(Icons.arrow_back_rounded, dark: true, onTap: () => Navigator.pop(context)),
                    const Spacer(),
                    CircleBtn(Icons.share_rounded, dark: true, onTap: () => showSnack(context, context.tr('shared'), icon: Icons.link_rounded)),
                  ]),
                ),
                PositionedDirectional(
                  start: 20,
                  end: 20,
                  bottom: 22,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Tag(projectStatusLabel(project.status, ar), bg: AppColors.gold, fg: AppColors.forestDark),
                      const Spacer(),
                      Row(
                        children: List.generate(
                          project.images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: i == _img ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(color: i == _img ? AppColors.gold : AppColors.white.o(.5), borderRadius: BorderRadius.circular(3)),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(project.name.of(ar), style: ts(context, 30, w: FontWeight.w800, color: AppColors.white, height: 1.15)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Flexible(child: Text('${project.location.of(ar)} • ${project.city.of(ar)}', style: ts(context, 13, color: AppColors.white.o(.85)))),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (dev != null)
                  Pressable(
                    onTap: () => Navigator.pushNamed(context, Routes.developer, arguments: dev.id),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: cardDeco(r: 18),
                      child: Row(children: [
                        DeveloperLogo(dev, size: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(context.tr('developer'), style: ts(context, 11, color: AppColors.muted)),
                            Text(dev.name.of(ar), style: ts(context, 15, w: FontWeight.w800)),
                          ]),
                        ),
                        Tag.soft(dev.rating.toStringAsFixed(1), icon: Icons.star_rounded, color: AppColors.goldDeep),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                      ]),
                    ),
                  ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.05,
                  children: [
                    _Fact(Icons.payments_rounded, context.tr('starting_from'), fmtPrice(project.startingPrice, ar)),
                    _Fact(Icons.event_available_rounded, context.tr('delivery'), '${project.deliveryYear}'),
                    _Fact(Icons.percent_rounded, context.tr('down_payment'), '${project.downPaymentPct}%'),
                    _Fact(Icons.date_range_rounded, context.tr('installments'), '${project.installmentYears} ${context.tr('years')}'),
                    _Fact(Icons.square_foot_rounded, context.tr('area_range'), '${project.minArea}–${project.maxArea}'),
                    _Fact(Icons.landscape_rounded, context.tr('project_size'), '${project.acres} ${context.tr('acres')}'),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: cardDeco(r: 18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(context.tr('construction_progress'), style: ts(context, 14, w: FontWeight.w800)),
                      const Spacer(),
                      Text('${(project.progress * 100).round()}%', style: ts(context, 16, w: FontWeight.w800, color: AppColors.goldDeep)),
                    ]),
                    const SizedBox(height: 10),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: project.progress),
                      duration: const Duration(milliseconds: 1100),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(value: v, minHeight: 10, backgroundColor: AppColors.sand, color: AppColors.forest),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 22),
                Text(context.tr('about_project'), style: ts(context, 18, w: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(project.description.of(ar), style: ts(context, 14, color: AppColors.muted, height: 1.75)),
                const SizedBox(height: 20),
                Text(context.tr('unit_types'), style: ts(context, 18, w: FontWeight.w800)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final t in project.unitTypes) Pill(typeLabel(t, ar), icon: typeIcon(t), dense: true),
                ]),
                const SizedBox(height: 22),
                Text(context.tr('amenities'), style: ts(context, 18, w: FontWeight.w800)),
                const SizedBox(height: 12),
                AmenityGrid(project.amenities),
                const SizedBox(height: 22),
                PaymentCalculator(price: project.startingPrice, initialDownPct: project.downPaymentPct, initialYears: project.installmentYears),
                const SizedBox(height: 22),
                Text(context.tr('location'), style: ts(context, 18, w: FontWeight.w800)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: MiniMap(x: project.x, y: project.y, label: context.tr('open_map'), onTap: () => Navigator.pushNamed(context, Routes.map)),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 26, bottom: 12), child: SectionHeader(context.tr('available_units')))),
          if (units.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: cardDeco(r: 18),
                  child: Text(context.tr('no_units'), style: ts(context, 13.5, color: AppColors.muted)),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: units.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) => PropertyCard(units[i], heroPrefix: 'proj'),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomNavigationBar: _ContactBar(
        primaryLabel: context.tr('book_viewing'),
        onPrimary: () => Navigator.pushNamed(context, Routes.inquiryNew, arguments: InquiryArgs(type: InquiryType.viewing, projectId: project.id)),
        onSecondary: () => Navigator.pushNamed(context, Routes.inquiryNew, arguments: InquiryArgs(type: InquiryType.callback, projectId: project.id)),
        secondaryIcon: Icons.phone_in_talk_rounded,
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Fact(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: cardDeco(r: 18),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: AppColors.gold, size: 22),
          const SizedBox(height: 6),
          FittedBox(child: Text(value, style: ts(context, 14, w: FontWeight.w800, color: AppColors.forest))),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 10.5, color: AppColors.muted)),
        ]),
      );
}

class AmenityGrid extends StatelessWidget {
  final List<String> amenities;
  const AmenityGrid(this.amenities, {super.key});

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final a in amenities)
          Container(
            width: (MediaQuery.sizeOf(context).width - 40 - 20) / 3,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: cardDeco(r: 16),
            child: Column(children: [
              Icon(amenityIcon(a), color: AppColors.forest, size: 22),
              const SizedBox(height: 6),
              Text(amenityLabel(a, ar), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 11.5, w: FontWeight.w700)),
            ]),
          ),
      ],
    );
  }
}

class _ContactBar extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final IconData secondaryIcon;
  const _ContactBar({required this.primaryLabel, required this.onPrimary, required this.onSecondary, required this.secondaryIcon});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.forestDark.o(.08), blurRadius: 24, offset: const Offset(0, -8))]),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(children: [
              Pressable(
                onTap: onSecondary,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.forest.o(.25), width: 1.2)),
                  child: Icon(secondaryIcon, color: AppColors.forest),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: AppButton(primaryLabel, onTap: onPrimary, icon: Icons.event_available_rounded, style: BtnStyle.gold)),
            ]),
          ),
        ),
      );
}
