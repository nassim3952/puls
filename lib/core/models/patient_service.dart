import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/models/visit_model.dart';
import 'package:puls/core/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final patientServiceProvider = Provider<PatientService>((ref) {
  final hospitalId = ref.watch(authProvider).user?.hospitalId;
  return PatientService(hospitalId: hospitalId ?? '');
});

class PatientService {
  final _supabase = Supabase.instance.client;
  final String hospitalId;

  PatientService({required this.hospitalId});

  // ── Patients filtrés → remplace filteredPatientsProvider ─────────────────
  Future<List<PatientModel>> fetchFilteredPatients({
    String? service,
    String? type,
    String? exploration,
    String? sortie,
    DateTime? dateStart,
    DateTime? dateEnd,
    String? search,
  }) async {
    try {
      final List<dynamic> response = await _supabase.rpc(
        'get_filtered_patients',
        params: {
          'p_hospital_id': hospitalId,
          if (service?.isNotEmpty == true)     'p_service':    service,
          if (type?.isNotEmpty == true)        'p_type':       type,
          if (exploration?.isNotEmpty == true) 'p_exploration': exploration,
          if (sortie?.isNotEmpty == true)      'p_sortie':     sortie,
          if (dateStart != null) 'p_date_start': dateStart.toIso8601String(),
          if (dateEnd != null)   'p_date_end':   dateEnd.toIso8601String(),
          if (search?.isNotEmpty == true) 'p_search': search,
        },
      );

      return _groupIntoPatients(response);
    } on PostgrestException catch (e) {
      throw Exception('Supabase [${e.code}] : ${e.message}');
    } catch (e) {
      throw Exception('fetchFilteredPatients : $e');
    }
  }

  // ── Alertes par onglet → remplace alertsProvider ──────────────────────────
  Future<List<PatientModel>> fetchAlerts({
    required String tab, // 'active' | 'pending' | 'validated'
    String? service,
    String? type,
    String? exploration,
    String? sortie,
    DateTime? dateStart,
    DateTime? dateEnd,
    String? search,
  }) async {
    try {
      final List<dynamic> response = await _supabase.rpc(
        'get_alerts',
        params: {
          'p_hospital_id': hospitalId,
          'p_tab':         tab,
          if (service?.isNotEmpty == true)     'p_service':    service,
          if (type?.isNotEmpty == true)        'p_type':       type,
          if (exploration?.isNotEmpty == true) 'p_exploration': exploration,
          if (sortie?.isNotEmpty == true)      'p_sortie':     sortie,
          if (dateStart != null) 'p_date_start': dateStart.toIso8601String(),
          if (dateEnd != null)   'p_date_end':   dateEnd.toIso8601String(),
          if (search?.isNotEmpty == true) 'p_search': search,
        },
      );
      return _groupIntoPatients(response);
    } on PostgrestException catch (e) {
      print('🔴 PostgrestException : ${e.message}');
      throw Exception('Supabase [${e.code}] : ${e.message}');
    } catch (e) {
      print('🔴 Exception : $e');
      throw Exception('fetchAlerts : $e');
    }
  }

  // ── Helper : regroupe les lignes plates en PatientModel ───────────────────
  List<PatientModel> _groupIntoPatients(List<dynamic> rows) {
    final map = <String, PatientModel>{};

    for (final row in rows) {
      final r = row as Map<String, dynamic>;
      final patientId = r['patient_id'] as String;
      final visit = VisitModel.fromFlatRow(r);

      if (map.containsKey(patientId)) {
        final existing = map[patientId]!;
        map[patientId] = existing.copyWith(
          visits: [...existing.visits, visit],
        );
      } else {
        map[patientId] = PatientModel(
          id: patientId,
          ipp: r['ipp']?.toString() ?? '',
          firstName: r['first_name']?.toString() ?? '',
          lastName: r['last_name']?.toString() ?? '',
          sex: r['sex']?.toString() ?? '',
          phone: _formatPhoneForWhatsApp(r['phone']?.toString()),
          visits: [visit],
        );
      }
    }

    return map.values.toList();
  }

  /// Formate le numéro de téléphone pour WaSender
  /// Ajoute le + devant si manquant
  /// Exemple : "213797244980" → "+213797244980"
  String? _formatPhoneForWhatsApp(String? phone) {
    if (phone == null || phone.isEmpty) return null;

    // Retire les espaces et caractères spéciaux
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.isEmpty) return null;

    // Si ça commence pas par +, ajoute-le
    if (!cleaned.startsWith('+')) {
      return '+$cleaned';
    }

    return cleaned;
  }
}