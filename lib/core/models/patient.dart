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
  final bool? planIsValid; // nullable : null = en attente, true = validé, false = rejeté/actif
  final String planBy;
  final DateTime? resolvedAt;
  final String? actionPlanLabel;  // "Contact avec rapport" | "Directement un rapport" | null
  final String? actionPlanReport; // texte du rapport saisi

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
    this.actionPlanLabel,
    this.actionPlanReport,
  });

  PatientModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? sex,
    String? ipp,
    String? service,
    String? visitType,
    String? exploration,
    String? afterCare,
    DateTime? date,
    PatientResponse? patientResponse,
    bool? hasAlert,
    bool? alertResolved,
    // planIsValid est nullable donc on utilise une sentinel
    Object? planIsValid = _sentinel,
    String? planBy,
    DateTime? resolvedAt,
    Object? actionPlanLabel = _sentinel,
    Object? actionPlanReport = _sentinel,
  }) {
    return PatientModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      sex: sex ?? this.sex,
      ipp: ipp ?? this.ipp,
      service: service ?? this.service,
      visitType: visitType ?? this.visitType,
      exploration: exploration ?? this.exploration,
      afterCare: afterCare ?? this.afterCare,
      date: date ?? this.date,
      patientResponse: patientResponse ?? this.patientResponse,
      hasAlert: hasAlert ?? this.hasAlert,
      alertResolved: alertResolved ?? this.alertResolved,
      planIsValid: planIsValid == _sentinel
          ? this.planIsValid
          : planIsValid as bool?,
      planBy: planBy ?? this.planBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      actionPlanLabel: actionPlanLabel == _sentinel
          ? this.actionPlanLabel
          : actionPlanLabel as String?,
      actionPlanReport: actionPlanReport == _sentinel
          ? this.actionPlanReport
          : actionPlanReport as String?,
    );
  }

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
      planIsValid: json['plan_is_valid'] as bool?,
      planBy: json['plan_by'] ?? '',
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      actionPlanLabel: json['action_plan_label'] as String?,
      actionPlanReport: json['action_plan_report'] as String?,
    );
  }
}

// Sentinel pour distinguer "pas passé" de "null explicite" dans copyWith
const Object _sentinel = Object();