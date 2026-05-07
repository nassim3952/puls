import 'package:flutter/material.dart';
import 'package:puls/core/shared_widget/widgets.dart';
import '../../../../core/color.dart';

Widget alertCard() {
  return SingleChildScrollView(
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
        AppWidget.alertTile(
          StatusType.warning,
          "Erreur système",
          "5 minutes",
          "Une erreur de connexion a été détectée",
          AppColors.warning,
          false,
        ),
        AppWidget.alertTile(
          StatusType.warning,
          "Erreur système",
          "5 minutes",
          "Une erreur de connexion a été détectée",
          AppColors.warning,
          false,
        ),
        AppWidget.alertTile(
          StatusType.success,
          "Erreur système",
          "5 minutes",
          "Une erreur de connexion a été détectée",
          AppColors.success,
          false,
        )
      ],
    ),
  );
}