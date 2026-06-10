import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class WhatsappService {
  final SupabaseClient _supabase;

  WhatsappService(this._supabase);

  /// Envoie un message WhatsApp via l'Edge Function
  ///
  /// [phone] - Numéro de téléphone au format international (+212...)
  /// [message] - Contenu du message
  ///
  /// Retourne le messageId si succès, throw une exception si erreur
  Future<String> sendMessage({
    required String phone,
    required String message,
  }) async {
    try {
      // Récupère le project ref depuis la configuration Supabase
      final projectRef = _extractProjectRef();

      final url = Uri.parse(
        'https://$projectRef.supabase.co/functions/v1/send-whatsapp',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'message': message,
        }),
      );

      // Parse la réponse
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return data['messageId'] as String? ?? 'unknown';
      } else {
        throw WhatsappSendException(
          message: data['error'] as String? ?? 'Erreur inconnue',
        );
      }
    } catch (e) {
      if (e is WhatsappSendException) rethrow;
      throw WhatsappSendException(
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Extrait le project ref depuis la configuration Supabase
  /// Ex: "yyohrbyjwemiqfpplmtj"
  String _extractProjectRef() {
    // Hardcode le project ref directement
    return 'yyohrbyjwemiqfpplmtj';
  }}

class WhatsappSendException implements Exception {
  final String message;

  WhatsappSendException({required this.message});

  @override
  String toString() => message;
}