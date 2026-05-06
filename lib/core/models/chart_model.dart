import 'dart:ui';

class ChartDataSpline {
  final String x;
  final double y;
  ChartDataSpline(this.x, this.y);
}

class SplineGroup {
  final String name;
  final List<ChartDataSpline> data;
  final Color color;

  SplineGroup({
    required this.name,
    required this.data,
    required this.color,
  });
}
class ChartDataPie {
  final String label;
  final double value;
  final Color color;
  ChartDataPie(this.label, this.value, this.color);
}