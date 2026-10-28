import 'package:flutter/material.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';

class MapBackdrop extends StatelessWidget {
  final bool showLabels;
  const MapBackdrop({super.key, this.showLabels = true});

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    return LayoutBuilder(builder: (context, c) {
      return Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _MapPainter())),
        if (showLabels)
          for (final city in Cities.all)
            Positioned(
              left: (Cities.pos[city.en]!.dx * c.maxWidth) - 50,
              top: (Cities.pos[city.en]!.dy * c.maxHeight) + 22,
              width: 100,
              child: IgnorePointer(
                child: Text(
                  city.of(ar),
                  textAlign: TextAlign.center,
                  style: ts(context, 10.5, w: FontWeight.w800, color: AppColors.forest.o(.55)),
                ),
              ),
            ),
      ]);
    });
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFF1ECE1));

    final sea = Path()
      ..moveTo(0, 0)
      ..lineTo(s.width, 0)
      ..lineTo(s.width, s.height * .05)
      ..quadraticBezierTo(s.width * .6, s.height * .1, s.width * .35, s.height * .06)
      ..quadraticBezierTo(s.width * .15, s.height * .1, 0, s.height * .14)
      ..close();
    canvas.drawPath(sea, Paint()..color = const Color(0xFFCFE3E3));

    final gulf = Path()
      ..moveTo(s.width, s.height * .62)
      ..quadraticBezierTo(s.width * .93, s.height * .78, s.width * .95, s.height)
      ..lineTo(s.width, s.height)
      ..close();
    canvas.drawPath(gulf, Paint()..color = const Color(0xFFCFE3E3));

    final dots = Paint()..color = AppColors.gold.o(.12);
    for (var i = 0; i < 160; i++) {
      final x = ((i * 73) % 1000) / 1000 * s.width;
      final y = ((i * 131) % 1000) / 1000 * s.height;
      if (y > s.height * .16) canvas.drawCircle(Offset(x, y), 1.4, dots);
    }

    final green = Paint()..color = const Color(0xFFDDE7D9);
    for (final o in Cities.pos.values) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(o.dx * s.width, o.dy * s.height), width: s.width * .16, height: s.height * .07), const Radius.circular(18)),
        green,
      );
    }

    final nile = Path()
      ..moveTo(s.width * .48, s.height)
      ..cubicTo(s.width * .5, s.height * .8, s.width * .44, s.height * .65, s.width * .5, s.height * .52)
      ..cubicTo(s.width * .52, s.height * .4, s.width * .45, s.height * .28, s.width * .5, s.height * .1);
    canvas.drawPath(
      nile,
      Paint()
        ..color = const Color(0xFFA9CDD0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    final road = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final roadEdge = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    Offset p(String city) => Offset(Cities.pos[city]!.dx * s.width, Cities.pos[city]!.dy * s.height);
    final links = [
      ['Sheikh Zayed', 'New Cairo'],
      ['6th of October', 'Sheikh Zayed'],
      ['New Cairo', 'New Capital'],
      ['New Cairo', 'Mostakbal City'],
      ['New Capital', 'Ain Sokhna'],
      ['Sheikh Zayed', 'North Coast'],
      ['North Coast', 'New Alamein'],
      ['6th of October', 'New Cairo'],
    ];
    for (final l in links) {
      final a = p(l[0]);
      final b = p(l[1]);
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 - 12);
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, b.dx, b.dy);
      canvas.drawPath(path, roadEdge);
      canvas.drawPath(path, road);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MiniMap extends StatelessWidget {
  final double x;
  final double y;
  final String label;
  final VoidCallback? onTap;
  const MiniMap({super.key, required this.x, required this.y, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: cardDecoMap(),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(builder: (context, c) {
          const zoom = 2.0;
          final w = c.maxWidth * zoom;
          final h = c.maxHeight * zoom * 1.4;
          final left = (c.maxWidth / 2 - x * w).clamp(c.maxWidth - w, 0.0);
          final top = (c.maxHeight / 2 - y * h).clamp(c.maxHeight - h, 0.0);
          return Stack(children: [
            Positioned(left: left, top: top, width: w, height: h, child: const MapBackdrop()),
            Positioned(
              left: left + x * w - 22,
              top: top + y * h - 50,
              child: const _Pin(),
            ),
            PositionedDirectional(
              bottom: 12,
              start: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.open_in_full_rounded, size: 15, color: AppColors.forest),
                  const SizedBox(width: 6),
                  Text(label, style: ts(context, 12, w: FontWeight.w800, color: AppColors.forest)),
                ]),
              ),
            ),
          ]);
        }),
      ),
    );
  }
}

BoxDecoration cardDecoMap() => BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.line),
    );

class _Pin extends StatelessWidget {
  const _Pin();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 44,
        height: 50,
        child: Stack(alignment: Alignment.topCenter, children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.forest,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 3),
              boxShadow: [BoxShadow(color: AppColors.forestDark.o(.35), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: const Icon(Icons.home_rounded, color: AppColors.gold, size: 22),
          ),
        ]),
      );
}
