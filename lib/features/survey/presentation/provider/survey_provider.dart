import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:puls/features/survey/presentation/provider/pending_survey_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/provider/auth_provider.dart';
import '../../../../core/supabase_config.dart';

// ─── Form state ───────────────────────────────────────────────────────────────

class SendSurveyFormState {
  // Patient résolu
  final String? resolvedPatientId;   // null = pas encore cherché/créé
  final String? resolvedPatientName; // nom affiché dans le chip

  // Champs saisis
  final String ipp;
  final String lastName;
  final String phone;

  // Facultatifs — patient
  final String? firstName;
  final String? sex;
  final DateTime? dateOfBirth;
  final String? email;

  // Facultatifs — visite
  final String? service;
  final String? visitType;
  final String? exploration;
  final String? aftercare;
  final String? doctorAssigned;
  final DateTime? visitDate;

  // UI state
  final bool isSearching;   // debounce recherche phone
  final bool isLoading;
  final String? errorMessage;
  final bool success;

  const SendSurveyFormState({
    this.resolvedPatientId,
    this.resolvedPatientName,
    this.ipp = '',
    this.lastName = '',
    this.phone = '',
    this.firstName,
    this.sex,
    this.dateOfBirth,
    this.email,
    this.service,
    this.visitType,
    this.exploration,
    this.aftercare,
    this.doctorAssigned,
    this.visitDate,
    this.isSearching = false,
    this.isLoading = false,
    this.errorMessage,
    this.success = false,
  });

  /// Patient valide = trouvé en BDD ou créé manuellement
  bool get hasPatient => resolvedPatientId != null;

  /// Visite complète = tous les champs obligatoires remplis
  bool get isVisitValid =>
      hasPatient &&
          service != null &&
          visitType != null &&
          exploration != null &&
          aftercare != null;

  // Garde pour isValid (submitAndSend / submitToQueue)
  bool get isValid => lastName.trim().isNotEmpty && phone.trim().isNotEmpty;

  SendSurveyFormState copyWith({
    Object? resolvedPatientId = _s,
    Object? resolvedPatientName = _s,
    String? ipp,
    String? lastName,
    String? phone,
    Object? firstName = _s,
    Object? sex = _s,
    Object? dateOfBirth = _s,
    Object? email = _s,
    Object? service = _s,
    Object? visitType = _s,
    Object? exploration = _s,
    Object? aftercare = _s,
    Object? doctorAssigned = _s,
    Object? visitDate = _s,
    bool? isSearching,
    bool? isLoading,
    Object? errorMessage = _s,
    bool? success,
  }) {
    return SendSurveyFormState(
      resolvedPatientId:   resolvedPatientId   == _s ? this.resolvedPatientId   : resolvedPatientId   as String?,
      resolvedPatientName: resolvedPatientName == _s ? this.resolvedPatientName : resolvedPatientName as String?,
      ipp:            ipp       ?? this.ipp,
      lastName:       lastName  ?? this.lastName,
      phone:          phone     ?? this.phone,
      firstName:      firstName   == _s ? this.firstName   : firstName   as String?,
      sex:            sex         == _s ? this.sex         : sex         as String?,
      dateOfBirth:    dateOfBirth == _s ? this.dateOfBirth : dateOfBirth as DateTime?,
      email:          email       == _s ? this.email       : email       as String?,
      service:        service     == _s ? this.service     : service     as String?,
      visitType:      visitType   == _s ? this.visitType   : visitType   as String?,
      exploration:    exploration == _s ? this.exploration : exploration as String?,
      aftercare:      aftercare   == _s ? this.aftercare   : aftercare   as String?,
      doctorAssigned: doctorAssigned == _s ? this.doctorAssigned : doctorAssigned as String?,
      visitDate:      visitDate   == _s ? this.visitDate   : visitDate   as DateTime?,
      isSearching:    isSearching ?? this.isSearching,
      isLoading:      isLoading   ?? this.isLoading,
      errorMessage:   errorMessage == _s ? this.errorMessage : errorMessage as String?,
      success:        success      ?? this.success,
    );
  }
}

const Object _s = Object(); // sentinel

// ─── Notifier ─────────────────────────────────────────────────────────────────

class SendSurveyNotifier extends Notifier<SendSurveyFormState> {
  static const String _supabaseUrl = SupabaseConfig.url;

  @override
  SendSurveyFormState build() => SendSurveyFormState(visitDate: DateTime.now());

