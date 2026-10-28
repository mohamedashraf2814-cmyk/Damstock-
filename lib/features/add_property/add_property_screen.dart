import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import '../inquiries/success_dialog.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _pc = PageController();
  int _step = 0;
  static const _steps = 4;

  ListingKind _kind = ListingKind.resale;
  PropertyType _type = PropertyType.apartment;
  Tx _city = Cities.newCairo;
  final _address = TextEditingController();
  final _area = TextEditingController();
  int _beds = 3;
  int _baths = 2;
  int _floor = 1;
  FinishType _finish = FinishType.full;
  bool _ready = true;
  int _deliveryYear = DateTime.now().year + 2;
  final _price = TextEditingController();
  final _paid = TextEditingController();
  int _remainingYears = 6;
  bool _negotiable = true;
  final Set<int> _photos = {};
  final _desc = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _agree = false;
  bool _loading = false;
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_prefilled) {
      final u = context.appRead.user;
      if (u != null) {
        _name.text = u.name;
        _phone.text = u.phone;
      }
      _prefilled = true;
    }
  }

  @override
  void dispose() {
    for (final c in [_address, _area, _price, _paid, _desc, _name, _phone]) {
      c.dispose();
    }
    _pc.dispose();
    super.dispose();
  }

  int _int(TextEditingController c) => int.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;

  String? _validateStep(bool ar) {
    switch (_step) {
      case 1:
        if (_address.text.trim().length < 3 || _int(_area) < 20) return S.get('err_complete_step', ar);
      case 2:
        if (_int(_price) < 100000) return S.get('err_complete_step', ar);
        if (_kind == ListingKind.assignment && _int(_paid) <= 0) return S.get('err_complete_step', ar);
        if (_photos.isEmpty) return S.get('err_photos', ar);
      case 3:
        if (_name.text.trim().length < 2) return S.get('err_name', ar);
        if (!isEgyptianMobile(_phone.text)) return S.get('err_phone', ar);
        if (!_agree) return S.get('err_terms', ar);
    }
    return null;
  }

  void _next() {
    final ar = context.appRead.isAr;
    final err = _validateStep(ar);
    if (err != null) {
      HapticFeedback.mediumImpact();
      showSnack(context, err, icon: Icons.error_outline_rounded);
      return;
    }
    FocusScope.of(context).unfocus();
    if (_step == _steps - 1) {
      _publish();
      return;
    }
    setState(() => _step++);
    _pc.animateToPage(_step, duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _step--);
    _pc.animateToPage(_step, duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
  }

  Future<void> _publish() async {
    final app = context.appRead;
    final ar = app.isAr;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final price = _int(_price);
    final paid = _kind == ListingKind.assignment ? _int(_paid) : null;
    final pos = Cities.pos[_city.en] ?? const Offset(.5, .5);
    final images = (_photos.toList()..sort()).map((i) => MockData.samplePhotos[i].replaceAll('w=600', 'w=1200')).toList();
    final title = Tx(
      '${typeLabel(_type, true)} ${kindLabel(_kind, true)} - ${_city.ar}',
      '${typeLabel(_type, false)} ${kindLabel(_kind, false)} - ${_city.en}',
    );
    final desc = _desc.text.trim().isEmpty ? Tx('${_address.text.trim()} — ${_area.text} م²', '${_address.text.trim()} — ${_area.text} m²') : Tx(_desc.text.trim(), _desc.text.trim());

    app.addListing(Property(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: _type,
      kind: _kind,
      price: price,
      area: _int(_area),
      beds: _beds,
      baths: _baths,
      floor: _floor,
      location: Tx(_address.text.trim(), _address.text.trim()),
      city: _city,
      images: images,
      description: desc,
      finish: _finish,
      deliveryYear: _ready ? DateTime.now().year : _deliveryYear,
      isReady: _ready,
      x: pos.dx,
      y: pos.dy,
      verified: false,
      listedAt: DateTime.now(),
      paidAmount: paid,
      downPayment: paid,
      installmentYears: _kind == ListingKind.assignment ? _remainingYears : null,
      sellerName: _name.text.trim(),
      negotiable: _negotiable,
      pendingReview: true,
    ));
    setState(() => _loading = false);

    final go = await showSuccessDialog(
      context,
      title: S.get('listing_sent', ar),
      body: S.get('listing_sent_sub', ar),
      primary: S.get('view_listings', ar),
      secondary: S.get('done', ar),
    );
    if (!mounted) return;
    if (go == true) {
      Navigator.pushReplacementNamed(context, Routes.myListings);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    final titles = ['s1_title', 's2_title', 's3_title', 's4_title'];
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: _back),
          title: Text(context.tr('add_title')),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('${context.tr('step')} ${_step + 1} ${context.tr('of')} $_steps', style: ts(context, 12.5, w: FontWeight.w700, color: AppColors.goldDeep)),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(context.tr(titles[_step]), key: ValueKey(_step), style: ts(context, 13, w: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                for (var i = 0; i < _steps; i++)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      margin: EdgeInsetsDirectional.only(end: i == _steps - 1 ? 0 : 6),
                      height: 5,
                      decoration: BoxDecoration(
                        color: i <= _step ? AppColors.forest : AppColors.line,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
              ]),
            ]),
          ),
          Expanded(
            child: PageView(
              controller: _pc,
              physics: const NeverScrollableScrollPhysics(),
              children: [_step1(ar), _step2(ar), _step3(ar), _step4(ar)],
            ),
          ),
        ]),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.forestDark.o(.06), blurRadius: 20, offset: const Offset(0, -6))]),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(children: [
                if (_step > 0) ...[
                  Expanded(flex: 2, child: AppButton(context.tr('back'), onTap: _back, style: BtnStyle.outline)),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: 3,
                  child: AppButton(
                    context.tr(_step == _steps - 1 ? 'publish' : 'next'),
                    onTap: _next,
                    loading: _loading,
                    style: _step == _steps - 1 ? BtnStyle.gold : BtnStyle.forest,
                    icon: _step == _steps - 1 ? Icons.publish_rounded : Icons.arrow_forward_rounded,
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _page(List<Widget> children) => ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: children);

  Widget _step1(bool ar) => _page([
        Text(context.tr('s1_title'), style: ts(context, 22, w: FontWeight.w800)),
        const SizedBox(height: 16),
        for (final k in [ListingKind.resale, ListingKind.assignment]) ...[
          Pressable(
            onTap: () => setState(() => _kind = k),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kind == k ? AppColors.forest : AppColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _kind == k ? AppColors.forest : AppColors.line),
                boxShadow: _kind == k ? [BoxShadow(color: AppColors.forest.o(.25), blurRadius: 18, offset: const Offset(0, 8))] : null,
              ),
              child: Row(children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: _kind == k ? AppColors.gold.o(.2) : AppColors.sand, borderRadius: BorderRadius.circular(16)),
                  child: Icon(k == ListingKind.resale ? Icons.sell_rounded : Icons.swap_horiz_rounded, color: _kind == k ? AppColors.gold : AppColors.forest),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(kindLabel(k, ar), style: ts(context, 16, w: FontWeight.w800, color: _kind == k ? AppColors.white : AppColors.ink)),
                    Text(context.tr(k == ListingKind.resale ? 'resale_desc' : 'assignment_desc'), style: ts(context, 12.5, color: _kind == k ? AppColors.white.o(.75) : AppColors.muted)),
                  ]),
                ),
                Icon(_kind == k ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: _kind == k ? AppColors.gold : AppColors.line),
              ]),
            ),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 10),
        FieldLabel(context.tr('property_type')),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.15,
          children: [
            for (final t in PropertyType.values)
              Pressable(
                onTap: () => setState(() => _type = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    color: _type == t ? AppColors.gold.o(.16) : AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _type == t ? AppColors.gold : AppColors.line, width: _type == t ? 1.6 : 1),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(typeIcon(t), color: AppColors.forest, size: 24),
                    const SizedBox(height: 6),
                    Text(typeLabel(t, ar), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 12, w: FontWeight.w700)),
                  ]),
                ),
              ),
          ],
        ),
      ]);

  Widget _step2(bool ar) => _page([
        FieldLabel(context.tr('city')),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in Cities.all) Pill(c.of(ar), dense: true, selected: _city.en == c.en, onTap: () => setState(() => _city = c)),
        ]),
        const SizedBox(height: 16),
        FieldLabel(context.tr('compound_name')),
        TextField(controller: _address, decoration: InputDecoration(hintText: context.tr('compound_hint'), prefixIcon: const Icon(Icons.location_on_outlined))),
        const SizedBox(height: 14),
        FieldLabel(context.tr('area_sqm')),
        TextField(
          controller: _area,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
          decoration: const InputDecoration(hintText: '150', prefixIcon: Icon(Icons.square_foot_rounded)),
        ),
        const SizedBox(height: 14),
        CounterField(label: context.tr('bedrooms'), value: _beds, onChanged: (v) => setState(() => _beds = v)),
        const SizedBox(height: 10),
        CounterField(label: context.tr('baths'), value: _baths, min: 1, onChanged: (v) => setState(() => _baths = v)),
        const SizedBox(height: 10),
        CounterField(label: context.tr('floor'), value: _floor, max: 40, onChanged: (v) => setState(() => _floor = v)),
        const SizedBox(height: 16),
        FieldLabel(context.tr('finishing')),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final f in FinishType.values) Pill(finishLabel(f, ar), dense: true, selected: _finish == f, onTap: () => setState(() => _finish = f)),
        ]),
        const SizedBox(height: 16),
        FieldLabel(context.tr('status')),
        Segmented(labels: [context.tr('ready'), context.tr('offplan')], index: _ready ? 0 : 1, onChanged: (i) => setState(() => _ready = i == 0)),
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          child: _ready
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: CounterField(
                    label: context.tr('delivery_year'),
                    value: _deliveryYear,
                    min: DateTime.now().year,
                    max: DateTime.now().year + 8,
                    onChanged: (v) => setState(() => _deliveryYear = v),
                  ),
                ),
        ),
      ]);

  Widget _step3(bool ar) => _page([
        FieldLabel(context.tr('price_egp')),
        TextField(
          controller: _price,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '5000000',
            prefixIcon: const Icon(Icons.payments_outlined),
            helperText: _int(_price) > 0 ? fmtFull(_int(_price), ar) : null,
          ),
        ),
        if (_kind == ListingKind.assignment) ...[
          const SizedBox(height: 14),
          FieldLabel(context.tr('paid_egp')),
          TextField(
            controller: _paid,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '800000',
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
              helperText: _int(_paid) > 0 ? fmtFull(_int(_paid), ar) : null,
            ),
          ),
          const SizedBox(height: 10),
          CounterField(label: context.tr('remaining_years'), value: _remainingYears, min: 1, max: 12, onChanged: (v) => setState(() => _remainingYears = v)),
        ],
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: cardDeco(r: 16, border: true),
          child: Row(children: [
            Expanded(child: Text(context.tr('negotiable'), style: ts(context, 14, w: FontWeight.w700))),
            Switch(value: _negotiable, onChanged: (v) => setState(() => _negotiable = v)),
          ]),
        ),
        const SizedBox(height: 18),
        Row(children: [
          FieldLabel(context.tr('photos')),
          const Spacer(),
          Text('${_photos.length}/8', style: ts(context, 12.5, w: FontWeight.w700, color: AppColors.goldDeep)),
        ]),
        Text(context.tr('photos_hint'), style: ts(context, 12, color: AppColors.muted)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (var i = 0; i < MockData.samplePhotos.length; i++)
              Pressable(
                onTap: () => setState(() => _photos.contains(i) ? _photos.remove(i) : _photos.add(i)),
                child: Stack(children: [
                  Positioned.fill(child: NetImg(MockData.samplePhotos[i], radius: BorderRadius.circular(14))),
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: _photos.contains(i) ? AppColors.forestDark.o(.45) : Colors.transparent,
                        border: Border.all(color: _photos.contains(i) ? AppColors.gold : Colors.transparent, width: 2.5),
                      ),
                    ),
                  ),
                  if (_photos.contains(i))
                    const Center(child: Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 28)),
                ]),
              ),
          ],
        ),
        const SizedBox(height: 18),
        FieldLabel(context.tr('description')),
        TextField(controller: _desc, minLines: 3, maxLines: 6, decoration: InputDecoration(hintText: context.tr('desc_hint'))),
      ]);

  Widget _step4(bool ar) {
    final price = _int(_price);
    Widget row(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(children: [
            Text(k, style: ts(context, 13, color: AppColors.muted)),
            const SizedBox(width: 12),
            Expanded(child: Text(v, textAlign: TextAlign.end, style: ts(context, 13.5, w: FontWeight.w800))),
          ]),
        );
    final cover = _photos.isEmpty ? null : MockData.samplePhotos[(_photos.toList()..sort()).first];
    return _page([
      Container(
        decoration: cardDeco(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (cover != null) NetImg(cover, height: 160, width: double.infinity, radius: const BorderRadius.vertical(top: Radius.circular(22))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 6, children: [Tag(kindLabel(_kind, ar)), Tag.gold(context.tr('pending_review'))]),
              const SizedBox(height: 10),
              Text(price > 0 ? fmtFull(price, ar) : '—', style: ts(context, 20, w: FontWeight.w800, color: AppColors.forest)),
              const SizedBox(height: 4),
              Text('${typeLabel(_type, ar)} • ${_city.of(ar)}', style: ts(context, 15, w: FontWeight.w800)),
              const Divider(height: 24),
              row(context.tr('compound_name'), _address.text.trim().isEmpty ? '—' : _address.text.trim()),
              row(context.tr('area'), '${_area.text} ${context.tr('sqm')}'),
              row('${context.tr('beds')} / ${context.tr('baths')}', '$_beds / $_baths'),
              row(context.tr('finishing'), finishLabel(_finish, ar)),
              row(context.tr('delivery'), _ready ? context.tr('ready_now') : '$_deliveryYear'),
              if (_kind == ListingKind.assignment) row(context.tr('paid_amount'), fmtFull(_int(_paid), ar)),
              row(context.tr('photos'), '${_photos.length}'),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 20),
      FieldLabel(context.tr('contact_info')),
      TextField(controller: _name, decoration: InputDecoration(hintText: context.tr('full_name'), prefixIcon: const Icon(Icons.person_outline_rounded))),
      const SizedBox(height: 12),
      Directionality(
        textDirection: TextDirection.ltr,
        child: TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
          decoration: const InputDecoration(hintText: '01XXXXXXXXX', prefixIcon: Icon(Icons.phone_iphone_rounded)),
        ),
      ),
      const SizedBox(height: 12),
      Pressable(
        onTap: () => setState(() => _agree = !_agree),
        child: Row(children: [
          Checkbox(value: _agree, onChanged: (v) => setState(() => _agree = v ?? false)),
          Expanded(child: Text(context.tr('agree_terms'), style: ts(context, 13, w: FontWeight.w600))),
        ]),
      ),
    ]);
  }
}
