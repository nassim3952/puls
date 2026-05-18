import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/app_chart.dart';
import '../provider/sun_burst_provider.dart';

class QuestionSunburstSection extends ConsumerWidget {
  final String questionKey; // ex: 'q2', 'q3', 'q4'

  const QuestionSunburstSection({
    super.key,
    required this.questionKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute le provider générique en lui injectant la clé de la question
    final sunburstAsync = ref.watch(sunburstFamilyProvider(questionKey));

    return sunburstAsync.when(
      data: (rootNode) => SizedBox(
        height: 400,
        child: AppCharts.SunChart(rootNode),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, _) => Center(
        child: Text("Erreur analyse ${questionKey.toUpperCase()} : $err"),
      ),
    );
  }
}