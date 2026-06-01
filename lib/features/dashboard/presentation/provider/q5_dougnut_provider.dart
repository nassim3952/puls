import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/patient_provider.dart';

import '../../../../core/models/chart_model.dart';

final q5DoughnutProvider = Provider<AsyncValue<List<ChartDataPie>>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);

  return patientsAsync.whenData((list) {
    if (list.isEmpty) return [];

    // On compte les occurrences de q5 (qui est un booléen dans ton modèle)
    final int ouiCount = list.where((p) => p.latestVisit?.survey?.consentementRappel == true).length;
    final int nonCount = list.where((p) => p.latestVisit?.survey?.consentementRappel == false).length;

    return [
      ChartDataPie("OUI", ouiCount.toDouble(), AppColors.primaryBlue),
      ChartDataPie("NON", nonCount.toDouble(), AppColors.primaryBlue.withOpacity(0.6)), // Utilise withOpacity
    ];
  });
});