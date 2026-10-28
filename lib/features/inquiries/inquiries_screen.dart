import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';

class InquiriesScreen extends StatefulWidget {
  const InquiriesScreen({super.key});

  @override
  State<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen> {
  int _seg = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ar = app.isAr;
    final list = app.inquiries.where((i) {
      if (_seg == 1) return i.type == InquiryType.viewing;
      if (_seg == 2) return i.type != InquiryType.viewing;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('my_inquiries'))),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Segmented(
            labels: [context.tr('all'), inquiryTypeLabel(InquiryType.viewing, ar), inquiryTypeLabel(InquiryType.info, ar)],
            index: _seg,
            onChanged: (i) => setState(() => _seg = i),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? EmptyState(
                  icon: Icons.event_note_rounded,
                  title: context.tr('inq_empty'),
                  subtitle: context.tr('inq_empty_sub'),
                  actionLabel: context.tr('start_exploring'),
                  onAction: () {
                    app.setTab(1);
                    AppRouter.toShell(context);
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => FadeSlideIn(key: ValueKey('${list[i].id}-$_seg'), delayMs: i * 60, child: _InquiryCard(list[i])),
                ),
        ),
      ]),
    );
  }
}

class _InquiryCard extends StatelessWidget {
  final Inquiry inq;
  const _InquiryCard(this.inq);

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ar = app.isAr;
    final prop = app.propertyById(inq.propertyId);
    final project = MockData.project(inq.projectId);
    final dev = MockData.developer(inq.developerId);
    final title = prop?.title.of(ar) ?? project?.name.of(ar) ?? dev?.name.of(ar) ?? context.tr('general_inquiry');
    final image = prop?.cover ?? project?.cover ?? (dev != null ? MockData.developerCover(dev) : null);

    final (Color sc, IconData si) = switch (inq.status) {
      InquiryStatus.pending => (AppColors.warning, Icons.hourglass_top_rounded),
      InquiryStatus.confirmed => (AppColors.success, Icons.check_circle_rounded),
      InquiryStatus.completed => (AppColors.info, Icons.task_alt_rounded),
    };
    final tIcon = switch (inq.type) {
      InquiryType.viewing => Icons.event_available_rounded,
      InquiryType.info => Icons.mail_outline_rounded,
      InquiryType.callback => Icons.phone_callback_rounded,
    };

    return Pressable(
      onTap: () {
        if (prop != null) {
          Navigator.pushNamed(context, Routes.property, arguments: PropertyArgs(prop.id));
        } else if (project != null) {
          Navigator.pushNamed(context, Routes.project, arguments: project.id);
        } else if (dev != null) {
          Navigator.pushNamed(context, Routes.developer, arguments: dev.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: cardDeco(r: 20),
        child: Column(children: [
          Row(children: [
            if (image != null)
              NetImg(image, width: 62, height: 62, radius: BorderRadius.circular(14))
            else
              Container(width: 62, height: 62, decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(14)), child: const Center(child: BrandMark(size: 38))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(tIcon, size: 15, color: AppColors.goldDeep),
                  const SizedBox(width: 4),
                  Text(inquiryTypeLabel(inq.type, ar), style: ts(context, 12, w: FontWeight.w800, color: AppColors.goldDeep)),
                  const Spacer(),
                  Tag.soft(inquiryStatusLabel(inq.status, ar), icon: si, color: sc),
                ]),
                const SizedBox(height: 4),
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(context, 14.5, w: FontWeight.w800)),
                Text(timeAgo(inq.createdAt, ar), style: ts(context, 11.5, color: AppColors.muted)),
              ]),
            ),
          ]),
          if (inq.type == InquiryType.viewing && inq.viewingDate != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: AppColors.ivory, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.forest),
                const SizedBox(width: 8),
                Text(context.tr('viewing_on'), style: ts(context, 12.5, color: AppColors.muted)),
                const Spacer(),
                Text('${dayName(inq.viewingDate!, ar)} ${fmtDate(inq.viewingDate!, ar)} • ${inq.slot ?? ''}', style: ts(context, 12.5, w: FontWeight.w800)),
              ]),
            ),
          ],
          if (inq.message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('“${inq.message}”', maxLines: 2, overflow: TextOverflow.ellipsis, style: ts(context, 12.5, color: AppColors.muted)),
            ),
          ],
        ]),
      ),
    );
  }
}
