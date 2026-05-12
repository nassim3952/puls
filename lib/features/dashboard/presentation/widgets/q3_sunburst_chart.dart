import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/app_chart.dart';

import '../provider/q3_sun_burst_provider.dart';

class Q3SunburstSection extends ConsumerWidget {
  const Q3SunburstSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. On surveille les données spécifiques à Q3
    final q3Data = ref.watch(q3SunburstProvider);

    return q3Data.when(
      // 2. Si c'est prêt, on utilise ta fonction globale sunChart
      data: (node) => SizedBox(
        height: 400,
        child: AppCharts.SunChart(node),
      ),
      // 3. En attendant, on affiche un loader
      loading: () => const Center(child: CircularProgressIndicator()),
      // 3. Si ça crash, on affiche l'erreur
      error: (e, _) => Center(child: Text('Erreur analyse Q4: $e')),
    );
  }
}