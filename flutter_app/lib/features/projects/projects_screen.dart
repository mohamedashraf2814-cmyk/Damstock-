import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  ProjectStatus? _status;

  @override
  Widget build(BuildContext context) {
    final ar = context.isAr;
    final list = MockData.projects.where((p) => _status == null || p.status == _status).toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('all_projects'))),
      body: Column(children: [
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            children: [
              Pill(context.tr('all'), selected: _status == null, onTap: () => setState(() => _status = null)),
              for (final s in ProjectStatus.values) ...[
                const SizedBox(width: 8),
                Pill(projectStatusLabel(s, ar), selected: _status == s, onTap: () => setState(() => _status = s)),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) => FadeSlideIn(
              key: ValueKey('${list[i].id}-$_status'),
              delayMs: i * 70,
              child: ProjectCard(list[i]),
            ),
          ),
        ),
      ]),
    );
  }
}
