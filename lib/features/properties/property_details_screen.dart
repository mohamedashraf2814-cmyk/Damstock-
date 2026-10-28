import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
import '../../widgets/map_canvas.dart';
import '../../widgets/payment_calculator.dart';
import '../projects/project_details_screen.dart' show AmenityGrid;

class PropertyDetailsScreen extends StatefulWidget {
  final String id;
  final String? heroTag;
  const PropertyDetailsScreen({super.key, required this.id, this.heroTag});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  int _img = 0;
  final _scroll = ScrollController();
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final c = _scroll.offset > 300;
      if (c != _collapsed) setState(() => _collapsed = c);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _toggleCompare(AppState app, Property p) {
    HapticFeedback.selectionClick();
    final r = app.toggleCompare(p.id);
    final ar = app.isAr;
    switch (r) {
      case CompareResult.added:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.compare_arrows_rounded, color: AppColors.gold),
              const SizedBox(width: 10),
              Expanded(child: Text(S.get('compare_added', ar))),
            ]),
            action: SnackBarAction(label: S.get('view', ar), textColor: AppColors.gold, onPressed: () => Navigator.pushNamed(context, Routes.compare)),
          ));
      case CompareResult.removed:
        showSnack(context, S.get('compare_removed', ar), icon: Icons.remove_circle_outline_rounded);
      case CompareResult.full:
        showSnack(context, S.get('compare_full', ar), icon: Icons.info_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ar = app.isAr;
    final p = app.propertyById(widget.id);
    if (p == null) {
      return Scaffold(appBar: AppBar(), body: EmptyState(icon: Icons.home_work_outlined, title: context.tr('no_results'), subtitle: ''));
    }
    final dev = MockData.developer(p.developerId);
    final project = MockData.project(p.projectId);
    final similar = app.marketProperties.where((o) => o.id != p.id && (o.city.en == p.city.en || o.type == p.type)).take(6).toList();
    final top = MediaQuery.paddingOf(context).top;
    final inCompare = app.inCompare(p.id);

    return Scaffold(
      body: Stack(children: [
        CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 400,
                child: Stack(children: [
                  Positioned.fill(
                    child: PageView.builder(
                      itemCount: p.images.length,
                      onPageChanged: (i) => setState(() => _img = i),
                      itemBuilder: (context, i) {
                        final image = GestureDetector(onTap: () => _openGallery(context, p, i), child: NetImg(p.images[i]));
                        return i == 0 && widget.heroTag != null ? Hero(tag: widget.heroTag!, child: image) : image;
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.o(.35), Colors.transparent, Colors.black.o(.45)],
                            stops: const [0, .4, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 40,
                    start: 20,
                    child: Wrap(spacing: 6, children: [
                      Tag(kindLabel(p.kind, ar), bg: kindColor(p.kind)),
                      if (p.verified && !p.pendingReview) Tag.glass(context.tr('verified'), icon: Icons.verified_rounded),
                      if (p.pendingReview) Tag.gold(context.tr('pending_review')),
                      if (p.negotiable) Tag.glass(context.tr('negotiable')),
                    ]),
                  ),
                  PositionedDirectional(
                    bottom: 42,
                    end: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.black.o(.45), borderRadius: BorderRadius.circular(10)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.photo_library_rounded, size: 14, color: AppColors.white),
                        const SizedBox(width: 5),
                        Text('${_img + 1}/${p.images.length}', style: ts(context, 12, w: FontWeight.w700, color: AppColors.white)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -26),
                child: Container(
                  decoration: const BoxDecoration(color: AppColors.ivory, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(fmtFull(p.price, ar), style: ts(context, 24, w: FontWeight.w800, color: AppColors.forest)),
                          if (p.monthly != null)
                            Text('${fmtFull(p.monthly!, ar)} ${context.tr('per_month')}', style: ts(context, 13, w: FontWeight.w700, color: AppColors.goldDeep)),
                        ]),
                      ),
                      Pressable(
                        onTap: () => _toggleCompare(app, p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: inCompare ? AppColors.forest : AppColors.white,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: inCompare ? AppColors.forest : AppColors.line),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(inCompare ? Icons.check_rounded : Icons.compare_arrows_rounded, size: 17, color: inCompare ? AppColors.gold : AppColors.forest),
                            const SizedBox(width: 5),
                            Text(context.tr(inCompare ? 'in_compare' : 'add_compare'), style: ts(context, 12, w: FontWeight.w800, color: inCompare ? AppColors.white : AppColors.forest)),
                          ]),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(p.title.of(ar), style: ts(context, 21, w: FontWeight.w800, height: 1.3)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on_rounded, size: 17, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Expanded(child: Text('${p.location.of(ar)} • ${p.city.of(ar)}', style: ts(context, 13.5, color: AppColors.muted))),
                    ]),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: cardDeco(r: 20),
                      child: Row(children: [
                        if (p.beds > 0) _SpecBox(Icons.king_bed_rounded, '${p.beds}', context.tr('beds')),
                        _SpecBox(Icons.bathtub_rounded, '${p.baths}', context.tr('baths')),
                        _SpecBox(Icons.square_foot_rounded, '${p.area}', context.tr('sqm')),
                        _SpecBox(Icons.layers_rounded, p.floor == null ? '—' : (p.floor == 0 ? context.tr('ground') : '${p.floor}'), context.tr('floor')),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: cardDeco(r: 20),
                      child: Column(children: [
                        _InfoRow(context.tr('type'), typeLabel(p.type, ar)),
                        _InfoRow(context.tr('finishing'), finishLabel(p.finish, ar)),
                        _InfoRow(context.tr('delivery'), p.isReady ? context.tr('ready_now') : '${p.deliveryYear}'),
                        _InfoRow(context.tr('price_per_m'), fmtFull(p.pricePerMeter, ar)),
                        if (p.sellerName != null) _InfoRow(context.tr('seller'), p.sellerName!, last: true) else _InfoRow(context.tr('listing_kind'), kindLabel(p.kind, ar), last: true),
                      ]),
                    ),
                    if (p.kind == ListingKind.assignment && p.paidAmount != null) ...[
                      const SizedBox(height: 14),
                      _AssignmentCard(p),
                    ],
                    if (dev != null || project != null) ...[
                      const SizedBox(height: 14),
                      Pressable(
                        onTap: () => project != null
                            ? Navigator.pushNamed(context, Routes.project, arguments: project.id)
                            : Navigator.pushNamed(context, Routes.developer, arguments: dev!.id),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: cardDeco(r: 20),
                          child: Row(children: [
                            if (project != null)
                              NetImg(project.cover, width: 56, height: 56, radius: BorderRadius.circular(14))
                            else
                              DeveloperLogo(dev!, size: 56),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(context.tr(project != null ? 'project' : 'developer'), style: ts(context, 11, color: AppColors.muted)),
                                Text(project?.name.of(ar) ?? dev!.name.of(ar), style: ts(context, 15, w: FontWeight.w800)),
                                if (project != null && dev != null) Text(dev.name.of(ar), style: ts(context, 12, color: AppColors.goldDeep, w: FontWeight.w700)),
                              ]),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                          ]),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Text(context.tr('about_property'), style: ts(context, 18, w: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(p.description.of(ar), style: ts(context, 14, color: AppColors.muted, height: 1.75)),
                    if (p.amenities.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      Text(context.tr('amenities'), style: ts(context, 18, w: FontWeight.w800)),
                      const SizedBox(height: 12),
                      AmenityGrid(p.amenities),
                    ],
                    if (p.installmentYears != null) ...[
                      const SizedBox(height: 22),
                      PaymentCalculator(
                        price: p.price,
                        initialDownPct: ((p.downPayment ?? 0) / p.price * 100).round(),
                        initialYears: p.installmentYears!,
                      ),
                    ],
                    const SizedBox(height: 22),
                    Text(context.tr('location'), style: ts(context, 18, w: FontWeight.w800)),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: MiniMap(x: p.x, y: p.y, label: context.tr('open_map'), onTap: () => Navigator.pushNamed(context, Routes.map))),
                  ]),
                ),
              ),
            ),
            if (similar.isNotEmpty) ...[
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(bottom: 12), child: SectionHeader(context.tr('similar')))),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 348,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    itemCount: similar.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, i) => PropertyCard(similar[i], heroPrefix: 'sim-${p.id}', width: 272, imageHeight: 170),
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.fromLTRB(16, top + 8, 16, 10),
            decoration: BoxDecoration(
              color: _collapsed ? AppColors.ivory : Colors.transparent,
              boxShadow: _collapsed ? [BoxShadow(color: AppColors.forestDark.o(.06), blurRadius: 16)] : null,
            ),
            child: Row(children: [
              CircleBtn(Icons.arrow_back_rounded, dark: !_collapsed, onTap: () => Navigator.pop(context)),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _collapsed ? 1 : 0,
                  child: Text(p.title.of(ar), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 15, w: FontWeight.w800)),
                ),
              ),
              CircleBtn(Icons.share_rounded, dark: !_collapsed, onTap: () => showSnack(context, context.tr('shared'), icon: Icons.link_rounded)),
              const SizedBox(width: 8),
              FavButton(p.id, size: 44),
            ]),
          ),
        ),
      ]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.forestDark.o(.08), blurRadius: 24, offset: const Offset(0, -8))]),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(children: [
              _RoundAction(Icons.phone_rounded, () => showSnack(context, context.tr('calling'), icon: Icons.phone_in_talk_rounded)),
              const SizedBox(width: 8),
              _RoundAction(Icons.chat_rounded, () => showSnack(context, context.tr('opening_whatsapp'), icon: Icons.chat_rounded), color: const Color(0xFF25D366)),
              const SizedBox(width: 8),
              _RoundAction(Icons.mail_outline_rounded, () => Navigator.pushNamed(context, Routes.inquiryNew, arguments: InquiryArgs(type: InquiryType.info, propertyId: p.id))),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  context.tr('book_viewing'),
                  icon: Icons.event_available_rounded,
                  style: BtnStyle.gold,
                  onTap: () => Navigator.pushNamed(context, Routes.inquiryNew, arguments: InquiryArgs(type: InquiryType.viewing, propertyId: p.id)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _openGallery(BuildContext context, Property p, int start) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (_, __, ___) => _FullGallery(images: p.images, start: start),
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    ));
  }
}

