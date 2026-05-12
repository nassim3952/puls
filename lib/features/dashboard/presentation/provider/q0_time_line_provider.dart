import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/patient_provider.dart';

final q0TimelineProvider = Provider<AsyncValue<List<ChartDataSpline>>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);

  return patientsAsync.whenData((list) {
    if (list.isEmpty) return [];

    // 1. On regroupe les scores par date (YYYY-MM-DD)
    Map<String, List<double>> groupedData = {};
    for (var p in list) {
      // On formate la date pour ignorer l'heure
      String dateKey = "${p.date.year}-${p.date.month.toString().padLeft(2, '0')}-${p.date.day.toString().padLeft(2, '0')}";
      double score = (double.tryParse(p.patientResponse.q0) ?? 0.0) * 20; // Score sur 100

      groupedData.putIfAbsent(dateKey, () => []).add(score);
    }

    // 2. On calcule la moyenne pour chaque jour
    List<ChartDataSpline> timeline = groupedData.entries.map((entry) {
      double avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return ChartDataSpline(entry.key, avg);
    }).toList();

    // 3. On trie par date pour que la courbe aille de gauche à droite
    timeline.sort((a, b) => a.x.compareTo(b.x));

    return timeline;
  });
});

// Petite classe simple pour porter la donnée du graphique
class ChartDataSpline {
  final String x;
  final double y;
  ChartDataSpline(this.x, this.y);
}