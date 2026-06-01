import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../core/color.dart';
import '../provider/q0_time_line_provider.dart';

class Q0SplineChart extends ConsumerWidget {
  const Q0SplineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(q0TimelineProvider);

    return RepaintBoundary(
      child: timelineAsync.when(
        data: (data) => SfCartesianChart(
          tooltipBehavior: TooltipBehavior(
            enable: true,
            header: '',
            canShowMarker: true,
            format: 'Date: point.x \nScore: point.y%',
            activationMode: ActivationMode.singleTap,
          ),
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(width: 0),
            labelRotation: -45, // Incline les dates pour la lisibilité
          ),
          primaryYAxis: const NumericAxis(
            axisLine: AxisLine(width: 0),
            majorGridLines: MajorGridLines(width: 0.5, dashArray: [5, 5]),
            minimum: 0,
            maximum: 109,
          ),
          series: <SplineSeries<ChartDataSpline, String>>[
            SplineSeries<ChartDataSpline, String>(
              name: 'Satisfaction (q0)',
              dataSource: data,
              xValueMapper: (d, _) => d.x,
              yValueMapper: (d, _) => d.y,
              color: AppColors.primaryBlue, // Ta couleur de thème
              width: 3,
              markerSettings: const MarkerSettings(
                isVisible: true,
                height: 4,
                width: 4,
                shape: DataMarkerType.circle,
                borderWidth: 2,
                borderColor: AppColors.primaryBlue,
              ),
              animationDuration: 800,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Erreur: $err")),
      ),
    );
  }
}