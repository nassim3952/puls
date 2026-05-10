import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/spline_selection_provider.dart';
import 'package:puls/core/shared_widget/app_chart.dart';
import '../../../../core/data/fake_data.dart';
import '../../../../core/provider/iar_selection_provider.dart';
import '../model/dashboard_item.dart';
import '../widgets/alert_card.dart';
import '../widgets/filter_chip.dart';

final dashboardItems = [
  DashboardItem(
    title: "Réponses",
    fullName: "Taux de réponses",
    crossAxis: 4,
    mainAxis: 2,
    child: Row(
      children: [
        Align(
          alignment: AlignmentGeometry.center,
          child: AppCharts.gauge(87, AppColors.primaryMenthe),
        ),
        Expanded(child: AppCharts.spline(kpi1Spline)),
      ],
    ),
  ),
  DashboardItem(
    title: "ISGPP",
    fullName: "Indice de Satisfaction Globale du Parcours Patient",
    crossAxis: 4,
    mainAxis: 2,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentGeometry.center,
          child: AppCharts.gauge(58, AppColors.primaryMenthe),
        ),
        Expanded(child: AppCharts.spline(kpi1Spline)),
      ],
    ),
  ),
  DashboardItem(
    headerWidget: const SplineLegendHeader(),
    title: "EMP",
    fullName: "Efficacité Médicale Perçue",
    crossAxis: 4,
    mainAxis: 2,
    child: Consumer(
      builder: (context, ref, child) {
        final selectedNames = ref.watch(splineSelectionProvider);
        final activePieData = kpi2Pie
            .where((data) => selectedNames.contains(data.label))
            .toList();
        final activeSplines = splineData1
            .where((s) => selectedNames.contains(s.name))
            .toList();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: AppCharts.pie(activePieData, false)),
            Expanded(child: AppCharts.spline(activeSplines)),
          ],
        );
      },
    ),
  ),
  DashboardItem(
    title: "VQPS",
    fullName: "Vécu Qualitatif du Parcours de Soins",
    crossAxis: 3,
    mainAxis: 3,
    isExpandable: true,
    child: AppCharts.SunChart(sunBurstData),
  ),
  DashboardItem(
    title: "MCR",
    fullName: "Vécu Qualitatif du Parcours de Soins",
    crossAxis: 3,
    mainAxis: 3,
    isExpandable: true,
    child: AppCharts.SunChart(sunBurstData),
  ),
  DashboardItem(
    title: "IAR",
    fullName: "Indice d'Amélioration & de Réputation",
    crossAxis: 3,
    mainAxis: 3,
    isExpandable: true,
    child: AppCharts.SunChart(sunBurstData),
  ),
  DashboardItem(
    title: "TCRQ",
    fullName: "Indice d'Amélioration & de Réputation",
    crossAxis: 3,
    mainAxis: 3,
    isExpandable: true,
    child: AppCharts.SunChart(sunBurstData),
  ),
  DashboardItem(
    title: "Alert",
    fullName: "Alert",
    crossAxis: 6,
    mainAxis: 4,
    child: alertCard(),
  ),
];
