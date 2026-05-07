import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/shared_widget/state_card.dart';
import '../model/dashboard_item.dart';

Widget buildTile(DashboardItem item, int crossAxisCount,Widget? headerWidget) {
  // LOGIQUE RESPONSIVE :
  // Si on est sur mobile (crossAxisCount de 4), on force la tuile à prendre
  // toute la largeur (4), sinon on garde la valeur définie dans l'item.
  int responsiveCrossAxis = crossAxisCount <= 4 ? crossAxisCount : item.crossAxis;

  return StaggeredGridTile.count(
    crossAxisCellCount: responsiveCrossAxis,
    mainAxisCellCount: item.mainAxis,
    child: StatCard(
      title: item.title,
      headerWidget: headerWidget,
      fullName: item.fullName,
      icon: item.icon,
      onMorePressed: () {},
      child: item.builder != null
          ? item.builder!()
          : (item.child ?? const SizedBox()),
    ),
  );
}