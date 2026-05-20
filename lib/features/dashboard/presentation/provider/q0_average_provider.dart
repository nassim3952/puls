import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/patient_provider.dart';

final q0AverageProvider = Provider<double>((ref) {
  // 1. On écoute la liste filtrée (la passoire)
  final patientsAsync = ref.watch(filteredPatientsProvider);

  return patientsAsync.when(
    data: (list) {
      if (list.isEmpty) return 0.0;

      // 2. On additionne tous les scores q0 (on convertit le String en double)
      final totalScore = list.fold<double>(0, (sum, p) {
        final score = (p.latestVisit?.survey?.qualitePriseEnCharge ?? 0).toDouble();
        return sum + score;
      });

      // 3. On calcule la moyenne sur 5
      final average = totalScore / list.length;

      // 4. On multiplie par 20 pour avoir un score sur 100
      return average * 20;
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});