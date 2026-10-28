import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/models.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/map_canvas.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _tc = TransformationController();
  ListingKind? _kind;
  String? _selected;
  bool _centered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_centered) {
      final size = MediaQuery.sizeOf(context);
      final mapW = size.width * 1.9;
      final mapH = size.height * 1.25;
      _tc.value = Matrix4.translationValues(-(mapW * .55 - size.width / 2), -(mapH * .55 - size.height / 2), 0);
      _centered = true;
    }
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ar = app.isAr;
    final size = MediaQuery.sizeOf(context);
    final mapW = size.width * 1.9;
    final mapH = size.height * 1.25;
    final props = app.marketProperties.where((p) => _kind == null || p.kind == _kind).toList();
    Property? sel;
    for (final p in props) {
      if (p.id == _selected) sel = p;
    }

    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _tc,
            constrained: false,
            minScale: .6,
            maxScale: 2.5,
            boundaryMargin: const EdgeInsets.all(80),
            child: SizedBox(
              width: mapW,
              height: mapH,
              child: Stack(children: [
                const Positioned.fill(child: MapBackdrop()),
                Positioned.fill(
                  child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => setState(() => _selected = null)),
                ),
                for (final p in props)
                  Positioned(
                    left: p.x * mapW - 40,
                    top: p.y * mapH - 40,
                    child: _PricePin(
                      label: fmtShort(p.price),
                      kind: p.kind,
                      selected: p.id == _selected,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selected = p.id);
                      },
                    ),
                  ),
              ]),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleBtn(Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: AlignmentDirectional.centerStart,
                    decoration: cardDeco(r: 15),
                    child: Text('${context.tr('map_title')} • ${props.length}', style: ts(context, 14, w: FontWeight.w800)),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  Pill(context.tr('all'), dense: true, selected: _kind == null, onTap: () => setState(() => _kind = null)),
                  for (final k in ListingKind.values) ...[
                    const SizedBox(width: 8),
                    Pill(kindLabel(k, ar), dense: true, selected: _kind == k, onTap: () => setState(() => _kind = k)),
                  ],
                ]),
              ),
            ]),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 0,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (c, a) => SlideTransition(
                position: Tween(begin: const Offset(0, .3), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                child: FadeTransition(opacity: a, child: c),
              ),
              child: sel == null
                  ? Container(
                      key: const ValueKey('hint'),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: AppColors.forestDark, borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        const Icon(Icons.touch_app_rounded, color: AppColors.gold, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(context.tr('map_hint'), style: ts(context, 13, w: FontWeight.w600, color: AppColors.white))),
                      ]),
                    )
                  : _MapPreview(key: ValueKey(sel.id), p: sel),
            ),
          ),
        ),
      ]),
    );
  }
}

class _PricePin extends StatelessWidget {
  final String label;
  final ListingKind kind;
  final bool selected;
  final VoidCallback onTap;
  const _PricePin({required this.label, required this.kind, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.gold : kindColor(kind);
    final fg = selected ? AppColors.forestDark : AppColors.white;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        height: 48,
        child: Column(children: [
          AnimatedScale(
            scale: selected ? 1.15 : 1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.white, width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.o(.2), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Text(label, style: ts(context, 12, w: FontWeight.w800, color: fg, height: 1.1)),
            ),
          ),
          CustomPaint(size: const Size(12, 7), painter: _TrianglePainter(bg)),
        ]),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(s.width, 0)
      ..lineTo(s.width / 2, s.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) => old.color != color;
}

class _MapPreview extends StatelessWidget {
  final Property p;
  const _MapPreview({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    final tag = 'map-${p.id}';
    return Pressable(
      onTap: () => Navigator.pushNamed(context, Routes.property, arguments: PropertyArgs(p.id, heroTag: tag)),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: cardDeco(),
        child: Row(children: [
          Hero(tag: tag, child: NetImg(p.cover, width: 100, height: 100, radius: BorderRadius.circular(16))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Tag(kindLabel(p.kind, ar), bg: kindColor(p.kind)),
              const SizedBox(height: 6),
              Text(p.title.of(ar), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 14.5, w: FontWeight.w800)),
              Text('${p.city.of(ar)} • ${p.area} ${context.tr('sqm')}', style: ts(context, 12, color: AppColors.muted)),
              const SizedBox(height: 6),
              Text(fmtPrice(p.price, ar), style: ts(context, 16, w: FontWeight.w800, color: AppColors.forest)),
            ]),
          ),
          FavButton(p.id),
        ]),
      ),
    );
  }
}
