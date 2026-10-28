import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';

Future<void> showFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _FilterSheet(),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late PropertyFilter f;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      f = context.appRead.filter.clone();
      _init = true;
    }
  }

  void _u(VoidCallback fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ar = app.isAr;
    final count = f.apply(app.marketProperties).length;
    final h = MediaQuery.sizeOf(context).height;

    Widget section(String title, Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: ts(context, 15, w: FontWeight.w800)),
            const SizedBox(height: 10),
            child,
          ]),
        );

    return SizedBox(
      height: h * .88,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 6),
            child: Column(children: [
              Container(width: 44, height: 5, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 12),
              Row(children: [
                Text(context.tr('filters'), style: ts(context, 20, w: FontWeight.w800)),
                const Spacer(),
                TextButton(
                  onPressed: () => _u(() => f = PropertyFilter()..query = f.query),
                  child: Text(context.tr('reset'), style: ts(context, 14, w: FontWeight.w700, color: AppColors.goldDeep)),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ]),
            ]),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              children: [
                section(
                  context.tr('listing_kind'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    Pill(context.tr('all'), selected: f.kind == null, onTap: () => _u(() => f.kind = null)),
                    for (final k in ListingKind.values) Pill(kindLabel(k, ar), selected: f.kind == k, onTap: () => _u(() => f.kind = k)),
                  ]),
                ),
                section(
                  context.tr('property_type'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final t in PropertyType.values)
                      Pill(
                        typeLabel(t, ar),
                        icon: typeIcon(t),
                        dense: true,
                        selected: f.types.contains(t),
                        onTap: () => _u(() => f.types.contains(t) ? f.types.remove(t) : f.types.add(t)),
                      ),
                  ]),
                ),
                section(
                  context.tr('city'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    Pill(context.tr('all'), dense: true, selected: f.city == null, onTap: () => _u(() => f.city = null)),
                    for (final c in Cities.all) Pill(c.of(ar), dense: true, selected: f.city == c.en, onTap: () => _u(() => f.city = c.en)),
                  ]),
                ),
                section(
                  context.tr('price_range'),
                  Column(children: [
                    Row(children: [
                      _PriceBox(label: fmtPrice(f.minPrice, ar)),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('—')),
                      _PriceBox(label: f.maxPrice >= PropertyFilter.priceCap ? context.tr('no_limit') : fmtPrice(f.maxPrice, ar)),
                    ]),
                    RangeSlider(
                      values: RangeValues(f.minPrice, f.maxPrice),
                      min: 0,
                      max: PropertyFilter.priceCap,
                      divisions: 60,
                      onChanged: (v) => _u(() {
                        f.minPrice = v.start;
                        f.maxPrice = v.end;
                      }),
                    ),
                  ]),
                ),
                section(
                  context.tr('bedrooms'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final b in [0, 1, 2, 3, 4, 5])
                      Pill(b == 0 ? context.tr('any') : (b == 5 ? '5+' : '$b+'), selected: f.minBeds == b, onTap: () => _u(() => f.minBeds = b)),
                  ]),
                ),
                section(
                  context.tr('finishing'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    Pill(context.tr('any'), dense: true, selected: f.finish == null, onTap: () => _u(() => f.finish = null)),
                    for (final fin in FinishType.values) Pill(finishLabel(fin, ar), dense: true, selected: f.finish == fin, onTap: () => _u(() => f.finish = fin)),
                  ]),
                ),
                section(
                  context.tr('status'),
                  Segmented(
                    labels: [context.tr('any'), context.tr('ready'), context.tr('offplan')],
                    index: f.ready == null ? 0 : (f.ready! ? 1 : 2),
                    onChanged: (i) => _u(() => f.ready = i == 0 ? null : i == 1),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.forestDark.o(.06), blurRadius: 20, offset: const Offset(0, -6))]),
            child: AppButton(
              '${context.tr('show_results')} ($count)',
              onTap: () {
                app.setFilter(f);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  final String label;
  const _PriceBox({required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: cardDeco(r: 14, border: true),
          child: Text(label, style: ts(context, 13.5, w: FontWeight.w800, color: AppColors.forest)),
        ),
      );
}
