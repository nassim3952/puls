import 'package:flutter/material.dart';

class AppColors {

  static const Gradient primaryGradient = LinearGradient(
    colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
    end: Alignment.centerLeft,
    begin: Alignment.centerRight,
  );

  static const infoText = Color(0xFF2A9E7C);

  // Surface & fond de page
  static const Color surface        = Colors.white; // fond page — menthe désaturé, doux 0xFFFDFFFE
  static const Color divider        = Color(0xFFD0E8E0); // séparateurs discrets


  // Greens menthe désaturés — professionnels
  static const Color primaryBlue        = Color(0xFF2A9E7C); // menthe sobre, lisible, médical
  static const Color primaryBlueDark    = Color(0xFF228567);
  static const Color primaryBlueDarker  = Color(0xFF1A6B52);
  static const Color primaryBlueLight   = Color(0xFFB2DDD1); // menthe pastel doux
  static const Color primaryBlueLighter = Color(0xFFEEF8F5); // fond quasi-blanc teinté

  static const Color primaryBG          = Color(0xFFF2FAF7);
  static const Color textFieldHover     = Color(0xFFDDF0EA);

  // Status colors
  static const Color primarySuccess = Color(0xFF2A9E7C);
  static const Color primaryWarning = Color(0xFFE48C26);
  static const Color primaryError   = Color(0xFFFA4B4B);
  static const Color primaryNeutral = Color(0xFF788A83);

  static const Color border         = Color(0xFFC8E2D9);

  static const Color white  = Colors.white;
  static const Color shadow = Colors.black;

  // Texte — contrastes renforcés
  static const Color textPrimary   = Color(0xFF0D1E1A); // quasi-noir teinté vert, excellent contraste
  static const Color textMid       = Color(0xFF2E5247);
  static const Color sideBarText   = Color(0xFF2E5247);
  static const Color textSecondary = Color(0xFF4E7268);
  static const Color kTextSub      = Color(0xFF85AFA4);
  static const Color black         = Color(0xFF000000);

  static const blueFaint    = Color(0xFFEBF7F3); // fond menthe très léger
  static const redFaint     = Color(0xFFFFF1F2);
  static const orangeFaint  = Color(0xFFFFF7ED);

  // Bordures niveau alerte
  static const urgentBorder  = Color(0xFFFCA5A5);
  static const warningBorder = Color(0xFFD4A96A);
  static const infoBorder    = Color(0xFFB2DDD1);

}