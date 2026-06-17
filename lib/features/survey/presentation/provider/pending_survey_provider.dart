import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/models/visit_model.dart';
import 'package:puls/core/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// status attendu: 'pending', 'sent', ou 'failed'
final pendingSurveysProvider =
FutureProvider.family<List<PendingSurveyItem>, String>((ref, status) async {
  final supabase = Supabase.instance.client;
  final authState = ref.watch(authProvider);
  final hospitalId = authState.user?.hospitalId;

  if (hospitalId == null) return [];

  try {
    final response = await supabase
        .from('visits')
        .select('''
          id,
          patient_id,
          service,
          visit_type,
          exploration,
          aftercare,
          doctor_assigned,
          date,
          status,
          patients (
            id,
            ipp,
            first_name,
            last_name,
            phone,
            sex,
            date_of_birth,
            email
          )
        ''')
        .eq('status', status)
        .order('date', ascending: false);

    final items = (response as List)
        .map((row) => PendingSurveyItem.fromJson(row))
        .toList();

    return items;
  } catch (e) {
    throw Exception('Erreur lors de la récupération des enquêtes ($status): $e');
  }
});

// ── Notifier (remplace Provider simple) ──────────────────────────────────────
class PendingSurveysNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> deleteFromQueue(String visitId) async {
    final supabase = Supabase.instance.client;
    print('>>> deleteFromQueue appelé avec visitId: $visitId');
    try {
      final result = await supabase.from('visits').delete().eq('id', visitId).select();
      print('>>> résultat suppression: $result');
      ref.invalidate(pendingSurveysProvider);
    } catch (e) {
      print('>>> ERREUR suppression: $e');
      throw Exception('Erreur lors de la suppression: $e');
    }
  }
  Future<void> updatePendingSurvey({
    required String visitId,
    String? service,
    String? visitType,
    String? exploration,
    String? aftercare,
    String? doctorAssigned,
  }) async {
    final supabase = Supabase.instance.client;
    try {
      final updateData = <String, dynamic>{
        if (service != null) 'service': service,
        if (visitType != null) 'visit_type': visitType,
        if (exploration != null) 'exploration': exploration,
        if (aftercare != null) 'aftercare': aftercare,
        if (doctorAssigned != null) 'doctor_assigned': doctorAssigned,
      };
      await supabase.from('visits').update(updateData).eq('id', visitId);
      ref.invalidate(pendingSurveysProvider);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  Future<void> markAsSent(String visitId) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('visits').update({'status': 'sent'}).eq('id', visitId);
      ref.invalidate(pendingSurveysProvider);
    } catch (e) {
      throw Exception('Erreur lors du marquage comme envoyé: $e');
    }
  }

  Future<void> markAsFailed(String visitId, String reason) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('visits').update({'status': 'failed'}).eq('id', visitId);
      ref.invalidate(pendingSurveysProvider);
    } catch (e) {
      throw Exception('Erreur lors du marquage comme échoué: $e');
    }
  }
}

final pendingSurveysNotifierProvider =
NotifierProvider<PendingSurveysNotifier, void>(
  PendingSurveysNotifier.new,
);

// ── Modèle de données ────────────────────────────────────────────────────────
class PendingSurveyItem {
  final String visitId;
  final String patientId;
  final String? ipp;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? service;
  final String? visitType;
  final String? exploration;
  final String? aftercare;
  final String? doctorAssigned;
  final DateTime date;

  const PendingSurveyItem({
    required this.visitId,
    required this.patientId,
    this.ipp,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.service,
    this.visitType,
    this.exploration,
    this.aftercare,
    this.doctorAssigned,
    required this.date,
  });

  String get fullName => '$firstName $lastName';

  factory PendingSurveyItem.fromJson(Map<String, dynamic> json) {
    final patientData = json['patients'] as Map<String, dynamic>?;
    return PendingSurveyItem(
      visitId: json['id']?.toString() ?? '',
      patientId: patientData?['id']?.toString() ?? '',
      ipp: patientData?['ipp']?.toString(),
      firstName: patientData?['first_name']?.toString() ?? '',
      lastName: patientData?['last_name']?.toString() ?? '',
      phone: patientData?['phone']?.toString(),
      service: json['service']?.toString(),
      visitType: json['visit_type']?.toString(),
      exploration: json['exploration']?.toString(),
      aftercare: json['aftercare']?.toString(),
      doctorAssigned: json['doctor_assigned']?.toString(),
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
    );
  }
}