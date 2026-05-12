import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/models/chart_model.dart';

import '../../../../core/models/patient.dart';
import '../../../../core/provider/patient_provider.dart';
import '../../../../core/provider/spline_selection_provider.dart';

final q1TimelineGroupsProvider = Provider<AsyncValue<List<SplineGroup>>>((ref) {
  // 1. On écoute la liste de patients filtrée (Service, Type, etc.)
  final patientsAsync = ref.watch(filteredPatientsProvider);

  // 2. On écoute les chips de la légende sélectionnés par l'utilisateur
  final selectedLabels = ref.watch(splineSelectionProvider);

  return patientsAsync.whenData((list) {
    if (list.isEmpty) return [];

    // 3. Définition des catégories (clés du JSON) et leurs couleurs
    final Map<String, Color> categories = {
      'oui_totalement': const Color(0xFF10B981),
      'oui_plutot': const Color(0xFF3B82F6),
      'en_partie': const Color(0xFFF59E0B),
      'non_pas_vraiment': const Color(0xFFEF4444),
      'en_attente': const Color(0xFF94A3B8),
    };

    // 4. On trie les patients par date pour le calcul cumulatif
    final sortedPatients = List<PatientModel>.from(list)
      ..sort((a, b) => a.date.compareTo(b.date));

    // 5. On récupère toutes les dates uniques au format String
    final dates = sortedPatients.map((p) =>
    "${p.date.year}-${p.date.month.toString().padLeft(2, '0')}-${p.date.day.toString().padLeft(2, '0')}"
    ).toSet().toList();

    // 6. Pour chaque catégorie, on construit sa ligne (SplineGroup)
    return categories.entries.map((entry) {
      final categoryKey = entry.key;
      // On transforme "oui_totalement" en "OUI TOTALEMENT" pour matcher tes chips
      final categoryLabel = categoryKey.replaceAll('_', ' ').toUpperCase();

      List<ChartDataSpline> dataPoints = [];
      int cumulativeCategoryCount = 0;
      int cumulativeTotalCount = 0;

      // On parcourt chaque date pour calculer le point à ce moment précis
      for (var date in dates) {
        final patientsToday = sortedPatients.where((p) {
          final pDate = "${p.date.year}-${p.date.month.toString().padLeft(2, '0')}-${p.date.day.toString().padLeft(2, '0')}";
          return pDate == date;
        }).toList();

        cumulativeCategoryCount += patientsToday.where((p) => p.patientResponse.q1 == categoryKey).length;
        cumulativeTotalCount += patientsToday.length;

        double percentage = cumulativeTotalCount == 0
            ? 0.0
            : (cumulativeCategoryCount / cumulativeTotalCount) * 100;

        dataPoints.add(ChartDataSpline(date, double.parse(percentage.toStringAsFixed(1))));
      }

      // 7. On crée l'objet final qui sera lu par le graphique
      return SplineGroup(
        name: categoryLabel,
        color: entry.value,
        data: dataPoints,
        // C'est ici qu'on décide si la ligne est affichée ou non
        isVisible: selectedLabels.contains(categoryLabel),
      );
    }).toList();
  });
});