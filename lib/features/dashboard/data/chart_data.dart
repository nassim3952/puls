import 'package:puls/core/models/chart_model.dart';
import 'package:puls/core/shared_widget/app_chart.dart';

import '../../../core/color.dart';

final fakeSplineData = [
  ChartDataSpline('Jan', 85),
  ChartDataSpline('Feb', 48),
  ChartDataSpline('Mar', 65),
  ChartDataSpline('Apr', 58),
];

final fakePieDate = [
  ChartDataPie('Oui totalement', 68, AppColors.success),
  ChartDataPie('En partie', 35, AppColors.warning),
  ChartDataPie('Non', 19, AppColors.error),
  ChartDataPie('En attente', 38, AppColors.neutral),
];