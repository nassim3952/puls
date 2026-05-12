import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/app_chart.dart';

import '../provider/Q3FlatNode.dart';

class Q3TreemapSection extends ConsumerWidget {
  const Q3TreemapSection({super.key});

// Remplace ton build par celui-ci
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q3Data = ref.watch(q3TreemapProvider);

    return q3Data.when(
      // ✅ Utilise Expanded ou LayoutBuilder pour prendre toute la place du parent
      data: (data) => AppCharts.treemapChart(data, ref),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text("Erreur: $e"),
    );
  }}