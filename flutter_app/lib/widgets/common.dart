import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/l10n/strings.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

const double kNavSpace = 116;

BoxDecoration cardDeco({double r = 22, Color color = AppColors.white, bool border = false}) => BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(r),
      border: border ? Border.all(color: AppColors.line) : null,
      boxShadow: [
        BoxShadow(color: AppColors.forestDark.o(.06), blurRadius: 26, offset: const Offset(0, 12)),
      ],
    );

class NetImg extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? radius;

  const NetImg(this.url, {super.key, this.fit = BoxFit.cover, this.width, this.height, this.radius});

  @override
  Widget build(BuildContext context) {
    Widget w = Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      frameBuilder: (ctx, child, frame, sync) {
        if (sync) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (ctx, e, s) => Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.forestSoft, AppColors.forestDark],
          ),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.apartment_rounded, color: AppColors.gold.o(.55), size: 34),
      ),
    );
    w = ColoredBox(color: AppColors.sand, child: w);
    if (radius != null) w = ClipRRect(borderRadius: radius!, child: w);
    return w;
  }
}

class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.97});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

enum BtnStyle { gold, forest, outline, light }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final BtnStyle style;
  final bool expand;
  final double height;
  final bool loading;

  const AppButton(
    this.label, {
    super.key,
    this.onTap,
    this.icon,
    this.style = BtnStyle.forest,
    this.expand = true,
    this.height = 54,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final (Color? bg, Gradient? grad, Color fg, Color? border) = switch (style) {
      BtnStyle.gold => (null, const LinearGradient(colors: [Color(0xFFE1C48F), AppColors.gold, AppColors.goldDeep]), AppColors.forestDark, null),
      BtnStyle.forest => (AppColors.forest, null, AppColors.white, null),
      BtnStyle.outline => (Colors.transparent, null, AppColors.forest, AppColors.forest.o(.25)),
      BtnStyle.light => (AppColors.white.o(.14), null, AppColors.white, AppColors.white.o(.25)),
    };
    return Pressable(
      onTap: loading ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onTap == null ? .5 : 1,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: bg,
            gradient: grad,
            borderRadius: BorderRadius.circular(17),
            border: border != null ? Border.all(color: border, width: 1.2) : null,
            boxShadow: style == BtnStyle.gold || style == BtnStyle.forest
                ? [BoxShadow(color: (style == BtnStyle.gold ? AppColors.gold : AppColors.forest).o(.28), blurRadius: 18, offset: const Offset(0, 8))]
                : null,
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
              else ...[
                if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 8)],
                Flexible(
                  child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 15, w: FontWeight.w700, color: fg)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool dark;
  final double size;
  final Color? iconColor;
  final int? badge;

  const CircleBtn(this.icon, {super.key, this.onTap, this.dark = false, this.size = 44, this.iconColor, this.badge});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: .9,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dark ? AppColors.white.o(.12) : AppColors.white,
              border: Border.all(color: dark ? AppColors.white.o(.18) : AppColors.line),
              boxShadow: dark ? null : [BoxShadow(color: AppColors.forestDark.o(.06), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: Icon(icon, size: size * .47, color: iconColor ?? (dark ? AppColors.white : AppColors.ink)),
          ),
          if (badge != null && badge! > 0)
            PositionedDirectional(
              top: -2,
              end: -2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18),
                height: 18,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(9), border: Border.all(color: AppColors.white, width: 1.5)),
                child: Text('$badge', style: ts(context, 10, w: FontWeight.w800, color: AppColors.forestDark, height: 1)),
              ),
            ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;
  final EdgeInsetsGeometry padding;

  const SectionHeader(this.title, {super.key, this.subtitle, this.onAction, this.actionLabel, this.padding = const EdgeInsets.symmetric(horizontal: 20)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ts(context, 19, w: FontWeight.w800, height: 1.25)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: ts(context, 12.5, color: AppColors.muted)),
                ],
              ],
            ),
          ),
          if (onAction != null)
            Pressable(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(actionLabel ?? context.tr('see_all'), style: ts(context, 13, w: FontWeight.w700, color: AppColors.goldDeep)),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.goldDeep),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;
  final double size;
  const Tag(this.label, {super.key, this.bg = AppColors.forest, this.fg = AppColors.white, this.icon, this.size = 11});

  factory Tag.gold(String label, {IconData? icon}) => Tag(label, bg: AppColors.gold, fg: AppColors.forestDark, icon: icon);
  factory Tag.glass(String label, {IconData? icon}) => Tag(label, bg: AppColors.forestDark.o(.55), fg: AppColors.white, icon: icon);
  factory Tag.soft(String label, {IconData? icon, Color color = AppColors.forest}) => Tag(label, bg: color.o(.1), fg: color, icon: icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: size + 2, color: fg), const SizedBox(width: 4)],
          Text(label, style: ts(context, size, w: FontWeight.w700, color: fg, height: 1.2)),
        ],
      ),
    );
  }
}

