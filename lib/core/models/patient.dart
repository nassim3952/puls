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
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final patientData = json['patient'] as Map<String, dynamic>;
    final answersData = json['answers'] as Map<String, dynamic>;

    return PatientModel(
      id: json['id'],
      firstName: patientData['first_name'],
      lastName: patientData['last_name'],
      sex: patientData['sex'],
      ipp: patientData['ipp'],
      service: patientData['service'],
      visitType: patientData['visit_type'],
      exploration: patientData['exploration'],
      afterCare: patientData['aftercare'],
      date: DateTime.parse(patientData['date']),
      hasAlert: json['has_alert'] ?? false,
      patientResponse: PatientResponse.fromJson(answersData),
    );
  }
}
