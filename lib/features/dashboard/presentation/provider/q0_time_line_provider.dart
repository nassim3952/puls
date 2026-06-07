import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_charts_provider.dart';

class ChartDataSpline {
  final String x;
  final double y;
  ChartDataSpline(this.x, this.y);
}

final q0TimelineProvider = Provider<AsyncValue<List<ChartDataSpline>>>((ref) {
  return ref.watch(dashboardChartsProvider).whenData((charts) =>
      charts.q0Timeline
          .map((p) => ChartDataSpline(p.x, p.y))
          .toList(),
  );
});