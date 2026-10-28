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
import 'success_dialog.dart';

class InquiryFormScreen extends StatefulWidget {
  final InquiryArgs args;
  const InquiryFormScreen({super.key, required this.args});

  @override
  State<InquiryFormScreen> createState() => _InquiryFormScreenState();
}

class _InquiryFormScreenState extends State<InquiryFormScreen> {
  final _form = GlobalKey<FormState>();
  late InquiryType _type = widget.args.type;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _msg = TextEditingController();
  DateTime? _day;
  String? _slot;
  bool _whatsapp = false;
  bool _loading = false;
  bool _prefilled = false;

  static const _slots = ['10:00', '12:00', '14:00', '16:00', '18:00', '20:00'];

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
    _name.dispose();
    _phone.dispose();
    _msg.dispose();
    super.dispose();
  }

  String _slotLabel(String s, bool ar) {
    final h = int.parse(s.split(':').first);
    final h12 = h > 12 ? h - 12 : h;
    return ar ? '$h12:00 ${h >= 12 ? 'م' : 'ص'}' : '$h12:00 ${h >= 12 ? 'PM' : 'AM'}';
  }

  Future<void> _submit() async {
    final app = context.appRead;
    final ar = app.isAr;
    if (!(_form.currentState?.validate() ?? false)) return;
    if (_type == InquiryType.viewing && (_day == null || _slot == null)) {
      HapticFeedback.mediumImpact();
      showSnack(context, S.get('err_slot', ar), icon: Icons.error_outline_rounded);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    app.addInquiry(Inquiry(
      id: 'i${DateTime.now().millisecondsSinceEpoch}',
      type: _type,
      propertyId: widget.args.propertyId,
      projectId: widget.args.projectId,
      developerId: widget.args.developerId,
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      message: _msg.text.trim(),
      viewingDate: _type == InquiryType.viewing ? _day : null,
      slot: _type == InquiryType.viewing ? _slot : null,
      viaWhatsApp: _whatsapp,
      createdAt: DateTime.now(),
    ));
    setState(() => _loading = false);
    final goList = await showSuccessDialog(
      context,
      title: S.get('request_sent', ar),
      body: S.get('request_sent_sub', ar),
      primary: S.get('view_requests', ar),
      secondary: S.get('done', ar),
    );
    if (!mounted) return;
    if (goList == true) {
      Navigator.pushReplacementNamed(context, Routes.inquiries);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ar = app.isAr;
    final property = app.propertyById(widget.args.propertyId);
    final project = MockData.project(widget.args.projectId);
    final dev = MockData.developer(widget.args.developerId);
    final today = DateTime.now();
    final days = List.generate(10, (i) => DateTime(today.year, today.month, today.day + i + 1));

    final (String? ctxImg, String ctxTitle, String ctxSub) = property != null
        ? (property.cover, property.title.of(ar), fmtPrice(property.price, ar))
        : project != null
            ? (project.cover, project.name.of(ar), '${context.tr('starting_from')} ${fmtPrice(project.startingPrice, ar)}')
            : dev != null
                ? (MockData.developerCover(dev), dev.name.of(ar), dev.tagline.of(ar))
                : (null, context.tr('general_inquiry'), context.tr('brand_sub'));

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('inquiry_title'))),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: cardDeco(r: 20),
              child: Row(children: [
                if (ctxImg != null)
                  NetImg(ctxImg, width: 64, height: 64, radius: BorderRadius.circular(14))
                else
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(14)),
                    child: const Center(child: BrandMark(size: 40)),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(ctxTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 15, w: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(ctxSub, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 12.5, w: FontWeight.w700, color: AppColors.goldDeep)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Segmented(
              labels: [for (final t in InquiryType.values) inquiryTypeLabel(t, ar)],
              index: _type.index,
              onChanged: (i) => setState(() => _type = InquiryType.values[i]),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _type != InquiryType.viewing
                  ? const SizedBox(width: double.infinity, height: 8)
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 20),
                      FieldLabel(context.tr('choose_date')),
                      SizedBox(
                        height: 82,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: days.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final d = days[i];
                            final sel = _day == d;
                            return Pressable(
                              onTap: () => setState(() => _day = d),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: 66,
                                decoration: BoxDecoration(
                                  color: sel ? AppColors.forest : AppColors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: sel ? AppColors.forest : AppColors.line),
                                ),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Text(dayName(d, ar), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 11, w: FontWeight.w600, color: sel ? AppColors.gold : AppColors.muted)),
                                  Text('${d.day}', style: ts(context, 22, w: FontWeight.w800, color: sel ? AppColors.white : AppColors.ink, height: 1.2)),
                                  Text(monthName(d, ar), style: ts(context, 10.5, color: sel ? AppColors.white.o(.7) : AppColors.muted)),
                                ]),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      FieldLabel(context.tr('choose_time')),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final s in _slots) Pill(_slotLabel(s, ar), icon: Icons.schedule_rounded, selected: _slot == s, onTap: () => setState(() => _slot = s)),
                      ]),
                    ]),
            ),
            const SizedBox(height: 18),
            FieldLabel(context.tr('full_name')),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded)),
              validator: (v) => (v == null || v.trim().length < 2) ? context.tr('err_name') : null,
            ),
            const SizedBox(height: 14),
            FieldLabel(context.tr('mobile')),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                decoration: const InputDecoration(hintText: '01XXXXXXXXX', prefixIcon: Icon(Icons.phone_iphone_rounded)),
                validator: (v) => isEgyptianMobile(v ?? '') ? null : context.tr('err_phone'),
              ),
            ),
            const SizedBox(height: 14),
            FieldLabel(context.tr('message')),
            TextFormField(
              controller: _msg,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(hintText: context.tr('message_hint')),
            ),
            const SizedBox(height: 16),
            FieldLabel(context.tr('contact_pref')),
            Row(children: [
              Expanded(child: _ContactOpt(icon: Icons.phone_rounded, label: context.tr('call'), selected: !_whatsapp, onTap: () => setState(() => _whatsapp = false))),
              const SizedBox(width: 10),
              Expanded(child: _ContactOpt(icon: Icons.chat_rounded, label: context.tr('whatsapp'), selected: _whatsapp, onTap: () => setState(() => _whatsapp = true))),
            ]),
            const SizedBox(height: 26),
            AppButton(context.tr('submit_request'), onTap: _submit, loading: _loading, style: BtnStyle.gold, icon: Icons.send_rounded),
          ],
        ),
      ),
    );
  }
}

class _ContactOpt extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ContactOpt({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 52,
          decoration: BoxDecoration(
            color: selected ? AppColors.forest.o(.06) : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? AppColors.forest : AppColors.line, width: selected ? 1.5 : 1),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 19, color: selected ? AppColors.forest : AppColors.muted),
            const SizedBox(width: 8),
            Text(label, style: ts(context, 14, w: FontWeight.w700, color: selected ? AppColors.forest : AppColors.muted)),
            if (selected) ...[const SizedBox(width: 6), const Icon(Icons.check_circle_rounded, size: 17, color: AppColors.gold)],
          ]),
        ),
      );
}
