import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/filter_controller.dart';
import 'package:puls/core/provider/patient_provider.dart';
import 'package:puls/core/shared_widget/empty_state.dart';
import 'package:puls/features/dashboard/presentation/widgets/build_tile.dart';
import '../../../core/shared_widget/default_view.dart';
import 'configuration/dashboard_items.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(filteredPatientsProvider);
    final filters = ref.watch(filterProvider);

    // On détermine si des filtres sont actifs (pour distinguer les deux cas vides)
    final hasActiveFilters = filters.service != null ||
        filters.type != null ||
        filters.exploration != null ||
        filters.sortie != null ||
        filters.periode != null;

    return patientsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryMenthe),
      ),
      error: (e, _) => Center(
        child: Text(
          'Erreur : $e',
          style: const TextStyle(color: AppColors.primaryMentheError),
        ),
      ),
      data: (patients) {
        // ── CAS VIDE ───────────────────────────────────────────────────────
        if (patients.isEmpty) {
          return EmptyState(
            reason: hasActiveFilters
                ? EmptyStateReason.noResults   // filtres actifs → "aucun résultat"
                : EmptyStateReason.noData,     // BDD vide → "aucune donnée"
          );
        }

        // ── CAS NORMAL : on affiche les cards ─────────────────────────────
        return DefaultView(
          customWidget: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 900
                  ? 24
                  : (constraints.maxWidth > 600 ? 12 : 8);

              return StaggeredGrid.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                children: dashboardItems
                    .map((item) =>
                    buildTile(item, crossAxisCount, item.headerWidget))
                    .toList(),
              );
            },
          ),
        );
      },
    );
  }
}