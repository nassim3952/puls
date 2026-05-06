import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/chart_model.dart';
import 'package:puls/core/shared_widget/app_chart.dart';
import '../../data/chart_data.dart';
import '../model/dashboard_item.dart';

final dashboardItems = [
  DashboardItem(
    title: "ISGPP",
    fullName: "Indice de Satisfaction Globale du Parcours Patient",
    icon: Icons.speed,
    crossAxis: 6,
    mainAxis: 3,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        AppCharts.gauge(58, AppColors.primaryMenthe),
        Expanded(
          child: AppCharts.spline([
            SplineGroup(
              name: "Parcours A",
              color: Colors.blue,
              data: [ChartDataSpline('Jan', 60), ChartDataSpline('Feb', 45)],
            ),
            SplineGroup(
              name: "Parcours B",
              color: Colors.teal,
              data: [ChartDataSpline('Jan', 30), ChartDataSpline('Feb', 55)],
            ),
          ]),
        ),
      ],
    ),
  ),
  DashboardItem(
    title: "EMP",
    fullName: "Efficacité Médicale Perçue",
    icon: Icons.graphic_eq,
    crossAxis: 6,
    mainAxis: 3,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppCharts.pie(fakePieDate),
        Expanded(
          child: AppCharts.spline([
            SplineGroup(
              name: "Parcours A",
              color: Colors.blue,
              data: [ChartDataSpline('Jan', 60), ChartDataSpline('Feb', 45)],
            ),
            SplineGroup(
              name: "Parcours B",
              color: Colors.teal,
              data: [ChartDataSpline('Jan', 30), ChartDataSpline('Feb', 55)],
            ),
          ]),
        ),
      ],
    ),
  ),
  DashboardItem(
    title: "VQPS",
    fullName: "Vécu Qualitatif du Parcours de Soins",
    icon: Icons.graphic_eq,
    crossAxis: 3,
    mainAxis: 3,
    child: const Center(child: Text("horizontal Bar Chart")),
  ),
  DashboardItem(
    title: "IAR",
    fullName: "Indice d'Amélioration & de Réputation",
    icon: Icons.graphic_eq,
    crossAxis: 6,
    mainAxis: 3,
    child:  Center(child: Container(child: Text("Diverging Bar Chart"))),
  ),
];
