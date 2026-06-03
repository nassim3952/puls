// q5_dougnut_provider.dart
// Fixé : utilise patientsListProvider + filterProvider (cohérent avec le dashboard)
// au lieu de filteredPatientsProvider (filtres historique).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/filter_controller.dart';
import 'package:puls/core/provider/patient_provider.dart';
import 'package:puls/core/models/chart_model.dart';

final q5DoughnutProvider = Provider<AsyncValue<List<ChartDataPie>>>((ref) {
  final patientsAsync = ref.watch(patientsListProvider);
  final filters = ref.watch(filterProvider);

  return patientsAsync.whenData((patients) {
    int ouiCount = 0;
    int nonCount = 0;

    for (final patient in patients) {
      for (final v in patient.visits) {
        // ── Filtres dashboard ──────────────────────────────────────────
        final matchService =
        filters.service == null || filters.service!.isEmpty
            ? true
            : v.service == filters.service;
        final matchType = filters.type == null || filters.type!.isEmpty
            ? true
            : v.visitType == filters.type;
        final matchExplo =
        filters.exploration == null || filters.exploration!.isEmpty
            ? true
            : v.exploration == filters.exploration;
        final matchSortie =
        filters.sortie == null || filters.sortie!.isEmpty
            ? true
            : v.afterCare == filters.sortie;
        bool matchDate = true;
        if (filters.periode != null) {
          matchDate = v.date.isAfter(filters.periode!.start) &&
              v.date.isBefore(
                  filters.periode!.end.add(const Duration(days: 1)));
        }

        if (!matchService ||
            !matchType ||
            !matchExplo ||
            !matchSortie ||
            !matchDate) continue;

        if (v.survey == null) continue;

        if (v.survey!.consentementRappel) {
          ouiCount++;
        } else {
          nonCount++;
        }
      }
    }

    if (ouiCount == 0 && nonCount == 0) return [];

    return [
      ChartDataPie('OUI', ouiCount.toDouble(), AppColors.primaryBlue),
      ChartDataPie(
          'NON', nonCount.toDouble(), AppColors.primaryBlue.withOpacity(0.25)),
    ];
  });
});