import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/chart_model.dart';

class AppCharts {
  // --- 1. GRAPHIQUE JAUGE (KPS) ---
  static Widget gauge(double score, Color color) {
    return SizedBox(
      width: 60, // Légèrement réduit pour laisser de la place à la spline
      height: 60,
      child: SfCircularChart(
        margin: EdgeInsets.zero,
        series: <CircularSeries<double, String>>[
          RadialBarSeries<double, String>(
            dataSource: [score],
            maximumValue: 100,
            radius: '100%',
            innerRadius: '75%',
            xValueMapper: (d, _) => '',
            yValueMapper: (d, _) => d,
            pointColorMapper: (d, _) => color,
            trackColor: const Color(0xFFF0F0F0),
            cornerStyle: CornerStyle.bothCurve,
          ),
        ],
        annotations: <CircularChartAnnotation>[
          CircularChartAnnotation(
            widget: Text(
              '${score.toInt()}',
              style: const TextStyle(
                fontSize: 24, // Taille adaptée au nouveau diamètre
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }  // --- 2. GRAPHIQUE EN CAMEMBERT (Pie) ---
  static Widget pie(List<ChartDataPie> data) {
    return FittedBox(
      fit: BoxFit.fill, // <--- C'est ici que la magie opère
      child: SizedBox(
        width: 100, // Dimensions de référence pour le calcul du stretch
        height: 100,
        child: SfCircularChart(
          margin: EdgeInsets.zero,
          series: <CircularSeries<ChartDataPie, String>>[
            PieSeries<ChartDataPie, String>(
              dataSource: data,
              xValueMapper: (ChartDataPie d, _) => d.label,
              yValueMapper: (ChartDataPie d, _) => d.value,
              pointColorMapper: (ChartDataPie d, _) => d.color,
              radius: '100%', // Touche les bords du SizedBox
              dataLabelSettings: const DataLabelSettings(
                textStyle: TextStyle(color: Colors.white),
                isVisible: true,
                labelPosition: ChartDataLabelPosition.inside,
              ),
            )
          ],
        ),
      ),
    );
  }
  static Widget spline(List<SplineGroup> groups) {
    return SfCartesianChart(
      // Optionnel : masquer les lignes de la grille pour un look plus clean
      plotAreaBorderWidth: 0,
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
      ),
      // Génération dynamique des séries
      series: groups.map((group) {
        return SplineSeries<ChartDataSpline, String>(
          name: group.name,
          dataSource: group.data,
          xValueMapper: (d, _) => d.x,
          yValueMapper: (d, _) => d.y,
          color: group.color, // Utilise la couleur passée en paramètre
          width: 3, // Épaisseur pour un rendu professionnel
          markerSettings: const MarkerSettings(isVisible: true),
        );
      }).toList(),
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
    );
  }}


