import 'package:flutter/material.dart';

import '../core/l10n/strings.dart';
import '../core/router/routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/format.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import 'common.dart';

Color kindColor(ListingKind k) => switch (k) {
      ListingKind.primary => AppColors.forest,
      ListingKind.resale => AppColors.info,
      ListingKind.assignment => AppColors.warning,
    };

class PropertyCard extends StatelessWidget {
  final Property p;
  final String heroPrefix;
  final double? width;
  final double imageHeight;

  const PropertyCard(this.p, {super.key, required this.heroPrefix, this.width, this.imageHeight = 190});

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    final heroTag = '$heroPrefix-${p.id}';
    final monthly = p.monthly;
    return Pressable(
      onTap: () => Navigator.pushNamed(context, Routes.property, arguments: PropertyArgs(p.id, heroTag: heroTag)),
      child: Container(
        width: width,
        decoration: cardDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: imageHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: heroTag,
                      child: NetImg(p.cover, radius: const BorderRadius.vertical(top: Radius.circular(22))),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.o(.18), Colors.transparent, Colors.black.o(.35)],
                            stops: const [0, .45, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 12,
                    start: 12,
                    child: Wrap(spacing: 6, children: [
                      Tag(kindLabel(p.kind, ar), bg: kindColor(p.kind)),
                      if (p.pendingReview) Tag.gold(context.tr('pending_review')),
                      if (p.verified && !p.pendingReview) Tag.glass(context.tr('verified'), icon: Icons.verified_rounded),
                    ]),
                  ),
                  PositionedDirectional(top: 10, end: 10, child: FavButton(p.id)),
                  PositionedDirectional(
                    bottom: 12,
                    start: 12,
                    child: Row(children: [
                      Icon(typeIcon(p.type), size: 15, color: AppColors.white),
                      const SizedBox(width: 5),
                      Text(typeLabel(p.type, ar), style: ts(context, 12, w: FontWeight.w700, color: AppColors.white)),
                      if (p.isReady) ...[
                        const SizedBox(width: 8),
                        Tag.gold(context.tr('ready_now')),
                      ],
                    ]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(fmtPrice(p.price, ar), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 18, w: FontWeight.w800, color: AppColors.forest)),
                      ),
                      if (monthly != null)
                        Text('${fmtPrice(monthly, ar)}${context.tr('per_month')}', style: ts(context, 11, w: FontWeight.w600, color: AppColors.goldDeep)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(p.title.of(ar), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 15, w: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_rounded, size: 15, color: AppColors.gold),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text('${p.location.of(ar)} • ${p.city.of(ar)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 12, color: AppColors.muted)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Container(height: 1, color: AppColors.line),
                  const SizedBox(height: 10),
                  Row(children: [
                    if (p.beds > 0) ...[_Spec(Icons.king_bed_rounded, '${p.beds}'), const SizedBox(width: 14)],
                    _Spec(Icons.bathtub_rounded, '${p.baths}'),
                    const SizedBox(width: 14),
                    _Spec(Icons.square_foot_rounded, '${p.area} ${context.tr('sqm')}'),
                    const Spacer(),
                    Text(timeAgo(p.listedAt, ar), style: ts(context, 10.5, color: AppColors.muted)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String value;
  const _Spec(this.icon, this.value);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: AppColors.forestSoft),
        const SizedBox(width: 4),
        Text(value, style: ts(context, 12.5, w: FontWeight.w700)),
      ]);
}

class ProjectCard extends StatelessWidget {
  final Project project;
  final double height;
  final double? width;
  const ProjectCard(this.project, {super.key, this.height = 250, this.width});

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    final dev = MockData.developer(project.developerId);
    return Pressable(
      onTap: () => Navigator.pushNamed(context, Routes.project, arguments: project.id),
      child: Container(
        height: height,
        width: width,
        decoration: cardDeco(r: 26),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              Positioned.fill(child: Hero(tag: 'project-${project.id}-${height.round()}', child: NetImg(project.cover))),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.forestDark.o(.55), AppColors.forestDark.o(.95)],
                      stops: const [.25, .62, 1],
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 14,
                start: 14,
                child: Tag(projectStatusLabel(project.status, ar), bg: project.status == ProjectStatus.launch ? AppColors.gold : AppColors.forestDark.o(.6), fg: project.status == ProjectStatus.launch ? AppColors.forestDark : AppColors.white),
              ),
              PositionedDirectional(
                bottom: 16,
                start: 16,
                end: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dev != null)
                      Row(children: [
                        DeveloperLogo(dev, size: 24),
                        const SizedBox(width: 7),
                        Flexible(child: Text(dev.name.of(ar), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 12, w: FontWeight.w600, color: AppColors.white.o(.85)))),
                      ]),
                    const SizedBox(height: 6),
                    Text(project.name.of(ar), style: ts(context, 22, w: FontWeight.w800, color: AppColors.white, height: 1.2)),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.gold),
                      const SizedBox(width: 3),
                      Flexible(child: Text(project.city.of(ar), style: ts(context, 12.5, color: AppColors.white.o(.8)))),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(context.tr('starting_from'), style: ts(context, 11, color: AppColors.white.o(.7))),
                          Text(fmtPrice(project.startingPrice, ar), style: ts(context, 16, w: FontWeight.w800, color: AppColors.gold)),
                        ]),
                      ),
                      _GlassStat('${project.downPaymentPct}%', context.tr('down_payment')),
                      const SizedBox(width: 8),
                      _GlassStat('${project.installmentYears} ${context.tr('years_short')}', context.tr('installments')),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassStat extends StatelessWidget {
  final String value;
  final String label;
  const _GlassStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white.o(.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.white.o(.15)),
        ),
        child: Column(children: [
          Text(value, style: ts(context, 13, w: FontWeight.w800, color: AppColors.white)),
          Text(label, style: ts(context, 9.5, color: AppColors.white.o(.7))),
        ]),
      );
}

