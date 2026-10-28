import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/routes.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final list = app.myListings;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('my_listings')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => Navigator.pushNamed(context, Routes.addProperty),
          ),
        ],
      ),
      body: list.isEmpty
          ? EmptyState(
              icon: Icons.add_home_work_rounded,
              title: context.tr('listings_empty'),
              subtitle: context.tr('listings_empty_sub'),
              actionLabel: context.tr('sell_your_unit'),
              onAction: () => Navigator.pushNamed(context, Routes.addProperty),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) => FadeSlideIn(delayMs: i * 60, child: PropertyCard(list[i], heroPrefix: 'mine')),
            ),
    );
  }
}
