import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common.dart';

Future<bool?> showSuccessDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String primary,
  required String secondary,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.forestDark.o(.55),
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (ctx, _, __) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.sizeOf(ctx).width - 48,
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
          decoration: BoxDecoration(color: AppColors.ivory, borderRadius: BorderRadius.circular(30)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (context, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.forestSoft, AppColors.forestDark]),
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.gold, size: 46),
              ),
            ),
            const SizedBox(height: 20),
            Text(title, textAlign: TextAlign.center, style: ts(ctx, 20, w: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center, style: ts(ctx, 13.5, color: AppColors.muted, height: 1.6)),
            const SizedBox(height: 22),
            AppButton(primary, onTap: () => Navigator.pop(ctx, true), style: BtnStyle.gold),
            const SizedBox(height: 10),
            AppButton(secondary, onTap: () => Navigator.pop(ctx, false), style: BtnStyle.outline),
          ]),
        ),
      ),
    ),
    transitionBuilder: (ctx, a, __, child) => FadeTransition(
      opacity: a,
      child: ScaleTransition(scale: Tween(begin: .9, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: child),
    ),
  );
}
