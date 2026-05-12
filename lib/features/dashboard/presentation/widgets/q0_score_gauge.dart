import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;

import '../provider/q0_average_provider.dart';

class Q0ScoreGauge extends ConsumerWidget {
  const Q0ScoreGauge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute la moyenne calculée
    final score = ref.watch(q0AverageProvider);

    // On peut même changer la couleur selon le score !
    Color gaugeColor = score > 70 ? Colors.green : (score > 40 ? Colors.orange : Colors.red);

    return RepaintBoundary(
      child: SizedBox(
        width: 120, // Un peu plus grand pour mieux voir
        height: 120,
        child: gauges.SfRadialGauge(
          enableLoadingAnimation: false,
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
                  color: gaugeColor, // Couleur dynamique
                  enableAnimation: true,
                  animationDuration: 1000,
                ),
                gauges.NeedlePointer(
                  value: score,
                  needleLength: 0.5,
                  needleStartWidth: 0.5,
                  needleEndWidth: 3,
                  enableAnimation: true,
                  knobStyle: const gauges.KnobStyle(knobRadius: 0.1, color: Color(0xFF2E1A5E)),
                  needleColor: const Color(0xFF2E1A5E),
                ),
              ],
              annotations: <gauges.GaugeAnnotation>[
                gauges.GaugeAnnotation(
                  widget: Text(
                      '${score.toInt()}%',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)
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
}