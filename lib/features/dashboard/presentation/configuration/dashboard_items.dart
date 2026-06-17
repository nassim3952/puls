import 'package:flutter/material.dart';
import 'package:puls/features/dashboard/presentation/widgets/alert_section.dart';
import 'package:puls/features/dashboard/presentation/widgets/q1_pie_chart.dart';
import 'package:puls/features/dashboard/presentation/widgets/q1_time_line.dart';
import 'package:puls/features/dashboard/presentation/widgets/sunburst_chart.dart';
import 'package:puls/features/dashboard/presentation/widgets/verbatim_bar_chart.dart';
import '../../model/dashboard_item.dart';
import '../widgets/filter_chip.dart';
import '../../../../core/shared_widget/q0_score_gauge.dart';
import '../widgets/q0_spline_chart.dart';
import '../widgets/q5_dougnut_chart.dart';
import '../widgets/verbatim_feed_section.dart';

final dashboardItems = [
  DashboardItem(
    title: "ISGPP",
    fullName: "Indice de Satisfaction Globale du Parcours Patient",
    crossAxis: 12,
    mainAxis: 5,
    isExpandable: true,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(alignment: AlignmentGeometry.center, child: Q0ScoreGauge()),
        Expanded(child: Q0SplineChart()),
      ],
    ),
  ),

  DashboardItem(
    headerWidget: const SplineLegendHeader(),
    title: "EMP",
    isExpandable: true,
    fullName: "Efficacité Médicale Perçue",
    crossAxis: 12,
    mainAxis: 5,
    child: LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: constraints.maxHeight.clamp(80.0, 140.0),
              height: constraints.maxHeight.clamp(80.0, 140.0),
              child: Q1PieChart(),
            ),
          ),
          Expanded(child: Q1MultiSplineChart()),
        ],
      ),
    ),
  ),

  DashboardItem(
    title: "VQPS",
    fullName: "Vécu Qualitatif du Parcours de Soins",
    crossAxis: 12,
    mainAxis: 8,
    isExpandable: true,
    child: VerbatimBarChart(questionKey: 'q2'),
    secondaryChild: QuestionSunburstSection(questionKey: 'q2'),
  ),

  DashboardItem(
    title: "MCR",
    fullName: "Moments Critiques & Réputation de l'Établissement",
    crossAxis: 12,
    mainAxis: 8,
    isExpandable: true,
    child: VerbatimBarChart(questionKey: 'q3'),
    secondaryChild: QuestionSunburstSection(questionKey: 'q3'),
  ),

  DashboardItem(
    title: "IAR",
    fullName: "Indice d'Amélioration & de Réputation",
    crossAxis: 12,
    mainAxis: 8,
    isExpandable: true,
    child: VerbatimBarChart(questionKey: 'q4'),
    secondaryChild: QuestionSunburstSection(questionKey: 'q4'),
  ),

  DashboardItem(
    title: "Voix Patients",
    fullName: "Verbatims des patients",
    crossAxis: 12,
    mainAxis: 8,
    child: VerbatimFeedSection(),
  ),
];
