import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/mock_data.dart';
import '../../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  final LoginArgs args;
  const LoginScreen({super.key, required this.args});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.args.name);
  late final _phone = TextEditingController(text: widget.args.phone);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_form.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    Navigator.pushNamed(
      context,
      Routes.otp,
      arguments: LoginArgs(fromInside: widget.args.fromInside, name: _name.text.trim(), phone: _phone.text.trim()),
    );
  }

  void _guest() {
    if (widget.args.fromInside) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, Routes.shell, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: h * .36,
              child: Stack(
                children: [
                  Positioned.fill(child: NetImg(img(0, w: 1400))),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.forestDark.o(.4), AppColors.forestDark.o(.9)],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(children: [
                        if (widget.args.fromInside || Navigator.canPop(context))
                          CircleBtn(Icons.arrow_back_rounded, dark: true, onTap: () => Navigator.maybePop(context)),
                        const Spacer(),
                        CircleBtn(Icons.translate_rounded, dark: true, iconColor: AppColors.gold, onTap: context.appRead.toggleLocale),
                      ]),
                    ),
                  ),
                  const Positioned(left: 0, right: 0, bottom: 36, child: Center(child: BrandWordmark(size: 26))),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
                decoration: const BoxDecoration(
                  color: AppColors.ivory,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Form(
                  key: _form,
                  child: FadeSlideIn(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('welcome_back'), style: ts(context, 26, w: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(context.tr('login_sub'), style: ts(context, 14, color: AppColors.muted, height: 1.5)),
                        const SizedBox(height: 24),
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
                            decoration: InputDecoration(
                              hintText: '01XXXXXXXXX',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  const Text('🇪🇬'),
                                  const SizedBox(width: 6),
                                  Text('+20', style: ts(context, 14, w: FontWeight.w700)),
                                  const SizedBox(width: 10),
                                  Container(width: 1, height: 22, color: AppColors.line),
                                ]),
                              ),
                            ),
                            validator: (v) => isEgyptianMobile(v ?? '') ? null : context.tr('err_phone'),
                            onFieldSubmitted: (_) => _continue(),
                          ),
                        ),
                        const SizedBox(height: 26),
                        AppButton(context.tr('continue'), onTap: _continue, icon: Icons.arrow_forward_rounded),
                        const SizedBox(height: 12),
                        AppButton(context.tr('guest'), onTap: _guest, style: BtnStyle.outline),
                        const SizedBox(height: 18),
                        Center(
                          child: Text(context.tr('terms_note'), textAlign: TextAlign.center, style: ts(context, 11.5, color: AppColors.muted)),
                        ),
                      ],
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
