import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/app_chart.dart';

import '../provider/Q3FlatNode.dart';

class Q3TreemapSection extends ConsumerWidget {
  const Q3TreemapSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q3Data = ref.watch(q3TreemapProvider);

    return q3Data.when(
      data: (data) => SizedBox(
        height: 300,
        child: AppCharts.treemapChart(data),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text("Erreur Q3 Treemap: $e"),
    );
  }
}