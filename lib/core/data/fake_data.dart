import 'package:flutter/material.dart';

import '../color.dart';
import '../models/chart_model.dart';

final splineData1 = [
  SplineGroup(
    name: "Oui totalement",
    color: AppColors.success,
    data: [
      ChartDataSpline('Jan', 60),
      ChartDataSpline('Feb', 45),
      ChartDataSpline('Mar', 52),
      ChartDataSpline('Apr', 45),
      ChartDataSpline('May', 55),
    ],
  ),
  SplineGroup(
    name: "En partie",
    color: AppColors.warning,
    data: [
      ChartDataSpline('Jan', 30),
      ChartDataSpline('Feb', 55),
      ChartDataSpline('Mar', 59),
      ChartDataSpline('Apr', 40),
      ChartDataSpline('May', 45),
    ],
  ),
  SplineGroup(
    name: "Non",
    color: AppColors.error,
    data: [
      ChartDataSpline('Jan', 38),
      ChartDataSpline('Feb', 58),
      ChartDataSpline('Mar', 67),
      ChartDataSpline('Apr', 49),
      ChartDataSpline('May', 60),
    ],
  ),
  SplineGroup(
    name: "En attente",
    color: AppColors.neutral,
    data: [
      ChartDataSpline('Jan', 20),
      ChartDataSpline('Feb', 25),
      ChartDataSpline('Mar', 39),
      ChartDataSpline('Apr', 20),
      ChartDataSpline('May', 25),
    ],
  ),
];

final splineData2 = [
  SplineGroup(
    name: "kpi",
    data: [
      ChartDataSpline('Jan', 60),
      ChartDataSpline('Feb', 45),
      ChartDataSpline('Mar', 52),
      ChartDataSpline('Apr', 45),
      ChartDataSpline('May', 55),
    ],
  ),





];

final kpi1Jauge = 85;
final kpi1Spline = splineData2;

final kpi2Pie = [
  ChartDataPie('Oui totalement', 45, AppColors.success),
  ChartDataPie('En partie', 35, AppColors.warning),
  ChartDataPie('Non', 30, AppColors.error),
  ChartDataPie('En attente', 38,AppColors.neutral),
];
final kpi2Spline = splineData1;

final List<BarData> dataIAR = [
  BarData(label: "Accueil", value: 85, valence: Valence.bonne),
  BarData(label: "Attente", value: 42, valence: Valence.mauvaise),
  BarData(label: "Empathie", value: 92, valence: Valence.bonne),
  BarData(label: "Écoute", value: 78, valence: Valence.mauvaise),
  BarData(label: "Médecin", value: 88, valence: Valence.neutre),
  BarData(label: "Soins", value: 95, valence: Valence.neutre),
  BarData(label: "Douleur", value: 30, valence: Valence.critique),
  BarData(label: "Explication", value: 65, valence: Valence.neutre),
  BarData(label: "Propreté", value: 82, valence: Valence.bonne),
  BarData(label: "Hygiène", value: 90, valence: Valence.neutre),
  BarData(label: "Coordination", value: 55, valence: Valence.neutre),
  BarData(label: "Orientation", value: 48, valence: Valence.neutre),
  BarData(label: "Matériel", value: 70, valence: Valence.neutre),
];