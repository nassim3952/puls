import '../color.dart';
import '../models/chart_model.dart';

final splineData1 = [
  SplineGroup(
    name: "Oui totalement",
    color: AppColors.primaryBlue,
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
    color: AppColors.primaryNeutral,
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
    color: AppColors.primaryError,
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
    color: AppColors.primaryWarning,
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

