import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/app_chart.dart';
import 'package:xtal_dataview/src/models/chart_tree_node.dart';

import '../model/chart_tree_model.dart';
import '../provider/q2_sun_burst_provider.dart';

class Q2SunburstSection extends ConsumerWidget {
  const Q2SunburstSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sunburstAsync = ref.watch(q2SunburstProvider);

    return sunburstAsync.when(
      data: (rootNode) => SizedBox(
        height: 400, // Important : donner une hauteur car SizedBox.expand est utilisé
        child: AppCharts.SunChart(rootNode),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Erreur Sunburst : $err")),
    );
  }
}