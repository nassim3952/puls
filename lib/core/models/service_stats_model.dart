import 'package:flutter/material.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/models/visit_model.dart';

class ServiceStats {
  final String serviceName;
  final double averageIsgpp; // Moyenne des qualitePriseEnCharge
  final int totalVisits;
  final int alertCount; // Nombre de visites avec alerte
  final List<PatientModel> patients; // Patients du service

  const ServiceStats({
    required this.serviceName,
    required this.averageIsgpp,
    required this.totalVisits,
    required this.alertCount,
    required this.patients,
  });

  // Calculé depuis la liste des patients
  static ServiceStats fromPatients(
      String serviceName,
      List<PatientModel> patients,
      ) {
    // Filtrer les visites du service
    final visitsInService = <VisitModel>[];
    final patientsInService = <PatientModel>[];

    for (final patient in patients) {
      final visites = patient.visits
          .where((v) => v.service == serviceName)
          .toList();

      if (visites.isNotEmpty) {
        visitsInService.addAll(visites);
        patientsInService.add(patient.copyWith(visits: visites));
      }
    }

    // Calculer la moyenne ISGPP (qualitePriseEnCharge)
    final scores = visitsInService
        .where((v) => v.survey != null)
        .map((v) => v.survey!.qualitePriseEnCharge.toDouble())
        .toList();

    final avgIsgpp = scores.isEmpty
        ? 0.0
        : scores.reduce((a, b) => a + b) / scores.length;

    // Compter les alertes
    final alertCount = visitsInService.where((v) => v.hasAlert).length;

    return ServiceStats(
      serviceName: serviceName,
      averageIsgpp: avgIsgpp,
      totalVisits: visitsInService.length,
      alertCount: alertCount,
      patients: patientsInService,
    );
  }

  // Couleur dynamique selon le score
  static Color getIsgppColor(double score) {
    if (score >= 4.0) return const Color(0xFF4DD37D); // Vert
    if (score >= 3.0) return const Color(0xFFD97706); // Ambre
    return const Color(0xFFDC2626); // Rouge
  }

  Color get isgppColor => getIsgppColor(averageIsgpp);
}
