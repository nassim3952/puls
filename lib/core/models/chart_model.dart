import 'dart:ui';

import '../color.dart';

class ChartDataSpline {
  final String x;
  final double y;

  ChartDataSpline(this.x, this.y);
}

class SplineGroup {
  final String name;
  final List<ChartDataSpline> data;
  final Color color;
  final bool isVisible;

  SplineGroup({
    required this.name,
    required this.data,
    this.color = AppColors.primaryMenthe,
    this.isVisible = true,
  });

  SplineGroup copyWith({bool? isVisible}) {
    return SplineGroup(
      name: name,
      data: data,
      color: color,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class ChartDataPie {
  final String label;
  final double value;
  final Color color;

  ChartDataPie(this.label, this.value, this.color);
}

class BarData {
  final String label;
  final double value;
  final Valence valence;

  BarData({required this.label, required this.value, this.valence = Valence.neutre});
}

enum Valence {
  bonne,
  neutre,
  mauvaise,
  critique
}