  // ── Setters basiques ─────────────────────────────────────────────────────
  void setIpp(String v)            => state = state.copyWith(ipp: v);
  void setLastName(String v)       => state = state.copyWith(lastName: v.toUpperCase());
  void setPhone(String v)          => state = state.copyWith(phone: v);
  void setFirstName(String? v)     => state = state.copyWith(firstName: v);
  void setSex(String? v)           => state = state.copyWith(sex: v);
  void setDateOfBirth(DateTime? v) => state = state.copyWith(dateOfBirth: v);
  void setEmail(String? v)         => state = state.copyWith(email: v);
  void setService(String? v)       => state = state.copyWith(service: v);
  void setVisitType(String? v)     => state = state.copyWith(visitType: v);
  void setExploration(String? v)   => state = state.copyWith(exploration: v);
  void setAftercare(String? v)     => state = state.copyWith(aftercare: v);
  void setDoctorAssigned(String? v)=> state = state.copyWith(doctorAssigned: v);
  void setVisitDate(DateTime? v)   => state = state.copyWith(visitDate: v);

  void reset() => state = SendSurveyFormState(visitDate: DateTime.now());
  void clearError() => state = state.copyWith(errorMessage: null);

  /// Réinitialise le patient résolu (quand l'utilisateur change le numéro)
  void clearResolvedPatient() => state = state.copyWith(
    resolvedPatientId: null,
    resolvedPatientName: null,
    lastName: '',
    firstName: null,
    sex: null,
    dateOfBirth: null,
    email: null,
    ipp: '',
  );

  // ── Recherche patient par numéro WhatsApp ────────────────────────────────
  Future<void> searchPatientByPhone() async {
    final formatted = _formatPhone(state.phone.trim());
    if (formatted.length < 9) return;

    final supabase = Supabase.instance.client;
    final authState = ref.read(authProvider);
    final hospitalId = authState.user?.hospitalId;
    if (hospitalId == null) return;

    state = state.copyWith(isSearching: true, errorMessage: null);

    try {
      final result = await supabase
          .from('patients')
          .select('id, last_name, first_name, ipp, sex, date_of_birth, email')
          .eq('hospital_id', hospitalId)
          .eq('phone', formatted)
          .maybeSingle();

      if (result != null) {
        final lastName  = result['last_name']  as String? ?? '';
        final firstName = result['first_name'] as String? ?? '';
        final displayName = [lastName, firstName].where((s) => s.isNotEmpty).join(' ');
        state = state.copyWith(
          isSearching: false,
          resolvedPatientId:   result['id'] as String,
          resolvedPatientName: displayName,
          lastName:    lastName,
          firstName:   firstName.isEmpty ? null : firstName,
          ipp:         result['ipp']           as String? ?? '',
          sex:         result['sex']           as String?,
          email:       result['email']         as String?,
          dateOfBirth: result['date_of_birth'] != null
              ? DateTime.tryParse(result['date_of_birth'] as String)
              : null,
        );
      } else {
        // Patient inconnu — on remet à zéro le patient résolu
        state = state.copyWith(
          isSearching: false,
          resolvedPatientId:   null,
          resolvedPatientName: null,
        );
      }
    } catch (e) {
      state = state.copyWith(isSearching: false, errorMessage: 'Erreur recherche : $e');
    }
  }

