import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/chart_model.dart';
import 'dashboard_charts_provider.dart';

final q5DoughnutProvider = Provider<AsyncValue<List<ChartDataPie>>>((ref) {
  return ref.watch(dashboardChartsProvider).whenData((charts) {
    if (charts.q5Consent.isEmpty) return [];

    final total = charts.q5Consent.fold(0, (sum, e) => sum + e.count);
    if (total == 0) return [];

    return charts.q5Consent.map((e) => ChartDataPie(
      e.label,
      e.count.toDouble(),
      e.label == 'OUI'
          ? AppColors.primaryBlue
          : AppColors.primaryBlue.withOpacity(0.25),
    )).toList();
  });
});