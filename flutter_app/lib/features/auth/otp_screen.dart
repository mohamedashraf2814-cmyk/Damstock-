import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common.dart';

class OtpScreen extends StatefulWidget {
  final LoginArgs args;
  const OtpScreen({super.key, required this.args});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _len = 4;
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _seconds = 30;
  bool _error = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (_seconds <= 1) t.cancel();
      setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_ctrl.text.length < _len) return;
    if (_ctrl.text != '1234') {
      HapticFeedback.mediumImpact();
      setState(() => _error = true);
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final app = context.appRead;
    app.login(widget.args.name, widget.args.phone);
    showSnack(context, S.get('logged_in', app.isAr));
    if (widget.args.fromInside) {
      Navigator.of(context).popUntil((r) => r.settings.name == Routes.shell || r.isFirst);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, Routes.shell, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _ctrl.text;
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeSlideIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.sms_rounded, color: AppColors.gold, size: 30),
                ),
                const SizedBox(height: 22),
                Text(context.tr('otp_title'), style: ts(context, 26, w: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(context.tr('otp_sub'), style: ts(context, 14, color: AppColors.muted)),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text('+20 ${widget.args.phone}', style: ts(context, 15, w: FontWeight.w800, color: AppColors.forest)),
                ),
                const SizedBox(height: 32),
                Stack(
                  children: [
                    Opacity(
                      opacity: 0,
                      child: SizedBox(
                        height: 70,
                        child: TextField(
                          controller: _ctrl,
                          focusNode: _focus,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(_len)],
                          onChanged: (v) {
                            setState(() => _error = false);
                            if (v.length == _len) _verify();
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _focus.requestFocus(),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_len, (i) {
                            final filled = i < code.length;
                            final active = i == code.length;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 68,
                              height: 70,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  width: active || _error ? 1.8 : 1,
                                  color: _error ? AppColors.danger : (active ? AppColors.gold : (filled ? AppColors.forest : AppColors.line)),
                                ),
                                boxShadow: active ? [BoxShadow(color: AppColors.gold.o(.2), blurRadius: 14)] : null,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                                child: Text(filled ? code[i] : '', key: ValueKey('$i-${filled ? code[i] : ''}'), style: ts(context, 26, w: FontWeight.w800)),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _error
                      ? Text(context.tr('otp_wrong'), key: const ValueKey('e'), style: ts(context, 13, w: FontWeight.w700, color: AppColors.danger))
                      : Tag.soft(context.tr('otp_demo'), icon: Icons.info_outline_rounded, color: AppColors.goldDeep),
                ),
                const SizedBox(height: 22),
                Center(
                  child: _seconds > 0
                      ? Text('${context.tr('resend_in')} 00:${_seconds.toString().padLeft(2, '0')}', style: ts(context, 13.5, color: AppColors.muted))
                      : Pressable(
                          onTap: _startTimer,
                          child: Text(context.tr('resend'), style: ts(context, 14, w: FontWeight.w800, color: AppColors.goldDeep)),
                        ),
                ),
                const Spacer(),
                AppButton(context.tr('verify'), onTap: code.length == _len ? _verify : null, loading: _loading),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
