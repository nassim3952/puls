import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/spline_selection_provider.dart';
import 'package:puls/core/shared_widget/app_chart.dart';
import '../../../../core/data/fake_data.dart';
import '../../../../core/provider/iar_selection_provider.dart';
import '../model/dashboard_item.dart';
import '../widgets/alert_card.dart';

final dashboardItems = [
  DashboardItem(
    title: "Réponses",
    fullName: "Taux de réponses",
    crossAxis: 4,
    mainAxis: 2,
    icon: Icons.speed,
    child: Row(
      children: [
        Align(
          alignment: AlignmentGeometry.topCenter,

          child: AppCharts.gauge(87, AppColors.primaryMenthe),
        ),
        Expanded(child: AppCharts.spline(kpi1Spline)),
      ],
    ),
  ),
  DashboardItem(
    title: "ISGPP",
    fullName: "Indice de Satisfaction Globale du Parcours Patient",
    icon: Icons.speed,
    crossAxis: 4,
    mainAxis: 2,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        AppCharts.gauge(58, AppColors.primaryMenthe),
        Expanded(child: AppCharts.spline(kpi1Spline)),
      ],
    ),
  ),
  DashboardItem(
    headerWidget: Container(width: 60,height: 60,color: Colors.red,),
    title: "EMP",
    fullName: "Efficacité Médicale Perçue",
    icon: Icons.graphic_eq,
    crossAxis: 4,
    mainAxis: 2,
    child: Consumer(
      // On met le Consumer plus haut pour englober le Pie et la Spline
      builder: (context, ref, child) {
        // 1. On écoute le même cerveau (le Set de noms sélectionnés)
        final selectedNames = ref.watch(splineSelectionProvider);

        // 2. On filtre les données du Pie Chart
        // On garde uniquement les données dont le nom est dans selectedNames
        final activePieData = kpi2Pie
            .where((data) => selectedNames.contains(data.label))
            .toList();

        // 3. On filtre les données des Splines (comme avant)
        final activeSplines = splineData1
            .where((s) => selectedNames.contains(s.name))
            .toList();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Maintenant le Pie est dynamique !
            AppCharts.pie(activePieData, false),
            Expanded(child: AppCharts.spline(activeSplines)),
          ],
        );
      },
    ),
  ),
  DashboardItem(
    title: "VQPS",
    fullName: "Vécu Qualitatif du Parcours de Soins",
    icon: Icons.graphic_eq,
    crossAxis: 6,
    mainAxis: 3,
    child: Consumer(
      builder: (context, ref, child) {
        // 2. On écoute le NOUVEAU cerveau (IAR) et non plus splineSelectionProvider
        final selectedNames = ref.watch(iarSelectionProvider);

        // 3. On filtre les données avec les bons noms (Accueil, Médecin, etc.)
        final activeBarData = dataVPQS
            .where((d) => selectedNames.contains(d.label))
            .toList();

        return AppCharts.bar(activeBarData, isHorizontal: true);
      },
    ),
  ),
  DashboardItem(
    title: "MCR",
    fullName: "Vécu Qualitatif du Parcours de Soins",
    icon: Icons.graphic_eq,
    crossAxis: 6,
    mainAxis: 3,
    child: Expanded(child: AppCharts.bar(dataMCR,isHorizontal: true)),
  ),
  DashboardItem(
    title: "IAR",
    fullName: "Indice d'Amélioration & de Réputation",
    icon: Icons.bar_chart,
    crossAxis: 6,
    mainAxis: 3,
    // Augmenté à 4 pour laisser de la place aux boutons de filtre
    child: Consumer(
      builder: (context, ref, child) {
        // 2. On écoute le NOUVEAU cerveau (IAR) et non plus splineSelectionProvider
        final selectedNames = ref.watch(iarSelectionProvider);

        // 3. On filtre les données avec les bons noms (Accueil, Médecin, etc.)
        final activeBarData = dataIAR
            .where((d) => selectedNames.contains(d.label))
            .toList();

        return AppCharts.bar(activeBarData, isHorizontal: true);
      },
    ),
  ),
  DashboardItem(
    title: "TCRQ",
    fullName: "Indice d'Amélioration & de Réputation",
    icon: Icons.bar_chart,
    crossAxis: 6,
    mainAxis: 3,
    // Augmenté à 4 pour laisser de la place aux boutons de filtre
    child: Consumer(
      builder: (context, ref, child) {
        // 2. On écoute le NOUVEAU cerveau (IAR) et non plus splineSelectionProvider
        final selectedNames = ref.watch(iarSelectionProvider);

        // 3. On filtre les données avec les bons noms (Accueil, Médecin, etc.)
        final activeBarData = dataIAR
            .where((d) => selectedNames.contains(d.label))
            .toList();

        return AppCharts.bar(activeBarData, isHorizontal: true);
      },
    ),
  ),
  DashboardItem(
    title: "Alert",
    fullName: "Alert",
    icon: Icons.warning_amber_outlined,
    crossAxis: 12,
    mainAxis: 3,
    child: alertCard(),
  ),
];

// class IarFilter extends ConsumerWidget {
//   const IarFilter({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // On récupère l'état du filtre (ce qui est coché ou non)
//     final selectedIar = ref.watch(iarSelectionProvider);
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Wrap(
//         spacing: 6,
//         runSpacing: 0,
//         alignment: WrapAlignment.center,
//         children: dataIAR.map((data) {
//           final isSelected = selectedIar.contains(data.label);
//           return FilterChip(
//             visualDensity: VisualDensity.compact,
//             label: Text(
//               data.label,
//               style: TextStyle(
//                 fontSize: 10,
//                 color: isSelected ? Colors.white : Colors.black87,
//               ),
//             ),
//             selected: isSelected,
//             onSelected: (_) {
//               // On appelle la méthode toggle du Notifier moderne
//               ref.read(iarSelectionProvider.notifier).toggleName(data.label);
//             },
//             selectedColor: data.color,
//             checkmarkColor: Colors.white,
//             backgroundColor: Colors.grey[100],
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