class ProjectTile extends StatelessWidget {
  final Project project;
  const ProjectTile(this.project, {super.key});

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    final dev = MockData.developer(project.developerId);
    return Pressable(
      onTap: () => Navigator.pushNamed(context, Routes.project, arguments: project.id),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: cardDeco(r: 20),
        child: Row(children: [
          NetImg(project.cover, width: 92, height: 92, radius: BorderRadius.circular(16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(project.name.of(ar), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 15.5, w: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('${dev?.name.of(ar) ?? ''} • ${project.city.of(ar)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 12, color: AppColors.muted)),
              const SizedBox(height: 8),
              Row(children: [
                Text(fmtPrice(project.startingPrice, ar), style: ts(context, 14, w: FontWeight.w800, color: AppColors.forest)),
                const Spacer(),
                Tag.soft('${context.tr('delivery')} ${project.deliveryYear}', color: AppColors.goldDeep),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: project.progress, minHeight: 4, backgroundColor: AppColors.sand, color: AppColors.gold),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class DeveloperLogo extends StatelessWidget {
  final Developer dev;
  final double size;
  const DeveloperLogo(this.dev, {super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [dev.color, Color.lerp(dev.color, Colors.black, .35)!]),
        border: Border.all(color: AppColors.gold.o(.7), width: size > 40 ? 2 : 1.2),
      ),
      alignment: Alignment.center,
      child: Text(dev.letter, style: brandStyle(size * .42, color: AppColors.gold, spacing: 0)),
    );
  }
}

class DeveloperCard extends StatelessWidget {
  final Developer dev;
  const DeveloperCard(this.dev, {super.key});

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    return Pressable(
      onTap: () => Navigator.pushNamed(context, Routes.developer, arguments: dev.id),
      child: Container(
        decoration: cardDeco(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 128,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(child: NetImg(MockData.developerCover(dev), radius: const BorderRadius.vertical(top: Radius.circular(22)))),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppColors.forestDark.o(.6)]),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 12,
                end: 12,
                child: Tag.glass(dev.rating.toStringAsFixed(1), icon: Icons.star_rounded),
              ),
              PositionedDirectional(bottom: -26, start: 16, child: DeveloperLogo(dev, size: 58)),
            ]),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 32, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(dev.name.of(ar), style: ts(context, 17, w: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(dev.tagline.of(ar), style: ts(context, 12.5, color: AppColors.muted)),
              const SizedBox(height: 14),
              Row(children: [
                _DevStat('${dev.projectsCount}', context.tr('projects')),
                _divider(),
                _DevStat('${fmtNum(dev.deliveredUnits)}+', context.tr('delivered_units')),
                _divider(),
                _DevStat('${dev.founded}', context.tr('founded')),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 28, color: AppColors.line, margin: const EdgeInsets.symmetric(horizontal: 12));
}

class _DevStat extends StatelessWidget {
  final String value;
  final String label;
  const _DevStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value, style: ts(context, 15, w: FontWeight.w800, color: AppColors.forest)),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 11, color: AppColors.muted)),
        ]),
      );
}
