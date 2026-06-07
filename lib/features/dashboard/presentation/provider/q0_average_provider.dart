import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_charts_provider.dart';

final q0AverageProvider = Provider<double>((ref) {
  final charts = ref.watch(dashboardChartsProvider);
  return charts.when(
    data: (c) => c.q0Average,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});