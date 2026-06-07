import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../provider/q1_pie_chart_provider.dart';

class Q1PieChart extends ConsumerWidget {
  const Q1PieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pieDataAsync = ref.watch(q1PieChartProvider);

    return RepaintBoundary(
      child: SizedBox(
        width: 100, // Légèrement plus grand pour laisser respirer les labels
        height: 100,
        child: pieDataAsync.when(
          data: (data) => SfCircularChart(
            margin: EdgeInsets.zero,
            tooltipBehavior: TooltipBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
              builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${data.label}: ${data.value}%',
                    style: TextStyle(color: AppColors.surface, fontSize: 10),
                  ),
                );
              },
            ),
            series: <CircularSeries<ChartDataPie, String>>[
              PieSeries<ChartDataPie, String>(
                dataSource: data,
                xValueMapper: (ChartDataPie d, _) => d.label,
                yValueMapper: (ChartDataPie d, _) => d.value,
                pointColorMapper: (ChartDataPie d, _) => d.color,
                radius: '100%',
                strokeColor: AppColors.surface,
                strokeWidth: 1,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.inside,
                  overflowMode: OverflowMode.hide,
                  textStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.surface),
                ),
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (err, _) => const Icon(Icons.error),
        ),
      ),
    );
  }
}