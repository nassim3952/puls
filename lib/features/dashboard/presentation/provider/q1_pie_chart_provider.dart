import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/patient_provider.dart';
import 'package:puls/core/provider/spline_selection_provider.dart';

final q1PieChartProvider = Provider<AsyncValue<List<ChartDataPie>>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);
  // On écoute les chips sélectionnés
  final selectedLabels = ref.watch(splineSelectionProvider);

  return patientsAsync.whenData((list) {
    if (list.isEmpty) return [];

    final Map<String, Color> categories = {
      'Oui totalement': AppColors.primaryMenthe,
      'En partie': AppColors.primaryMenthe.withValues(alpha: 0.8),
      'Non': AppColors.primaryMenthe.withValues(alpha: 0.4),
      'En attente': AppColors.primaryMenthe.withValues(alpha: 0.6),
    };

    return categories.entries.map((entry) {
      final cleanLabel = entry.key.replaceAll('_', ' ').toUpperCase();


      // CONDITION : Si le label n'est pas sélectionné dans tes chips, on met 0
      if (!selectedLabels.contains(cleanLabel)) {
        // On renvoie une valeur vide si pas sélectionné
        return ChartDataPie(label: cleanLabel, value: 0.0, color: Colors.transparent);
      }

      final count = list.where((p) => p.latestVisit?.survey?.attentesSoins == entry.key).length;
      final percentage = (count / list.length) * 100;

      return ChartDataPie(
        label: cleanLabel,
        value: double.parse(percentage.toStringAsFixed(1)),
        color: entry.value,
      );
    }).where((data) => data.value > 0).toList(); // On cache les tranches désactivées
  });
});

// La classe pour les données du camembert
class ChartDataPie {
  final String label;
  final double value;
  final Color color;
  ChartDataPie({required this.label, required this.value, required this.color});
}

// Petite extension pour mettre une majuscule
extension StringExtension on String {
  String capitalize() => this.length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
}