class FavButton extends StatelessWidget {
  final String propertyId;
  final double size;
  const FavButton(this.propertyId, {super.key, this.size = 38});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final fav = app.isFav(propertyId);
    return Pressable(
      scale: .85,
      onTap: () {
        HapticFeedback.lightImpact();
        app.toggleFav(propertyId);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.o(.92),
          boxShadow: [BoxShadow(color: Colors.black.o(.12), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (c, a) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.elasticOut), child: c),
          child: Icon(
            fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(fav),
            size: size * .52,
            color: fav ? AppColors.danger : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final double dy;
  const FadeSlideIn({super.key, required this.child, this.delayMs = 0, this.dy = 18});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (context, child) => Opacity(
        opacity: _a.value,
        child: Transform.translate(offset: Offset(0, widget.dy * (1 - _a.value)), child: child),
      ),
      child: widget.child,
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.gold.o(.25), AppColors.gold.o(.08)]),
                ),
                child: Icon(icon, size: 42, color: AppColors.forest),
              ),
              const SizedBox(height: 22),
              Text(title, textAlign: TextAlign.center, style: ts(context, 18, w: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(subtitle, textAlign: TextAlign.center, style: ts(context, 13.5, color: AppColors.muted, height: 1.6)),
              if (actionLabel != null) ...[
                const SizedBox(height: 24),
                AppButton(actionLabel!, onTap: onAction, expand: false, style: BtnStyle.forest),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool dense;
  const Pill(this.label, {super.key, this.selected = false, this.onTap, this.icon, this.dense = false});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: .94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: dense ? 12 : 16, vertical: dense ? 7 : 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.forest : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.forest : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: selected ? AppColors.gold : AppColors.muted),
              const SizedBox(width: 6),
            ],
            Text(label, style: ts(context, dense ? 12.5 : 13.5, w: FontWeight.w700, color: selected ? AppColors.white : AppColors.ink)),
          ],
        ),
      ),
    );
  }
}

class Segmented extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final bool dark;
  const Segmented({super.key, required this.labels, required this.index, required this.onChanged, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark ? AppColors.white.o(.1) : AppColors.sand,
        borderRadius: BorderRadius.circular(15),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth / labels.length;
          final rtl = Directionality.of(context) == TextDirection.rtl;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: rtl ? null : w * index,
                right: rtl ? w * index : null,
                top: 0,
                bottom: 0,
                width: w,
                child: Container(
                  decoration: BoxDecoration(
                    color: dark ? AppColors.gold : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: AppColors.forestDark.o(.08), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: ts(
                              context,
                              13.5,
                              w: FontWeight.w700,
                              color: i == index ? (dark ? AppColors.forestDark : AppColors.forest) : (dark ? AppColors.white.o(.75) : AppColors.muted),
                            ),
                            child: Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RoofPainter(),
        child: Align(
          alignment: const Alignment(0, .55),
          child: Text('D', style: brandStyle(size * .46, color: AppColors.gold, spacing: 0)),
        ),
      ),
    );
  }
}

class _RoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * .065
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(s.width * .1, s.height * .44)
      ..lineTo(s.width * .5, s.height * .1)
      ..lineTo(s.width * .9, s.height * .44);
    canvas.drawPath(path, p);
    canvas.drawLine(Offset(s.width * .72, s.height * .2), Offset(s.width * .72, s.height * .3), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrandWordmark extends StatelessWidget {
  final double size;
  final Color color;
  const BrandWordmark({super.key, this.size = 22, this.color = AppColors.white});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('DAMSTOCK', style: brandStyle(size, color: color, spacing: size * .16)),
          const SizedBox(height: 3),
          Text('HOMES', style: brandStyle(size * .48, color: AppColors.gold, w: FontWeight.w600, spacing: size * .55)),
        ],
      ),
    );
  }
}

void showSnack(BuildContext context, String msg, {IconData icon = Icons.check_circle_rounded}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    duration: const Duration(milliseconds: 1800),
    content: Row(children: [
      Icon(icon, color: AppColors.gold, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Text(msg)),
    ]),
  ));
}

class CounterField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const CounterField({super.key, required this.label, required this.value, required this.onChanged, this.min = 0, this.max = 10});

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData i, bool enabled, VoidCallback f) => Pressable(
          onTap: enabled ? f : null,
          scale: .88,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled ? AppColors.forest : AppColors.sand,
            ),
            child: Icon(i, size: 18, color: enabled ? AppColors.white : AppColors.muted),
          ),
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: cardDeco(r: 16, border: true),
      child: Row(
        children: [
          Expanded(child: Text(label, style: ts(context, 14, w: FontWeight.w700))),
          btn(Icons.remove_rounded, value > min, () => onChanged(value - 1)),
          SizedBox(
            width: 40,
            child: Center(child: Text('$value', style: ts(context, 17, w: FontWeight.w800))),
          ),
          btn(Icons.add_rounded, value < max, () => onChanged(value + 1)),
        ],
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8, top: 4),
        child: Text(text, style: ts(context, 13.5, w: FontWeight.w800, color: AppColors.ink)),
      );
}
