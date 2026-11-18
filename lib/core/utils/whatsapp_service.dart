import 'package:supabase_flutter/supabase_flutter.dart';

class WhatsappService {
  final SupabaseClient _supabase;

  WhatsappService(this._supabase);

  /// Envoie un message WhatsApp via l'Edge Function `send-whatsapp`.
  ///
  /// [phone] - Numéro de téléphone au format international (+212...)
  /// [message] - Contenu du message
  ///
  /// `functions.invoke` ajoute automatiquement l'apikey et le jeton de
  /// l'utilisateur connecté : la fonction déployée sur le VPS refuse les
  /// appels anonymes (401 « connexion requise »).
  ///
  /// Retourne le messageId si succès, throw une exception si erreur
  Future<String> sendMessage({
    required String phone,
    required String message,
  }) async {
    if (_supabase.auth.currentSession == null) {
      throw WhatsappSendException(message: 'Connexion requise');
    }

    try {
      final response = await _supabase.functions.invoke(
        'send-whatsapp',
        body: {'phone': phone, 'message': message},
      );

      final data = response.data;
      if (data is Map && data['success'] == true) {
        return data['messageId']?.toString() ?? 'unknown';
      }
      throw WhatsappSendException(message: _errorFrom(data));
    } on FunctionException catch (e) {
      throw WhatsappSendException(message: _errorFrom(e.details));
    } on WhatsappSendException {
      rethrow;
    } catch (e) {
      throw WhatsappSendException(message: 'Erreur: $e');
    }
  }

  static String _errorFrom(dynamic data) {
    if (data is Map) {
      final err = data['error'] ?? data['message'];
      if (err != null) return err.toString();
    }
    return 'Erreur inconnue';
  }
}

class WhatsappSendException implements Exception {
  final String message;

  WhatsappSendException({required this.message});

  @override
  String toString() => message;
}
