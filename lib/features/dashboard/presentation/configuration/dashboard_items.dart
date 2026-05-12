import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/spline_selection_provider.dart';
import 'package:puls/core/shared_widget/app_chart.dart';
import 'package:puls/features/dashboard/presentation/widgets/q1_pie_chart.dart';
import 'package:puls/features/dashboard/presentation/widgets/q1_time_line.dart';
import 'package:puls/features/dashboard/presentation/widgets/q2_sunburst_chart.dart';
import 'package:puls/features/dashboard/presentation/widgets/q4_sunburst_chart.dart';
import '../../../../core/data/fake_data.dart';
import '../../../../core/provider/iar_selection_provider.dart';
import '../model/dashboard_item.dart';
import '../widgets/alert_card.dart';
import '../widgets/filter_chip.dart';
import '../widgets/q0_score_gauge.dart';
import '../widgets/q0_spline_chart.dart';
import '../widgets/q3_sunburst_chart.dart';
import '../widgets/q5_dougnut_chart.dart';

final dashboardItems = [

  DashboardItem(
    title: "ISGPP",
    fullName: "Indice de Satisfaction Globale du Parcours Patient",
    crossAxis: 12,
    mainAxis: 5,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentGeometry.center,
          child: Q0ScoreGauge(),
        ),
        Expanded(child: Q0SplineChart()),
      ],
    ),
  ),
  DashboardItem(
    headerWidget: const SplineLegendHeader(),
    title: "EMP",
    fullName: "Efficacité Médicale Perçue",
    crossAxis: 12,
    mainAxis: 5,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentGeometry.center,
          child: Q1PieChart(),
        ),
        Expanded(child: Q1MultiSplineChart()),
      ],
    ),
  ),
  DashboardItem(
    title: "VQPS",
    fullName: "Vécu Qualitatif du Parcours de Soins",
    crossAxis: 6,
    mainAxis: 6,
    isExpandable: true,
    secondaryChild: AppCharts.Treemap(mockPatients),
    child: Q2SunburstSection(),
  ),
  DashboardItem(
    title: "MCR",
    fullName: "Moments Critiques & Réputation de l'Établissement",
    crossAxis: 6,
    mainAxis: 6,
    isExpandable: true,
    secondaryChild: AppCharts.Treemap(mockPatients),
    child: Q3SunburstSection(),
  ),
  DashboardItem(
    title: "IAR",
    fullName: "Indice d'Amélioration & de Réputation",
    crossAxis: 6,
    mainAxis: 6,
    isExpandable: true,
    secondaryChild: AppCharts.Treemap(mockPatients),
    child: Q4SunburstSection(),
  ),
  DashboardItem(
    title: "Consentement",
    fullName: "Indice d'Amélioration & de Réputation",
    crossAxis: 6,
    mainAxis: 6,
    child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: Q5DoughnutSection()),
  ),

  DashboardItem(
    title: "Alert",
    fullName: "Alert",
    crossAxis: 12,
    mainAxis: 8,
    child: alertCard(),
  ),
  DashboardItem(
    title: "Réponse",
    fullName: "Indice d'Amélioration & de Réputation",
    crossAxis: 12,
    mainAxis: 4,
    child: Row(
      children: [
        Align(
          alignment: AlignmentGeometry.center,
          child: AppCharts.gauge(87, AppColors.primaryMenthe),
        ),
        Expanded(child: AppCharts.spline(kpi1Spline)),
      ],
    ),
  )
];
