import 'package:flutter/material.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/format.dart';
import 'common.dart';

class PaymentCalculator extends StatefulWidget {
  final int price;
  final int initialDownPct;
  final int initialYears;
  final bool editablePrice;

  const PaymentCalculator({super.key, required this.price, this.initialDownPct = 10, this.initialYears = 8, this.editablePrice = false});

  @override
  State<PaymentCalculator> createState() => _PaymentCalculatorState();
}

class _PaymentCalculatorState extends State<PaymentCalculator> {
  late double _price = widget.price.toDouble();
  late double _down = widget.initialDownPct.clamp(0, 50).toDouble();
  late double _years = widget.initialYears.clamp(0, 12).toDouble();

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    final downAmount = _price * _down / 100;
    final months = (_years * 12).round();
    final monthly = months == 0 ? 0 : (_price - downAmount) / months;

    Widget slider(String label, String value, double v, double min, double max, int div, ValueChanged<double> f) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(label, style: ts(context, 13, w: FontWeight.w700, color: AppColors.muted))),
              Text(value, style: ts(context, 14, w: FontWeight.w800, color: AppColors.forest)),
            ]),
            Slider(value: v, min: min, max: max, divisions: div, onChanged: f),
          ],
        );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.gold.o(.18), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.calculate_rounded, color: AppColors.goldDeep, size: 20),
            ),
            const SizedBox(width: 10),
            Text(context.tr('calculator'), style: ts(context, 16, w: FontWeight.w800)),
          ]),
          const SizedBox(height: 14),
          if (widget.editablePrice)
            slider(context.tr('price_egp'), fmtPrice(_price, ar), _price, 1000000, 30000000, 58, (v) => setState(() => _price = v)),
          slider(context.tr('down_payment'), '${_down.round()}%  •  ${fmtPrice(downAmount, ar)}', _down, 0, 50, 10, (v) => setState(() => _down = v)),
          slider(context.tr('installments'), _years == 0 ? context.tr('cash') : '${_years.round()} ${context.tr('years')}', _years, 0, 12, 12, (v) => setState(() => _years = v)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.forest, AppColors.forestDark]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(context.tr('monthly'), style: ts(context, 12, color: AppColors.white.o(.7))),
                  const SizedBox(height: 2),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: monthly.toDouble()),
                    duration: const Duration(milliseconds: 350),
                    builder: (context, v, _) => Text(
                      months == 0 ? context.tr('cash') : fmtFull(v, ar),
                      style: ts(context, 20, w: FontWeight.w800, color: AppColors.gold),
                    ),
                  ),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(context.tr('down_payment'), style: ts(context, 11, color: AppColors.white.o(.7))),
                Text(fmtPrice(downAmount, ar), style: ts(context, 14, w: FontWeight.w800, color: AppColors.white)),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
          Text(context.tr('calc_note'), style: ts(context, 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}
