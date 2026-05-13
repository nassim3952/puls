import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/features/dashboard/presentation/provider/Q3FlatNode.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:syncfusion_flutter_treemap/treemap.dart';
import 'package:xtal_dataview/xtal_dataview.dart' hide LegendPosition;
import 'package:xtal_dataview/xtal_dataview.dart' as xtal;

import '../../features/dashboard/presentation/provider/q3_nav_provider.dart';
import '../color.dart';
import '../data/fake_data.dart';
import '../data/fake_data.dart';
import '../models/chart_model.dart';
import '../models/patient.dart';

class AppCharts {
  // --- 1. GRAPHIQUE JAUGE (KPS) ---
  static Widget gauge(double score, Color color) {
    return RepaintBoundary(
      child: SizedBox(
        width: 80,
        height: 80,
        child: gauges.SfRadialGauge(
          enableLoadingAnimation: false,
          // Performance : off pour éviter les saccades au scroll
          axes: <gauges.RadialAxis>[
            gauges.RadialAxis(
              minimum: 0,
              maximum: 100,
              startAngle: 150,
              endAngle: 30,
              showLabels: false,
              showTicks: true,
              axisLineStyle: const gauges.AxisLineStyle(
                thickness: 0.15,
                thicknessUnit: gauges.GaugeSizeUnit.factor,
                cornerStyle: gauges.CornerStyle.bothCurve,
                color: Color(0xFFF0F0F0),
              ),
              pointers: <gauges.GaugePointer>[
                gauges.RangePointer(
                  value: score,
                  width: 0.15,
                  sizeUnit: gauges.GaugeSizeUnit.factor,
                  cornerStyle: gauges.CornerStyle.bothCurve,
                  color: color,
                  enableAnimation: true,
                  animationDuration: 1000,
                ),
                gauges.NeedlePointer(
                  value: score,
                  needleLength: 0.5,
                  needleStartWidth: 0.5,
                  needleEndWidth: 3,
                  enableAnimation: true,
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
                    ),
                  ),
                  angle: 90,
                  positionFactor: 0.8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. GRAPHIQUE EN CAMEMBERT (Pie) ---
  static Widget pie(List<ChartDataPie> data, bool legend) {
    return RepaintBoundary(
      child: SizedBox(
        width: 80,
        height: 80,
        child: SfCircularChart(
          margin: EdgeInsets.zero,
          // Utilisation d'un builder pour un contrôle total sur la taille du hint
          tooltipBehavior: TooltipBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
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
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${data.label}: ${data.value}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ), // Texte très petit
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
              // Remplit tout l'espace 80x80
              strokeColor: Colors.white,
              strokeWidth: 1,
              enableTooltip: true,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.inside,
                // Désactiver les labels si le segment est trop petit pour éviter le bruit visuel
                overflowMode: OverflowMode.hide,
                textStyle: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  } // --- 3. SPLINE ---

  static Widget spline(List<SplineGroup> activeGroups) {
    return RepaintBoundary(
      child: SfCartesianChart(
        // 1. On active le Tooltip (le hint)
        // 1. On active le Tooltip (le hint)
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: '',
          // Supprime l'en-tête par défaut pour un look plus clean
          canShowMarker: true,
          format: 'point.x : point.y%',
          // Personnalise le texte du hint
          activationMode: ActivationMode.singleTap, // Pour le web/mobile
        ),
        enableMultiSelection: true,
        plotAreaBorderWidth: 0,
        primaryXAxis: const CategoryAxis(
          majorGridLines: MajorGridLines(width: 0),
          axisLine: AxisLine(width: 0),
        ),
        primaryYAxis: const NumericAxis(
          axisLine: AxisLine(width: 0),
          majorGridLines: MajorGridLines(width: 0.5, dashArray: [5, 5]),
        ),
        series: activeGroups.map((group) {
          return SplineSeries<ChartDataSpline, String>(
            name: group.name,
            dataSource: group.data,
            xValueMapper: (d, _) => d.x,
            yValueMapper: (d, _) => d.y,
            color: group.color,
            width: 3,
            enableTooltip: true,
            // 2. On autorise le tooltip pour cette série
            animationDuration: 800,
            // 3. On agrandit les points ici (height et width)
            // 3. On agrandit les points ici (height et width)
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 6,
              // Augmenté de 4 à 8
              width: 6,
              // Augmenté de 4 à 8
              shape: DataMarkerType.circle,
              borderWidth: 2,
              // Ajoute un petit contour blanc pour le style
              // Ajoute un petit contour blanc pour le style
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 4. BAR ---
  static Widget bar(List<BarData> data, {bool isHorizontal = false}) {
    return RepaintBoundary(
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: const CategoryAxis(
          majorGridLines: MajorGridLines(width: 0),
        ),
        series: <CartesianSeries>[
          isHorizontal
              ? BarSeries<BarData, String>(
                  dataSource: data,
                  xValueMapper: (BarData d, _) => d.label,
                  yValueMapper: (BarData d, _) => d.value,
                  pointColorMapper: (BarData d, _) => d.valence == Valence.bonne
                      ? AppColors.primaryMenthe
                      : AppColors.warning,
                  animationDuration: 600,
                )
              : ColumnSeries<BarData, String>(
                  dataSource: data,
                  xValueMapper: (BarData d, _) => d.label,
                  yValueMapper: (BarData d, _) => d.value,
                  animationDuration: 600,
                ),
        ],
      ),
    );
  }

  // --- 5. SUNBURST ---
// --- 5. SUNBURST ---
  static Widget SunChart(xtal.ChartTreeNode data) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Center(
          child: SizedBox.expand(
            child: xtal.SunburstChart(
              data: data,
              // Si 'palette' n'existe pas, on retire la ligne
              // Le widget devrait lire la propriété .color de chaque noeud de 'data'
            ),
          ),
        ),
      ),
    );
  }  static Widget doughnut(List<ChartDataPie> data) {
    if (data.length < 2) {
      return const SizedBox.square(
        dimension: 100,
        child: Center(child: Text("Pas assez de data")),
      );
    }

    final value1 = data[0].value ?? 0;
    final value2 = data[1].value ?? 0;
    final total = value1 + value2;
    final percentage = total > 0 ? (value1 / total) * 100 : 0.0;

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(bottom: 14),
        child: SfCircularChart(
          margin: EdgeInsets.zero,
          // Activation du tooltip (le "hint")
          tooltipBehavior: TooltipBehavior(
            enable: true,
            textStyle: const TextStyle(fontSize: 14),
          ),
          annotations: [
            CircularChartAnnotation(
              widget: Center(
                child: Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ),
            ),
          ],
          series: <CircularSeries>[
            DoughnutSeries<ChartDataPie, String>(
              dataSource: data,
              xValueMapper: (d, _) => d.label,
              yValueMapper: (d, _) => d.value,
              pointColorMapper: (d, _) => d.color,
              radius: '100%',
              innerRadius: '60%',
              strokeColor: Colors.white,
              strokeWidth: 3,
              animationDuration: 600,
              // Configuration des labels (les numéros en blanc)
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.inside,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AJOUTE "WidgetRef ref" en paramètre pour pouvoir modifier le provider
  static Color _getTileColor(TreemapNavigation nav) {
    if (nav.selectedClasse == null) return AppColors.primaryMenthe;
    if (nav.selectedSousClasse == null) AppColors.primaryMenthe;
    return  AppColors.primaryMenthe;
  }

  // --- 1. TREEMAP (LE GROS MORCEAU) ---
  static Widget treemapChart(List<Q3FlatNode> data, WidgetRef ref) {
    final nav = ref.watch(treemapNavProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navigation Breadcrumbs compacte
        if (nav.selectedClasse != null)
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.home_outlined, size: 20),
                  onPressed: () => ref.read(treemapNavProvider.notifier).state = TreemapNavigation(),
                ),
                const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                TextButton(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  onPressed: () => ref.read(treemapNavProvider.notifier).state =
                      TreemapNavigation(selectedClasse: nav.selectedClasse),
                  child: Text(nav.selectedClasse!, style: const TextStyle(fontSize: 12)),
                ),
                if (nav.selectedSousClasse != null) ...[
                  const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nav.selectedSousClasse!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),

        // Le Treemap sans marges inutiles
        Expanded(
          child: SfTreemap(
            key: ValueKey('tree_${nav.selectedClasse}_${nav.selectedSousClasse}'),
            dataCount: data.length,
            weightValueMapper: (int index) => 1.0,
            onSelectionChanged: (TreemapTile tile) {
              final node = data[tile.indices.first];
              if (nav.selectedClasse == null) {
                ref.read(treemapNavProvider.notifier).state = TreemapNavigation(selectedClasse: node.classe);
              } else if (nav.selectedSousClasse == null) {
                ref.read(treemapNavProvider.notifier).state = TreemapNavigation(
                  selectedClasse: node.classe,
                  selectedSousClasse: node.sousClasse,
                );
              }
            },
            levels: <TreemapLevel>[
              TreemapLevel(
                groupMapper: (int index) {
                  if (nav.selectedClasse == null) return data[index].classe;
                  if (nav.selectedSousClasse == null) return data[index].sousClasse;
                  return data[index].message;
                },
                padding: const EdgeInsets.all(1.0),
                color: _getTileColor(nav),
                labelBuilder: (context, tile) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      tile.group,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
