import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/models/patient.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final patientServiceProvider = Provider<PatientService>((ref) => PatientService());

class PatientService {
  final _supabase = Supabase.instance.client;

  Future<List<PatientModel>> fetchPatients() async {
    try {
      final List<dynamic> response = await _supabase
          .from('patients')
          .select('*, visits(*, survey_responses(*))')
          .order('date', referencedTable: 'visits', ascending: false);

      return response
          .map((json) => PatientModel.fromSupabase(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Supabase [${e.code}] : ${e.message}');
    } catch (e) {
      throw Exception('fetchPatients : $e');
    }
  }
}