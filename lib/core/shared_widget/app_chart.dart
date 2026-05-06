import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;

import '../color.dart';
import '../models/chart_model.dart';

class AppCharts {
  // --- 1. GRAPHIQUE JAUGE (KPS) ---
  static Widget gauge(double score, Color color) {
    return SizedBox(
      width: 80,
      height: 80,
      child: gauges.SfRadialGauge(
        // On peut aussi ajouter une durée globale ici si besoin
        enableLoadingAnimation: true,
        axes: <gauges.RadialAxis>[
          gauges.RadialAxis(
            minimum: 0,
            maximum: 100,
            startAngle: 150,
            endAngle: 30,
            showLabels: false,
            showTicks: true,
            axisLineStyle: gauges.AxisLineStyle(
              thickness: 0.15,
              thicknessUnit: gauges.GaugeSizeUnit.factor,
              cornerStyle: gauges.CornerStyle.bothCurve,
              color: const Color(0xFFF0F0F0),
            ),
            majorTickStyle: const gauges.MajorTickStyle(length: 4, thickness: 1, color: Colors.grey),
            minorTickStyle: const gauges.MinorTickStyle(length: 2, thickness: 0.5, color: Colors.grey),

            pointers: <gauges.GaugePointer>[
              // 1. Animation de la barre de progression
              gauges.RangePointer(
                value: score,
                width: 0.15,
                sizeUnit: gauges.GaugeSizeUnit.factor,
                cornerStyle: gauges.CornerStyle.bothCurve,
                color: color,
                enableAnimation: true, // <--- ACTIVER
                animationDuration: 1200,
                animationType: gauges.AnimationType.ease,
              ),
              // 2. Animation de l'aiguille
              gauges.NeedlePointer(
                value: score,
                needleLength: 0.5,
                needleStartWidth: 0.5,
                needleEndWidth: 3,
                enableAnimation: true, // <--- ACTIVER
                animationDuration: 1200,
                animationType: gauges.AnimationType.ease,
                knobStyle: const gauges.KnobStyle(
                  knobRadius: 0.1,
                  color: Color(0xFF2E1A5E),
                ),
                needleColor: const Color(0xFF2E1A5E),
              ),
            ],
            annotations: <gauges.GaugeAnnotation>[
              gauges.GaugeAnnotation(
                widget: Text(
                  '${score.toInt()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                angle: 90,
                positionFactor: 0.8,
              ),
            ],
          ),
        ],
      ),
    );
  } // --- 2. GRAPHIQUE EN CAMEMBERT (Pie) ---

  static Widget pie(List<ChartDataPie> data) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 80,
        height: 80,
        child: SfCircularChart(
          margin: EdgeInsets.zero,
          // L'utilité passe par le Tooltip car on n'a plus de place pour le texte
          tooltipBehavior: TooltipBehavior(
            enable: true,
            // On crée un petit container léger pour le tooltip
            builder:
                (
                  dynamic data,
                  dynamic point,
                  dynamic series,
                  int pointIndex,
                  int seriesIndex,
                ) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${data.label} : ${data.value}%',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
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

              // --- ESTHÉTIQUE "PREMIUM" ---
              // Bordure blanche pour séparer les parts (indispensable en petit format)
              strokeColor: Colors.white,
              strokeWidth: 1.5,

              // --- INTERACTIVITÉ ---
              explode: true,
              explodeOffset: '10%',

              // --- GESTION DES LABELS ---
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.inside,
                // On n'affiche le texte que si la part est assez grande
                labelIntersectAction: LabelIntersectAction.hide,
                textStyle: TextStyle(
                  fontSize: 9, // Très petit pour tenir
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              animationDuration: 600,
            ),
          ],
        ),
      ),
    );
  }

  static Widget spline(List<SplineGroup> activeGroups) {
    return SfCartesianChart(
      // 1. Animation et Interaction
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '', // Supprime le titre du tooltip pour plus de clarté
        canShowMarker: true,
      ),
      plotAreaBorderWidth: 0,

      // 2. Personnalisation des Axes
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
        axisLine: AxisLine(width: 0), // Supprime la ligne de l'axe
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      primaryYAxis: const NumericAxis(
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(size: 0),
        majorGridLines: MajorGridLines(
          width: 1,
          dashArray: <double>[5, 5], // Lignes horizontales en pointillés
        ),
      ),

      // 3. Génération des séries
      series: activeGroups.map((group) {
        return SplineSeries<ChartDataSpline, String>(
          name: group.name,
          dataSource: group.data,
          xValueMapper: (d, _) => d.x,
          yValueMapper: (d, _) => d.y,
          color: group.color,
          width: 4,
          // Un peu plus épais pour le confort visuel
          enableTooltip: true,
          animationDuration: 1500,

          // Animation fluide au démarrage

          // Dégradé sous la courbe (optionnel, rend le tout très moderne)
          // opacity: 0.8,
          markerSettings: MarkerSettings(
            isVisible: true,
            height: 6,
            width: 6,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            // Point avec contour blanc pour qu'il "pop"
          ),
        );
      }).toList(),

      legend: const Legend(
        isVisible: false, // On garde false car tu gères tes propres boutons
      ),
    );
  }

  static Widget bar(List<BarData> data, {bool isHorizontal = false}) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
      ),
      // C'est ici qu'on fixe la limite
      primaryYAxis: const NumericAxis(
        minimum: 0,
        maximum: 100, // <--- Force l'axe à s'arrêter à 100
        interval: 20, // Optionnel : affiche 0, 20, 40, 60, 80, 100
        majorGridLines: MajorGridLines(width: 0.5, dashArray: [5, 5]),
      ),
      series: <CartesianSeries<BarData, String>>[
        if (isHorizontal)
          BarSeries<BarData, String>(
            legendItemText: data.first.label,
            dataSource: data,
            xValueMapper: (BarData d, _) => d.label,
            yValueMapper: (BarData d, _) => d.value,
            // Utilisation de tes couleurs selon la valence
            pointColorMapper: (BarData d, _) => d.valence == Valence.bonne
                ? AppColors.primaryMenthe
                : d.valence == Valence.mauvaise
                ? AppColors.warning
                : d.valence == Valence.critique
                ? AppColors.error
                : AppColors.neutral,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            animationDuration: 1000,
          )
        else
          ColumnSeries<BarData, String>(
            dataSource: data,
            xValueMapper: (BarData d, _) => d.label,
            yValueMapper: (BarData d, _) => d.value,
            pointColorMapper: (BarData d, _) => d.valence == Valence.bonne
                ? AppColors.primaryMenthe
                : d.valence == Valence.mauvaise
                ? AppColors.warning
                : d.valence == Valence.critique
                ? AppColors.error
                : AppColors.neutral,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
            animationDuration: 1000,
          ),
      ],
    );
  }
}
