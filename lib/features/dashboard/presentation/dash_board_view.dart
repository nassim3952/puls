import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:puls/features/dashboard/presentation/widgets/build_tile.dart';
import '../../../core/shared_widget/default_view.dart';
import 'configuration/dashboard_items.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultView(
      customWidget: LayoutBuilder(
        builder: (context, constraints) {
          // Calcul dynamique des colonnes
          int crossAxisCount = constraints.maxWidth > 900 ? 24 : (constraints.maxWidth > 600 ? 12 : 8);

          return StaggeredGrid.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            // On passe item.headerWidget pour que les chips s'affichent
            children: dashboardItems.map((item) => buildTile(item, crossAxisCount, item.headerWidget)).toList(),
          );
        },
      ),
    );
  }
}