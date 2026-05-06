import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:puls/core/shared_widget/state_card.dart';
import 'package:puls/core/shared_widget/widgets.dart';

import '../../../../core/color.dart';



Widget alertCard() {
  return StaggeredGridTile.count(
    crossAxisCellCount: 6,
    mainAxisCellCount: 3,
    child: StatCard(
      title: "Alertes",
      fullName: "",
      icon: Icons.warning_amber_outlined,
      onMorePressed: () {},
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppWidget.alertTile(
              StatusType.error,
              "Erreur système",
              "5 minutes",
              "Une erreur de connexion a été détectée",
              AppColors.error,
              false,
            ),
          ],
        ),
      ),
    ),
  );
}