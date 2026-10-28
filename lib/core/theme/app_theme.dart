import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static final Map<bool, ThemeData> _cache = {};

  static ThemeData of(bool isAr) => _cache.putIfAbsent(isAr, () => _build(isAr));

  static ThemeData _build(bool isAr) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.ivory,
      splashFactory: InkRipple.splashFactory,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.forest,
        primary: AppColors.forest,
        secondary: AppColors.gold,
        surface: AppColors.white,
      ),
    );

    final text = (isAr
            ? GoogleFonts.cairoTextTheme(base.textTheme)
            : GoogleFonts.interTextTheme(base.textTheme))
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.line),
    );

    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ivory,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.ink,
        centerTitle: true,
        titleTextStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 17),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: text.bodyMedium?.copyWith(color: AppColors.muted.o(.8)),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
        errorBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.danger)),
        focusedErrorBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.danger, width: 1.5)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.forest,
        inactiveTrackColor: AppColors.line,
        thumbColor: AppColors.gold,
        overlayColor: AppColors.gold.o(.18),
        trackHeight: 4,
        valueIndicatorColor: AppColors.forestDark,
        rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 11),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.forestDark,
        contentTextStyle: text.bodyMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.ivory,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.white : AppColors.muted),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.forest : AppColors.line),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.forest : Colors.transparent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.gold),
    );
  }
}

TextStyle ts(
  BuildContext context,
  double size, {
  FontWeight w = FontWeight.w500,
  Color? color,
  double? height,
  double? spacing,
}) {
  return Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontSize: size,
        fontWeight: w,
        color: color ?? AppColors.ink,
        height: height ?? 1.4,
        letterSpacing: spacing,
      );
}

TextStyle brandStyle(double size, {Color color = AppColors.white, FontWeight w = FontWeight.w800, double spacing = 2}) {
  return GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: w, color: color, letterSpacing: spacing, height: 1.1);
}
