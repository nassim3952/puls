import 'package:flutter/material.dart';

class AppColors {

  static const Gradient primaryGradient = LinearGradient(
    colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
    end: Alignment.centerLeft,
    begin: Alignment.centerRight,
  );

  static const infoText = Color(0xFF3B82F6);

  // Surface & fond de page
  static const Color surface        = Color(0xFFFCFEFF); // fond page — gris très léger, jamais blanc pur
  static const Color divider        = Color(0xFFE9ECF0); // séparateurs visibles


  // Blues
// Des bleus plus "calmes" et élégants
  static const Color primaryBlue     = Color(0xFF0284C7); // Plus stable, moins "cyan"
  static const Color primaryBlueDark    = Color(0xFF0369A1);
  static const Color primaryBlueDarker  = Color(0xFF075985);
  static const Color primaryBlueLight   = Color(0xFFBAE6FD);
  static const Color primaryBlueLighter = Color(0xFFF0F9FF); // Un peu plus subtil

// Un gris très léger pour le fond, c'est mieux pour les yeux
  static const Color primaryBG          = Color(0xFFF2F7FA);
  static const Color textFieldHover     = Color(0xFFE0F2FE);

// Status colors (plus lisibles)
  static const Color primarySuccess = Color(0xFF4DD37D);
  static const Color primaryWarning = Color(0xFFD97706);
  static const Color primaryError   = Color(0xFFDC2626);
  static const Color primaryNeutral = Color(0xFF64748B);

  // Bordure moins "sale" (plus discrète)
  static const Color border         = Color(0xFFE2E8F0);

  static const Color white  = Colors.white;
  static const Color shadow = Colors.black;

  // Texte (on vire le mélange de gris bleu et gris chaud pour un truc uniforme)
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textMid       = Color(0xFF475569);
  static const Color sideBarText   = Color(0xFF475569); // Uniformisé avec textMid
  static const Color textSecondary = Color(0xFF64748B);
  static const Color kTextSub      = Color(0xFF94A3B8);
  static const Color black         = Color(0xFF000000);


  static const blueFaint    = Color(0xFFEFF6FF); // fond bleu très léger
  static const redFaint     = Color(0xFFFFF1F2); // fond rouge très léger
  static const orangeFaint  = Color(0xFFFFF7ED); // fond orange très léger

  //Bordures niveau alerte — plus douces que les couleurs vives
  static const urgentBorder  = Color(0xFFFCA5A5); // rouge poudré
  static const warningBorder = Color(0xFFD4A96A); // brun doré, ni trop jaune ni trop orange
  static const infoBorder    = Color(0xFFBAE6FD); // bleu clair existant

}