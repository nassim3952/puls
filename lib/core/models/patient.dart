import 'package:puls/core/models/patient_response.dart';

class PatientModel {
  final String id;
  final String firstName;
  final String lastName;
  final String sex;
  final String ipp;
  final String service;
  final String visitType;
  final String exploration;
  final String afterCare;
  final DateTime date;
  final PatientResponse patientResponse;
  final bool hasAlert;
  final bool alertResolved;
  final bool planIsValid;
  final String planBy;
  final DateTime? resolvedAt; // Changé en nullable car si l'alerte n'est pas résolue, c'est null

  PatientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.sex,
    required this.ipp,
    required this.service,
    required this.visitType,
    required this.exploration,
    required this.afterCare,
    required this.date,
    required this.patientResponse,
    required this.hasAlert,
    required this.alertResolved,
    required this.planIsValid,
    required this.planBy,
    required this.resolvedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final patientData = json['patient'] as Map<String, dynamic>? ?? {};
    final answersData = json['answers'] as Map<String, dynamic>? ?? {};

    return PatientModel(
      id: json['id']?.toString() ?? '',
      firstName: patientData['first_name'] ?? 'Inconnu',
      lastName: patientData['last_name'] ?? 'Inconnu',
      sex: patientData['sex'] ?? 'N/A',
      ipp: patientData['ipp'] ?? '',
      service: patientData['service'] ?? '',
      visitType: patientData['visit_type'] ?? '',
      exploration: patientData['exploration'] ?? '',
      afterCare: patientData['aftercare'] ?? '',
      date: patientData['date'] != null
          ? DateTime.parse(patientData['date'])
          : DateTime.now(),
      patientResponse: PatientResponse.fromJson(answersData),
      hasAlert: json['has_alert'] ?? false,
      alertResolved: json['alert_resolved'] ?? false,
      planIsValid: json['plan_is_valid'] ?? false,
      planBy: json['plan_by'] ?? '',
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
    );
  }
}