class _SpecBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _SpecBox(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.gold.o(.15), borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, size: 20, color: AppColors.forest),
          ),
          const SizedBox(height: 6),
          Text(value, style: ts(context, 15, w: FontWeight.w800)),
          Text(label, style: ts(context, 11, color: AppColors.muted)),
        ]),
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool last;
  const _InfoRow(this.label, this.value, {this.last = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: AppColors.line))),
        child: Row(children: [
          Text(label, style: ts(context, 13.5, color: AppColors.muted)),
          const Spacer(),
          Text(value, style: ts(context, 14, w: FontWeight.w800)),
        ]),
      );
}

class _AssignmentCard extends StatelessWidget {
  final Property p;
  const _AssignmentCard(this.p);

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    final paid = p.paidAmount ?? 0;
    final contract = p.originalPrice ?? p.price;
    final over = p.price - contract;
    final ratio = contract == 0 ? 0.0 : (paid / contract).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.forest, AppColors.forestDark]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.swap_horiz_rounded, color: AppColors.gold),
          const SizedBox(width: 8),
          Text(kindLabel(ListingKind.assignment, ar), style: ts(context, 16, w: FontWeight.w800, color: AppColors.white)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _Mini(context.tr('original_price'), fmtPrice(contract, ar)),
          _Mini(context.tr('paid_amount'), fmtPrice(paid, ar)),
          _Mini(context.tr('remaining'), fmtPrice(contract - paid, ar)),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: ratio, minHeight: 8, backgroundColor: AppColors.white.o(.15), color: AppColors.gold),
        ),
        const SizedBox(height: 10),
        Text(
          '${context.tr('overprice')}: ${over >= 0 ? fmtFull(over, ar) : '−${fmtFull(-over, ar)}'}  •  ${context.tr('assignment_note')}',
          style: ts(context, 11.5, color: AppColors.white.o(.75)),
        ),
      ]),
    );
  }
}

