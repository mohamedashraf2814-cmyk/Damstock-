import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../widgets/common.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _i = 0;

  static final _pages = [
    (img(2, w: 1400), 'ob1_title', 'ob1_body', Icons.travel_explore_rounded),
    (img(7, w: 1400), 'ob2_title', 'ob2_body', Icons.insights_rounded),
    (img(13, w: 1400), 'ob3_title', 'ob3_body', Icons.key_rounded),
  ];

  void _finish() {
    context.appRead.completeOnboarding();
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  void _next() {
    if (_i == _pages.length - 1) return _finish();
    _pc.nextPage(duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final last = _i == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.forestDark,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pc,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _i = i),
            itemBuilder: (context, i) {
              return AnimatedBuilder(
                animation: _pc,
                builder: (context, child) {
                  double delta = 0;
                  if (_pc.hasClients && _pc.position.haveDimensions) delta = (_pc.page ?? 0) - i;
                  return Transform.scale(scale: 1 + delta.abs() * .08, child: child);
                },
                child: NetImg(_pages[i].$1, width: double.infinity, height: double.infinity),
              );
            },
          ),
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.forestDark.o(.55), Colors.transparent, AppColors.forestDark.o(.85), AppColors.forestDark],
                  stops: const [0, .3, .62, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
              child: Column(
                children: [
                  Row(children: [
                    const BrandMark(size: 40),
                    const SizedBox(width: 8),
                    Text('DAMSTOCK', style: brandStyle(15, spacing: 3)),
                    const Spacer(),
                    Pressable(
                      onTap: app.toggleLocale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.white.o(.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.white.o(.2)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.translate_rounded, size: 16, color: AppColors.gold),
                          const SizedBox(width: 6),
                          Text(app.isAr ? 'English' : 'العربية', style: ts(context, 12.5, w: FontWeight.w700, color: AppColors.white)),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!last)
                      Pressable(
                        onTap: _finish,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(context.tr('skip'), style: ts(context, 14, w: FontWeight.w700, color: AppColors.white.o(.85))),
                        ),
                      ),
                  ]),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    transitionBuilder: (c, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(position: Tween(begin: const Offset(0, .15), end: Offset.zero).animate(a), child: c),
                    ),
                    child: Column(
                      key: ValueKey(_i),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.gold.o(.16), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gold.o(.4))),
                          child: Icon(_pages[_i].$4, color: AppColors.gold, size: 26),
                        ),
                        const SizedBox(height: 18),
                        Text(context.tr(_pages[_i].$2), style: ts(context, 32, w: FontWeight.w800, color: AppColors.white, height: 1.2)),
                        const SizedBox(height: 12),
                        Text(context.tr(_pages[_i].$3), style: ts(context, 15.5, color: AppColors.white.o(.78), height: 1.65)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(children: [
                    for (var k = 0; k < _pages.length; k++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsetsDirectional.only(end: 6),
                        width: k == _i ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: k == _i ? AppColors.gold : AppColors.white.o(.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    const Spacer(),
                    AppButton(
                      context.tr(last ? 'get_started' : 'next'),
                      onTap: _next,
                      style: BtnStyle.gold,
                      expand: false,
                      icon: last ? Icons.arrow_forward_rounded : null,
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
