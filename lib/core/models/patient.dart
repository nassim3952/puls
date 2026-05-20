import 'package:puls/core/models/visit_model.dart';

class PatientModel {
  final String id;
  final String firstName;
  final String lastName;
  final String sex;
  final String ipp;
  final List<VisitModel> visits;

  const PatientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.sex,
    required this.ipp,
    required this.visits,
  });

  // Raccourci dashboard — visite la plus récente (liste triée DESC par le service)
  VisitModel? get latestVisit => visits.isNotEmpty ? visits.first : null;

  factory PatientModel.fromSupabase(Map<String, dynamic> json) {
    final visitsList = _toList(json['visits']);

    final visits = visitsList
        .map((v) => VisitModel.fromSupabase(Map<String, dynamic>.from(v as Map)))
        .toList();

    return PatientModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? 'Inconnu',
      lastName: json['last_name']?.toString() ?? 'Inconnu',
      sex: json['sex']?.toString() ?? 'N/A',
      ipp: json['ipp']?.toString() ?? '',
      visits: visits,
    );
  }

  PatientModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? sex,
    String? ipp,
    List<VisitModel>? visits,
  }) {
    return PatientModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      sex: sex ?? this.sex,
      ipp: ipp ?? this.ipp,
      visits: visits ?? this.visits,
    );
  }

  // Utilisé par alertsNotifier pour les overrides locaux
  PatientModel withUpdatedLatestVisit(VisitModel updatedVisit) {
    if (visits.isEmpty) return this;
    return copyWith(visits: [updatedVisit, ...visits.skip(1)]);
  }
}

List<dynamic> _toList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value;
  if (value is Map) return [value];
  return [];
}