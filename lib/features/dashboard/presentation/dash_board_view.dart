import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/filter_controller.dart';
import 'package:puls/core/provider/patient_provider.dart';
import 'package:puls/core/shared_widget/empty_state.dart';
import 'package:puls/features/dashboard/presentation/widgets/build_tile.dart';
import 'package:puls/features/dashboard/presentation/widgets/dashboard_kpi_strip.dart';
import '../../../core/shared_widget/build_header.dart';
import '../../../core/shared_widget/default_view.dart';
import 'configuration/dashboard_items.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(filteredPatientsProvider);
    final filters = ref.watch(filterProvider);

    final hasActiveFilters = filters.service != null ||
        filters.type != null ||
        filters.exploration != null ||
        filters.sortie != null ||
        filters.periode != null;

    return patientsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
      error: (e, _) => Center(
        child: Text(
          'Erreur : $e',
          style: const TextStyle(color: AppColors.primaryError),
        ),
      ),
      data: (patients) {
        if (patients.isEmpty) {
          return Column(
            children: [
              const DashboardHeader(showResultChip: false,),
              const SizedBox(height: 12),
              const DashboardKpiStrip(),
              const SizedBox(height: 12),
              Expanded(
                child: EmptyState(
                  reason: hasActiveFilters
                      ? EmptyStateReason.noResults
                      : EmptyStateReason.noData,
                ),
              ),
            ],
          );
        }

        return DefaultView(
          customWidget: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 900
                  ? 24
                  : (constraints.maxWidth > 600 ? 12 : 8);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Bande KPI ──────────────────────────────────────────
                  const DashboardKpiStrip(),
                  const SizedBox(height: 24),

                  // ── Grille des cards ───────────────────────────────────
                  StaggeredGrid.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    children: dashboardItems
                        .map((item) =>
                        buildTile(item, crossAxisCount, item.headerWidget))
                        .toList(),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}