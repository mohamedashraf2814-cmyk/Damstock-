import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/payment_calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _projectsPc = PageController(viewportFraction: .87);
  int _projectIndex = 0;

  @override
  void dispose() {
    _projectsPc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ar = app.isAr;
    final featuredProjects = MockData.projects.where((p) => p.featured).toList();
    final featuredProps = app.marketProperties.where((p) => p.featured).toList();
    final recent = [...app.marketProperties]..sort((a, b) => b.listedAt.compareTo(a.listedAt));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(app: app)),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),

          SliverToBoxAdapter(child: SectionHeader(context.tr('categories'))),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 96,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (final t in [PropertyType.apartment, PropertyType.villa, PropertyType.townhouse, PropertyType.chalet, PropertyType.duplex, PropertyType.penthouse, PropertyType.office])
                    _CategoryTile(
                      icon: typeIcon(t),
                      label: typeLabel(t, ar),
                      onTap: () => app.exploreWith((f) => f.types = {t}),
                    ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),

          SliverToBoxAdapter(
            child: SectionHeader(
              context.tr('featured_projects'),
              subtitle: context.tr('featured_projects_sub'),
              onAction: () => Navigator.pushNamed(context, Routes.projects),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: PageView.builder(
                controller: _projectsPc,
                itemCount: featuredProjects.length,
                padEnds: false,
                onPageChanged: (i) => setState(() => _projectIndex = i),
                itemBuilder: (context, i) => AnimatedBuilder(
                  animation: _projectsPc,
                  builder: (context, child) {
                    double t = 0;
                    if (_projectsPc.hasClients && _projectsPc.position.haveDimensions) {
                      t = ((_projectsPc.page ?? 0) - i).abs().clamp(0.0, 1.0);
                    }
                    return Transform.scale(scale: 1 - t * .05, child: child);
                  },
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: i == 0 ? 20 : 6, end: 6, bottom: 10),
                    child: ProjectCard(featuredProjects[i]),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                featuredProjects.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _projectIndex ? 22 : 6,
                  height: 6,
                  decoration: BoxDecoration(color: i == _projectIndex ? AppColors.gold : AppColors.line, borderRadius: BorderRadius.circular(3)),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),

          SliverToBoxAdapter(child: SectionHeader(context.tr('top_developers'), onAction: () => app.setTab(2))),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: MockData.developers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final d = MockData.developers[i];
                  return Pressable(
                    onTap: () => Navigator.pushNamed(context, Routes.developer, arguments: d.id),
                    child: SizedBox(
                      width: 78,
                      child: Column(children: [
                        DeveloperLogo(d, size: 66),
                        const SizedBox(height: 8),
                        Text(d.name.of(ar), maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: ts(context, 11.5, w: FontWeight.w700, height: 1.25)),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          SliverToBoxAdapter(child: SectionHeader(context.tr('featured_props'), onAction: () => app.exploreWith((_) {}))),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 348,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                itemCount: featuredProps.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) => PropertyCard(featuredProps[i], heroPrefix: 'home-feat', width: 272, imageHeight: 170),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          SliverToBoxAdapter(child: SectionHeader(context.tr('tools'))),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                _ToolTile(Icons.compare_arrows_rounded, context.tr('tool_compare'), badge: app.compareIds.length, onTap: () => Navigator.pushNamed(context, Routes.compare)),
                const SizedBox(width: 10),
                _ToolTile(Icons.map_rounded, context.tr('tool_map'), onTap: () => Navigator.pushNamed(context, Routes.map)),
                const SizedBox(width: 10),
                _ToolTile(Icons.calculate_rounded, context.tr('tool_calc'), onTap: () => _openCalculator(context)),
                const SizedBox(width: 10),
                _ToolTile(Icons.add_home_work_rounded, context.tr('tool_sell'), onTap: () => Navigator.pushNamed(context, Routes.addProperty)),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),

          SliverToBoxAdapter(child: _ResaleBanner(onTap: () => Navigator.pushNamed(context, Routes.addProperty))),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),

          SliverToBoxAdapter(child: SectionHeader(context.tr('popular_areas'))),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.35),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final c = Cities.all[i];
                  final count = app.marketProperties.where((p) => p.city.en == c.en).length;
                  return _AreaTile(city: c, count: count, onTap: () => app.exploreWith((f) => f.city = c.en));
                },
                childCount: 6,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),

          SliverToBoxAdapter(child: SectionHeader(context.tr('recent'), onAction: () => app.exploreWith((f) => f.sort = SortBy.newest))),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) => FadeSlideIn(delayMs: 80 * i, child: PropertyCard(recent[i], heroPrefix: 'home-recent')),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, kNavSpace),
              child: Center(child: Text(context.tr('demo_data'), style: ts(context, 11, color: AppColors.muted))),
            ),
          ),
        ],
      ),
    );
  }

  void _openCalculator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const _Grabber(),
          const SizedBox(height: 12),
          const PaymentCalculator(price: 6000000, editablePrice: true),
        ]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppState app;
  const _Header({required this.app});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.forestDark, AppColors.forest]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
              child: Opacity(opacity: .16, child: NetImg(img(7, w: 1200))),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const BrandMark(size: 38),
                    const SizedBox(width: 8),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('DAMSTOCK', style: brandStyle(14, spacing: 2.5)),
                        Text('HOMES', style: brandStyle(8, color: AppColors.gold, w: FontWeight.w600, spacing: 5)),
                      ]),
                    ),
                    const Spacer(),
                    CircleBtn(Icons.notifications_none_rounded, dark: true, size: 42, badge: app.notifications.length, onTap: () => _showNotifications(context)),
                    const SizedBox(width: 10),
                    Pressable(
                      onTap: () => Navigator.pushNamed(context, Routes.profile),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [Color(0xFFE1C48F), AppColors.goldDeep]),
                          border: Border.all(color: AppColors.white.o(.4), width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: app.user != null
                            ? Text(app.user!.initial, style: ts(context, 17, w: FontWeight.w800, color: AppColors.forestDark))
                            : const Icon(Icons.person_rounded, color: AppColors.forestDark, size: 22),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 22),
                  Text(
                    app.user != null ? '${context.tr('hello')}${app.isAr ? '،' : ','} ${app.user!.name.split(' ').first}' : context.tr('hello_guest'),
                    style: ts(context, 14, w: FontWeight.w600, color: AppColors.white.o(.75)),
                  ),
                  const SizedBox(height: 4),
                  Text(context.tr('home_headline'), style: ts(context, 26, w: FontWeight.w800, color: AppColors.white, height: 1.25)),
                  const SizedBox(height: 4),
                  Text(context.tr('tagline'), style: ts(context, 13, w: FontWeight.w700, color: AppColors.gold, spacing: .4)),
                  const SizedBox(height: 18),
                  Pressable(
                    onTap: () => app.setTab(1),
                    child: Container(
                      height: 54,
                      padding: const EdgeInsetsDirectional.only(start: 16, end: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.o(.15), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Row(children: [
                        const Icon(Icons.search_rounded, color: AppColors.muted),
                        const SizedBox(width: 10),
                        Expanded(child: Text(context.tr('search_hint'), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 13.5, color: AppColors.muted))),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.tune_rounded, color: AppColors.gold, size: 20),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(children: [
                    _HeaderStat('2,400+', context.tr('stat_units')),
                    _HeaderStat('${MockData.projects.length * 15}+', context.tr('stat_projects')),
                    _HeaderStat('${MockData.developers.length * 8}+', context.tr('stat_devs')),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    final ar = app.isAr;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Center(child: _Grabber()),
            const SizedBox(height: 14),
            Text(S.get('notifications', ar), style: ts(ctx, 19, w: FontWeight.w800)),
            const SizedBox(height: 12),
            for (final n in app.notifications)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: cardDeco(r: 18),
                child: Row(children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(14)),
                    child: Icon(n.icon, color: AppColors.gold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(n.title.of(ar), style: ts(ctx, 14, w: FontWeight.w800)),
                      Text(n.body.of(ar), style: ts(ctx, 12.5, color: AppColors.muted)),
                    ]),
                  ),
                  Text(timeAgo(n.at, ar), style: ts(ctx, 10.5, color: AppColors.muted)),
                ]),
              ),
          ]),
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeaderStat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsetsDirectional.only(end: 8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white.o(.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.white.o(.12)),
          ),
          child: Column(children: [
            Text(value, style: ts(context, 16, w: FontWeight.w800, color: AppColors.gold)),
            Text(label, style: ts(context, 11, color: AppColors.white.o(.75))),
          ]),
        ),
      );
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CategoryTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: Pressable(
          onTap: onTap,
          child: SizedBox(
            width: 74,
            child: Column(children: [
              Container(
                width: 62,
                height: 62,
                decoration: cardDeco(r: 20),
                child: Icon(icon, color: AppColors.forest, size: 27),
              ),
              const SizedBox(height: 7),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 12, w: FontWeight.w700)),
            ]),
          ),
        ),
      );
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;
  const _ToolTile(this.icon, this.label, {required this.onTap, this.badge = 0});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Pressable(
          onTap: onTap,
          child: Container(
            height: 92,
            padding: const EdgeInsets.all(10),
            decoration: cardDeco(r: 20),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Stack(clipBehavior: Clip.none, children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.gold.o(.16), borderRadius: BorderRadius.circular(13)),
                  child: Icon(icon, color: AppColors.forest, size: 21),
                ),
                if (badge > 0)
                  PositionedDirectional(
                    top: -4,
                    end: -6,
                    child: CircleAvatar(radius: 9, backgroundColor: AppColors.forest, child: Text('$badge', style: ts(context, 10, w: FontWeight.w800, color: AppColors.gold))),
                  ),
              ]),
              const SizedBox(height: 7),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: ts(context, 11, w: FontWeight.w700)),
            ]),
          ),
        ),
      );
}

