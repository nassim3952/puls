import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/models/chart_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../core/color.dart';
import '../provider/q1_time_line_groupe_provider.dart';

class Q1MultiSplineChart extends ConsumerWidget {
  const Q1MultiSplineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(q1TimelineGroupsProvider);

    return RepaintBoundary(
      child: groupsAsync.when(
        data: (groups) => SfCartesianChart(
          legend: const Legend(isVisible: false, position: LegendPosition.bottom), // Pour savoir quelle ligne est quoi
          tooltipBehavior: TooltipBehavior(
            enable: true,
            header: '',
            canShowMarker: true,
            format: 'point.x : point.y%',
            activationMode: ActivationMode.singleTap,
          ),
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(width: 0),
            labelRotation: -45,
          ),
          primaryYAxis: const NumericAxis(
            axisLine: AxisLine(width: 0),
            majorGridLines: MajorGridLines(width: 0.5, dashArray: [5, 5]),
            minimum: 0,
            maximum: 109,
          ),
// Dans ton widget Q1MultiSplineChart
            series: <SplineSeries<ChartDataSpline, String>>[
              // On filtre la liste 'groups' AVANT de faire le .map
              ...groups.where((group) => group.isVisible).map((group) {
                return SplineSeries<ChartDataSpline, String>(
                  name: group.name,
                  dataSource: group.data as List<ChartDataSpline>,
                  xValueMapper: (ChartDataSpline d, _) => d.x,
                  yValueMapper: (ChartDataSpline d, _) => d.y,
                  color: group.color,
                  width: 3,
                  enableTooltip: true,
                  animationDuration: 800,
                  markerSettings: const MarkerSettings(
                    isVisible: false,
                    height: 4,
                    width: 4,
                    shape: DataMarkerType.circle,
                    borderWidth: 2,
                    borderColor: AppColors.primaryMenthe,
                  ),
                );
              }).toList(),
            ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Erreur: $err")),
      ),
    );
  }
}