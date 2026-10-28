import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      final app = context.appRead;
      Navigator.pushReplacementNamed(context, app.onboarded ? Routes.shell : Routes.onboarding);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Animation<double> _interval(double a, double b) => CurvedAnimation(parent: _c, curve: Interval(a, b, curve: Curves.easeOutCubic));

  @override
  Widget build(BuildContext context) {
    final mark = _interval(0, .55);
    final word = _interval(.3, .8);
    final tag = _interval(.55, 1);
    return Scaffold(
      backgroundColor: AppColors.forestDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -.2),
            radius: 1.1,
            colors: [AppColors.forestSoft, AppColors.forest, AppColors.forestDark],
            stops: [0, .45, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _LinesPainter())),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: Tween(begin: .6, end: 1.0).animate(mark),
                    child: FadeTransition(opacity: mark, child: const BrandMark(size: 96)),
                  ),
                  const SizedBox(height: 22),
                  FadeTransition(
                    opacity: word,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, .4), end: Offset.zero).animate(word),
                      child: const BrandWordmark(size: 30),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeTransition(
                    opacity: tag,
                    child: Text(context.tr('tagline'), style: ts(context, 15, w: FontWeight.w600, color: AppColors.white.o(.8), spacing: .5)),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: tag,
                child: Center(
                  child: SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(minHeight: 2, backgroundColor: Color(0x22FFFFFF), color: AppColors.gold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = AppColors.gold.o(.06)
      ..strokeWidth = 1;
    for (var i = 0; i < 9; i++) {
      final x = s.width * (i / 8);
      canvas.drawLine(Offset(x, 0), Offset(x - s.width * .3, s.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