class _ResaleBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _ResaleBanner({required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Pressable(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE9D7B2), AppColors.gold]),
              boxShadow: [BoxShadow(color: AppColors.gold.o(.35), blurRadius: 24, offset: const Offset(0, 12))],
            ),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(context.tr('resale_banner_t'), style: ts(context, 17, w: FontWeight.w800, color: AppColors.forestDark)),
                  const SizedBox(height: 4),
                  Text(context.tr('resale_banner_b'), style: ts(context, 12.5, color: AppColors.forestDark.o(.75))),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(color: AppColors.forestDark, borderRadius: BorderRadius.circular(13)),
                    child: Text(context.tr('list_now'), style: ts(context, 13, w: FontWeight.w800, color: AppColors.gold)),
                  ),
                ]),
              ),
              const SizedBox(width: 10),
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.forestDark.o(.08)),
                child: const Icon(Icons.key_rounded, size: 42, color: AppColors.forestDark),
              ),
            ]),
          ),
        ),
      );
}

class _AreaTile extends StatelessWidget {
  final Tx city;
  final int count;
  final VoidCallback onTap;
  const _AreaTile({required this.city, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    return Pressable(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          Positioned.fill(child: NetImg(img(Cities.cover[city.en] ?? 0, w: 600))),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppColors.forestDark.o(.85)]),
              ),
            ),
          ),
          PositionedDirectional(
            start: 12,
            end: 12,
            bottom: 10,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(city.of(ar), style: ts(context, 15, w: FontWeight.w800, color: AppColors.white)),
              Text('$count ${context.tr('units_count')}', style: ts(context, 11.5, w: FontWeight.w600, color: AppColors.gold)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();
  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(3)),
      );
}
