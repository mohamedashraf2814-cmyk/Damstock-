import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ar = app.isAr;
    final user = app.user;

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.forestDark, AppColors.forest]),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(children: [
                  Row(children: [
                    CircleBtn(Icons.arrow_back_rounded, dark: true, onTap: () => Navigator.pop(context)),
                    Expanded(child: Center(child: Text(context.tr('profile'), style: ts(context, 17, w: FontWeight.w800, color: AppColors.white)))),
                    const SizedBox(width: 44),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFFE1C48F), AppColors.goldDeep]),
                      border: Border.all(color: AppColors.white.o(.5), width: 3),
                    ),
                    alignment: Alignment.center,
                    child: user != null
                        ? Text(user.initial, style: ts(context, 34, w: FontWeight.w800, color: AppColors.forestDark))
                        : const Icon(Icons.person_rounded, size: 42, color: AppColors.forestDark),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? context.tr('guest_user'), style: ts(context, 20, w: FontWeight.w800, color: AppColors.white)),
                  const SizedBox(height: 2),
                  if (user != null)
                    Directionality(textDirection: TextDirection.ltr, child: Text('+20 ${user.phone}', style: ts(context, 13.5, color: AppColors.gold, w: FontWeight.w700)))
                  else
                    Text(context.tr('guest_sub'), style: ts(context, 13, color: AppColors.white.o(.75))),
                  if (user == null) ...[
                    const SizedBox(height: 14),
                    AppButton(
                      context.tr('sign_in'),
                      style: BtnStyle.gold,
                      expand: false,
                      height: 46,
                      icon: Icons.login_rounded,
                      onTap: () => Navigator.pushNamed(context, Routes.login, arguments: const LoginArgs(fromInside: true)),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(children: [
                    _Stat('${app.favCount}', context.tr('saved'), () {
                      app.setTab(4);
                      AppRouter.toShell(context);
                    }),
                    _Stat('${app.inquiries.length}', context.tr('requests'), () => Navigator.pushNamed(context, Routes.inquiries)),
                    _Stat('${app.myListings.length}', context.tr('listings'), () => Navigator.pushNamed(context, Routes.myListings)),
                    _Stat('${app.compareIds.length}', context.tr('tool_compare'), () => Navigator.pushNamed(context, Routes.compare)),
                  ]),
                ]),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
          sliver: SliverList.list(children: [
            _Group(context.tr('account'), [
              _Item(Icons.event_note_rounded, context.tr('my_inquiries'), onTap: () => Navigator.pushNamed(context, Routes.inquiries)),
              _Item(Icons.home_work_outlined, context.tr('my_listings'), onTap: () => Navigator.pushNamed(context, Routes.myListings)),
              _Item(Icons.add_home_work_outlined, context.tr('add_title'), onTap: () => Navigator.pushNamed(context, Routes.addProperty)),
            ]),
            _Group(context.tr('preferences'), [
              _Item(
                Icons.translate_rounded,
                context.tr('language'),
                trailing: SizedBox(
                  width: 150,
                  child: Segmented(labels: const ['العربية', 'English'], index: ar ? 0 : 1, onChanged: (i) => app.setLocale(i == 0 ? 'ar' : 'en')),
                ),
              ),
              _Item(
                Icons.notifications_none_rounded,
                context.tr('notifications'),
                trailing: Switch(value: app.notificationsOn, onChanged: app.setNotifications),
              ),
            ]),
            _Group(context.tr('tools'), [
              _Item(Icons.compare_arrows_rounded, context.tr('compare_title'), onTap: () => Navigator.pushNamed(context, Routes.compare)),
              _Item(Icons.map_outlined, context.tr('map_title'), onTap: () => Navigator.pushNamed(context, Routes.map)),
              _Item(Icons.location_city_rounded, context.tr('all_projects'), onTap: () => Navigator.pushNamed(context, Routes.projects)),
            ]),
            _Group(context.tr('support'), [
              _Item(Icons.support_agent_rounded, context.tr('contact_us'), onTap: () => Navigator.pushNamed(context, Routes.inquiryNew)),
              _Item(Icons.info_outline_rounded, context.tr('about_app'), onTap: () => _about(context)),
            ]),
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AppButton(
                  context.tr('logout'),
                  icon: Icons.logout_rounded,
                  style: BtnStyle.outline,
                  onTap: () {
                    app.logout();
                    showSnack(context, S.get('logged_out', app.isAr), icon: Icons.logout_rounded);
                  },
                ),
              ),
            const SizedBox(height: 18),
            Center(child: Text('DAMSTOCK HOMES • ${context.tr('version')} 1.0.0', style: ts(context, 11.5, color: AppColors.muted))),
          ]),
        ),
      ]),
    );
  }

  void _about(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.forestDark, borderRadius: BorderRadius.circular(24)),
              child: const BrandMark(size: 60),
            ),
            const SizedBox(height: 14),
            const BrandWordmark(size: 22, color: AppColors.forestDark),
            const SizedBox(height: 6),
            Text(S.get('tagline', ctx.isAr), style: ts(ctx, 13, w: FontWeight.w700, color: AppColors.goldDeep)),
            const SizedBox(height: 14),
            Text(S.get('about_app_body', ctx.isAr), textAlign: TextAlign.center, style: ts(ctx, 13.5, color: AppColors.muted, height: 1.7)),
            const SizedBox(height: 18),
            AppButton(S.get('close', ctx.isAr), onTap: () => Navigator.pop(ctx), style: BtnStyle.outline),
          ]),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback onTap;
  const _Stat(this.value, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Pressable(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.white.o(.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.white.o(.12))),
            child: Column(children: [
              Text(value, style: ts(context, 18, w: FontWeight.w800, color: AppColors.gold)),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 11, color: AppColors.white.o(.75))),
            ]),
          ),
        ),
      );
}

class _Group extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _Group(this.title, this.items);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, bottom: 8),
            child: Text(title, style: ts(context, 13, w: FontWeight.w800, color: AppColors.muted)),
          ),
          Container(
            decoration: cardDeco(r: 20),
            child: Column(children: [
              for (var i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1) const Padding(padding: EdgeInsetsDirectional.only(start: 62), child: Divider()),
              ],
            ]),
          ),
        ]),
      );
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  const _Item(this.icon, this.label, {this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.gold.o(.15), borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, size: 19, color: AppColors.forest),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: ts(context, 14.5, w: FontWeight.w700))),
            trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ]),
        ),
      );
}
