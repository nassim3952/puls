import 'package:flutter/material.dart';
import '../widgets/kps_gauge.dart'; // Import de ton widget de jauge
import '../widgets/nps_bar_chart.dart'; // Si tu en crées un

class AppCharts {
  // Une méthode static pour la jauge KPS
  static Widget kps(double score) {
    return KpsGauge(score: score);
  }

  // Une méthode static pour le NPS
  static Widget nps(double score) {
    // Imaginons un autre widget ici
    return Center(child: Text("NPS: $score"));
  }

  // Tu peux aussi avoir des constantes pour des éléments purement visuels
  static const Widget loadingSpinner = Center(
    child: CircularProgressIndicator(color: Colors.mint),
  );
}