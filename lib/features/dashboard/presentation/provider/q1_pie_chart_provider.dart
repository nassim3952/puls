import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'dashboard_charts_provider.dart';
import 'spline_selection_provider.dart';

class ChartDataPie {
  final String label;
  final double value;
  final Color color;
  ChartDataPie({required this.label, required this.value, required this.color});
}

final q1PieChartProvider = Provider<AsyncValue<List<ChartDataPie>>>((ref) {
  final selectedLabels = ref.watch(splineSelectionProvider);

  return ref.watch(dashboardChartsProvider).whenData((charts) =>
      charts.q1Distribution
          .map((item) {
        final upperLabel = item.label.toUpperCase();
        final isActive = selectedLabels.isEmpty || selectedLabels.contains(upperLabel);
        return ChartDataPie(
          label: upperLabel,
          value: item.pct,
          // Grisé si désactivé, couleur normale si actif
          color: isActive ? item.color : Colors.grey.withOpacity(0.25),
        );
      })
          .toList(),
  );
});

extension StringExtension on String {
  String capitalize() => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}