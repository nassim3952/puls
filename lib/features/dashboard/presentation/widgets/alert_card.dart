import 'package:flutter/material.dart';
import 'package:puls/core/shared_widget/alert_tile.dart';
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
          AppColors.primaryMentheError,
          false,
        ),
        AppWidget.alertTile(
          StatusType.warning,
          "Erreur système",
          "5 minutes",
          "Une erreur de connexion a été détectée",
          AppColors.primaryMentheWarning,
          false,
        ),
        AppWidget.alertTile(
          StatusType.warning,
          "Erreur système",
          "5 minutes",
          "Une erreur de connexion a été détectée",
          AppColors.primaryMentheWarning,
          false,
        ),
        AppWidget.alertTile(
          StatusType.success,
          "Erreur système",
          "5 minutes",
          "Une erreur de connexion a été détectée",
          AppColors.primaryMenthe,
          false,
        )
      ],
    ),
  );
}