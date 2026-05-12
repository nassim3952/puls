import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/app_chart.dart';

import '../provider/q5_dougnut_provider.dart';

class Q5DoughnutSection extends ConsumerWidget {
  const Q5DoughnutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q5Data = ref.watch(q5DoughnutProvider);

    return q5Data.when(
      data: (data) => SizedBox(
        height: 200, // Taille fixe pour le doughnut
        child: AppCharts.doughnut(data),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text("Erreur Q5: $e"),
    );
  }
}