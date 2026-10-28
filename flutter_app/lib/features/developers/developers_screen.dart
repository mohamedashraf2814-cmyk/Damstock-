import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

class DevelopersScreen extends StatefulWidget {
  const DevelopersScreen({super.key});

  @override
  State<DevelopersScreen> createState() => _DevelopersScreenState();
}

class _DevelopersScreenState extends State<DevelopersScreen> {
  int _seg = 0;
  String _q = '';

  bool _match(String a, String b) => _q.isEmpty || '$a $b'.toLowerCase().contains(_q.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final devs = MockData.developers.where((d) => _match(d.name.ar, d.name.en)).toList();
    final projects = MockData.projects.where((p) => _match('${p.name.ar} ${p.city.ar}', '${p.name.en} ${p.city.en}')).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(context.tr('developers_title'), style: ts(context, 24, w: FontWeight.w800)),
                const SizedBox(height: 14),
                TextField(
                  onChanged: (v) => setState(() => _q = v.trim()),
                  decoration: InputDecoration(hintText: context.tr('search_dev'), prefixIcon: const Icon(Icons.search_rounded)),
                ),
                const SizedBox(height: 12),
                Segmented(
                  labels: ['${context.tr('tab_developers')} (${devs.length})', '${context.tr('projects')} (${projects.length})'],
                  index: _seg,
                  onChanged: (i) => setState(() => _seg = i),
                ),
              ]),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _seg == 0
                    ? (devs.isEmpty
                        ? EmptyState(key: const ValueKey('de'), icon: Icons.domain_disabled_rounded, title: context.tr('no_results'), subtitle: context.tr('no_results_sub'))
                        : ListView.separated(
                            key: const ValueKey('d'),
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, kNavSpace),
                            itemCount: devs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, i) => FadeSlideIn(delayMs: i * 70, child: DeveloperCard(devs[i])),
                          ))
                    : (projects.isEmpty
                        ? EmptyState(key: const ValueKey('pe'), icon: Icons.location_city_rounded, title: context.tr('no_results'), subtitle: context.tr('no_results_sub'))
                        : ListView.separated(
                            key: const ValueKey('p'),
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, kNavSpace),
                            itemCount: projects.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, i) => FadeSlideIn(delayMs: i * 60, child: ProjectTile(projects[i])),
                          )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
