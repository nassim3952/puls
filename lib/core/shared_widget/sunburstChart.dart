// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../features/dashboard/presentation/model/domain/verbatim_node.dart';
// import '../../features/dashboard/presentation/provider/verbatim_provider.dart';
//
// class MySunburstChart extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // On utilise le provider généré
//     final List<VerbatimNode> chartData = ref.watch(verbatimDataProvider);
//
//     return SfSunburstChart(
//       dataSource: chartData,
//       // Configuration des niveaux pour descendre dans les verbatims
//       levels: [
//         SunburstLevel(groupMode: SunburstGroupMode.value),
//         SunburstLevel(groupMode: SunburstGroupMode.value),
//       ],
//       // Liaison avec les propriétés de votre classe VerbatimNode
//       valueMapper: (VerbatimNode data) => data.value,
//       childrenMapper: (VerbatimNode data) => data.children,
//       labelMapper: (VerbatimNode data) => data.label,
//       dataLabelSettings: const SunburstDataLabelSettings(isVisible: true),
//     );
//   }
// }