  // ── Créer un nouveau patient ─────────────────────────────────────────────
  Future<void> createPatient() async {
    if (state.lastName.trim().isEmpty) return;

    final supabase = Supabase.instance.client;
    final authState = ref.read(authProvider);
    final hospitalId = authState.user?.hospitalId;
    if (hospitalId == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final formatted = _formatPhone(state.phone.trim());
      final result = await supabase
          .from('patients')
          .insert({
        'hospital_id': hospitalId,
        'phone':     formatted,
        'last_name': state.lastName.trim().toUpperCase(),
        if (state.firstName != null) 'first_name':   state.firstName!.trim(),
        if (state.ipp.trim().isNotEmpty) 'ipp':      state.ipp.trim().toUpperCase(),
        if (state.sex != null) 'sex':                state.sex,
        if (state.dateOfBirth != null) 'date_of_birth':
        state.dateOfBirth!.toIso8601String().substring(0, 10),
        if (state.email != null) 'email':            state.email!.trim(),
      })
          .select('id')
          .single();

      final lastName    = state.lastName.trim().toUpperCase();
      final firstName   = state.firstName?.trim() ?? '';
      final displayName = [lastName, firstName].where((s) => s.isNotEmpty).join(' ');

      state = state.copyWith(
        isLoading: false,
        resolvedPatientId:   result['id'] as String,
        resolvedPatientName: displayName,
      );
    } on PostgrestException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erreur BDD : ${e.message}');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erreur : $e');
    }
  }

  // ── Mettre à jour les infos personnelles d'un patient existant ──────────
  Future<void> updatePatientInfo() async {
    final patientId = state.resolvedPatientId;
    if (patientId == null) return;

    final supabase = Supabase.instance.client;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await supabase.from('patients').update({
        'last_name': state.lastName.trim().toUpperCase(),
        if (state.firstName != null) 'first_name':   state.firstName!.trim(),
        if (state.ipp.trim().isNotEmpty) 'ipp':      state.ipp.trim().toUpperCase(),
        if (state.sex != null) 'sex':                state.sex,
        if (state.dateOfBirth != null) 'date_of_birth':
        state.dateOfBirth!.toIso8601String().substring(0, 10),
        if (state.email != null) 'email':            state.email!.trim(),
      }).eq('id', patientId);

      final lastName    = state.lastName.trim().toUpperCase();
      final firstName   = state.firstName?.trim() ?? '';
      final displayName = [lastName, firstName].where((s) => s.isNotEmpty).join(' ');

      state = state.copyWith(
        isLoading: false,
        resolvedPatientName: displayName,
      );
    } on PostgrestException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erreur BDD : ${e.message}');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erreur : $e');
    }
  }

  // ── Ajouter à la file d'attente (status = 'pending') ─────────────────────
  Future<void> submitToQueue() async {
    final patientId = state.resolvedPatientId;
    if (patientId == null || !state.isVisitValid) return;

    state = state.copyWith(isLoading: true, errorMessage: null, success: false);
    final supabase = Supabase.instance.client;

    try {
      final visitDateTime = state.visitDate ?? DateTime.now();
      await supabase.from('visits').insert({
        'patient_id': patientId,
        'canal':  'Whatsapp',
        'date':   visitDateTime.toIso8601String(),
        'status': 'pending',
        if (state.service != null)       'service':         state.service,
        if (state.visitType != null)     'visit_type':      state.visitType,
        if (state.exploration != null)   'exploration':     state.exploration,
        if (state.aftercare != null)     'aftercare':       state.aftercare,
        if (state.doctorAssigned != null)'doctor_assigned': state.doctorAssigned,
      });
      state = state.copyWith(isLoading: false, success: true);
    } on PostgrestException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erreur base de données : ${e.message}');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Une erreur inattendue est survenue : $e');
    }
  }

  // ── Envoyer depuis la file d'attente (patient déjà en BDD) ───────────────
  Future<void> sendFromQueue({
    required String visitId,
    required String patientId,
    required String ipp,
    required String firstName,
    required String lastName,
    required String? phone,
    required String? service,
    required String? visitType,
    required String? exploration,
    required String? aftercare,
    required String? doctorAssigned,
    required DateTime date,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, success: false);

    final authState   = ref.read(authProvider);
    final hospitalName = authState.user?.hospitalName ?? '';

    try {
      final formattedPhone = _formatPhone(phone ?? '');
      final payload = {
        'id':     visitId, // ⚠️ id par visite (et non par patient) pour autoriser plusieurs visites/sondages
        'canal':  'Whatsapp',
        'survey': '1',
        'patient': {
          'first_name':     firstName,
          'last_name':      lastName,
          'sex':            '',
          'birth_date':     '',
          'email':          '',
          'phone':          formattedPhone,
          'country':        'ALG',
          'hospital':       hospitalName.toUpperCase(),
          'service':        service        ?? '',
          'doctor_assigned':doctorAssigned ?? '',
          'visit_type':     visitType      ?? '',
          'exploration':    exploration    ?? '',
          'aftercare':      aftercare      ?? '',
          'ipp':            ipp,
          'date':           date.toIso8601String(),
        },
        'answers': {'q1': '', 'q2': '', 'q3': '', 'q4': '', 'q5': '', 'q6': ''},
      };

      final accessToken = Supabase.instance.client.auth.currentSession?.accessToken ?? '';
      final proxyResponse = await http.post(
        Uri.parse('$_supabaseUrl/functions/v1/proxy-survey'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
        body: jsonEncode(payload),
      );

      if (proxyResponse.statusCode < 200 || proxyResponse.statusCode >= 300) {
        await Supabase.instance.client.from('visits').update({'status': 'failed'}).eq('id', visitId);
        state = state.copyWith(isLoading: false, errorMessage: 'Erreur enregistrement (${proxyResponse.statusCode}). Réessayez.');
        return;
      }

      final sendResponse = await Supabase.instance.client.functions.invoke('send-survey', body: payload);
      if (sendResponse.status < 200 || sendResponse.status >= 300) {
        await Supabase.instance.client.from('visits').update({'status': 'failed'}).eq('id', visitId);
        state = state.copyWith(isLoading: false, errorMessage: 'Erreur WhatsApp (${sendResponse.status}). Réessayez.');
        return;
      }

      await Supabase.instance.client.from('visits').update({'status': 'sent'}).eq('id', visitId);
      ref.invalidate(pendingSurveysProvider);
      state = state.copyWith(isLoading: false, success: true);

    } on PostgrestException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erreur BDD : ${e.message}');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erreur inattendue : $e');
    }
  }

  // ── Envoyer directement (bypass la file) ─────────────────────────────────
  Future<void> submitAndSend() async {
    final patientId = state.resolvedPatientId;
    if (patientId == null || !state.isVisitValid) return;

    state = state.copyWith(isLoading: true, errorMessage: null, success: false);

    final supabase     = Supabase.instance.client;
    final authState    = ref.read(authProvider);
    final hospitalName = authState.user?.hospitalName ?? '';

    try {
      final visitDateTime = state.visitDate ?? DateTime.now();
      final visitInsert   = await supabase.from('visits').insert({
        'patient_id': patientId,
        'canal':  'Whatsapp',
        'date':   visitDateTime.toIso8601String(),
        'status': 'sent',
        if (state.service != null)       'service':         state.service,
        if (state.visitType != null)     'visit_type':      state.visitType,
        if (state.exploration != null)   'exploration':     state.exploration,
        if (state.aftercare != null)     'aftercare':       state.aftercare,
        if (state.doctorAssigned != null)'doctor_assigned': state.doctorAssigned,
      }).select('id').single();

      final visitId        = visitInsert['id'] as String;
      final formattedPhone = _formatPhone(state.phone.trim());

      final payload = {
        'id':     visitId, // ⚠️ id par visite (et non par patient) pour autoriser plusieurs visites/sondages
        'canal':  'Whatsapp',
        'survey': '1',
        'patient': {
          'first_name':     state.firstName ?? '',
          'last_name':      state.lastName.trim().toUpperCase(),
          'sex':            state.sex ?? '',
          'birth_date':     state.dateOfBirth != null
              ? state.dateOfBirth!.toIso8601String().substring(0, 10) : '',
          'email':          state.email ?? '',
          'phone':          formattedPhone,
          'country':        'ALG',
          'hospital':       hospitalName.toUpperCase(),
          'service':        state.service        ?? '',
          'doctor_assigned':state.doctorAssigned ?? '',
          'visit_type':     state.visitType      ?? '',
          'exploration':    state.exploration    ?? '',
          'aftercare':      state.aftercare      ?? '',
          'ipp':            state.ipp.trim().toUpperCase(),
          'date':           visitDateTime.toIso8601String(),
        },
        'answers': {'q1': '', 'q2': '', 'q3': '', 'q4': '', 'q5': '', 'q6': ''},
      };

      final accessToken = supabase.auth.currentSession?.accessToken ?? '';
      final proxyResponse = await http.post(
        Uri.parse('$_supabaseUrl/functions/v1/proxy-survey'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
        body: jsonEncode(payload),
      );

      if (proxyResponse.statusCode < 200 || proxyResponse.statusCode >= 300) {
        await supabase.from('visits').update({'status': 'failed'}).eq('id', visitId);
        state = state.copyWith(isLoading: false, success: false,
            errorMessage: 'Erreur enregistrement (${proxyResponse.statusCode}). Réessayez depuis la file.');
        return;
      }

      final sendResponse = await supabase.functions.invoke('send-survey', body: payload);
      if (sendResponse.status < 200 || sendResponse.status >= 300) {
        await supabase.from('visits').update({'status': 'failed'}).eq('id', visitId);
        state = state.copyWith(isLoading: false, success: false,
            errorMessage: 'Erreur WhatsApp (${sendResponse.status}). Réessayez depuis la file.');
        return;
      }

      state = state.copyWith(isLoading: false, success: true);

    } on PostgrestException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erreur base de données : ${e.message}');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Une erreur inattendue est survenue : $e');
    }
  }

  Future<void> submit() => submitAndSend();

  static String _formatPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('213')) return digits;
    if (digits.startsWith('0'))   return '213${digits.substring(1)}';
    return '213$digits';
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final sendSurveyProvider =
NotifierProvider<SendSurveyNotifier, SendSurveyFormState>(
  SendSurveyNotifier.new,
);