class _Mini extends StatelessWidget {
  final String label;
  final String value;
  const _Mini(this.label, this.value);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(context, 11, color: AppColors.white.o(.65))),
          const SizedBox(height: 2),
          Text(value, style: ts(context, 14, w: FontWeight.w800, color: AppColors.gold)),
        ]),
      );
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _RoundAction(this.icon, this.onTap, {this.color = AppColors.forest});

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        scale: .9,
        child: Container(
          width: 50,
          height: 54,
          decoration: BoxDecoration(
            color: color.o(.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      );
}

class _FullGallery extends StatefulWidget {
  final List<String> images;
  final int start;
  const _FullGallery({required this.images, required this.start});

  @override
  State<_FullGallery> createState() => _FullGalleryState();
}

class _FullGalleryState extends State<_FullGallery> {
  late int _i = widget.start;
  late final _pc = PageController(initialPage: widget.start);

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        PageView.builder(
          controller: _pc,
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _i = i),
          itemBuilder: (_, i) => InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(child: NetImg(widget.images[i], fit: BoxFit.contain, width: double.infinity)),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleBtn(Icons.close_rounded, dark: true, onTap: () => Navigator.pop(context)),
              const Spacer(),
              Text('${_i + 1} / ${widget.images.length}', style: ts(context, 14, w: FontWeight.w700, color: AppColors.white)),
            ]),
          ),
        ),
      ]),
    );
  }
}
