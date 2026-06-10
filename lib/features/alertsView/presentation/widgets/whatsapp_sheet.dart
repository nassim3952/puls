import 'package:flutter/material.dart';
import 'package:puls/core/shared_widget/action_button.dart';
import 'package:puls/features/alertsView/presentation/widgets/sheet_base.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/color.dart';
import '../../../../core/utils/whatsapp_service.dart';
import 'alert_view.dart';


class WhatsappSheet extends StatefulWidget {
  final AlertView alert;
  const WhatsappSheet({required this.alert});

  @override
  State<WhatsappSheet> createState() => _WhatsappSheetState();
}

class _WhatsappSheetState extends State<WhatsappSheet> {
  late TextEditingController _messageController;
  bool _isLoading = false;
  late WhatsappService _whatsappService;

  final List<String> _suggestedMessages = [
    'Bonjour {patient}, nous avons bien reçu votre retour. Comment vous sentez-vous aujourd\'hui ?',
    'Suite à votre signalement, votre médecin a été informé. Pouvez-vous préciser l\'intensité de vos symptômes ?',
    'Nous vous rappelons votre prochain rendez-vous. Avez-vous des questions ?',
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _whatsappService = WhatsappService(Supabase.instance.client);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// Ajoute un message suggéré au TextField
  void _insertSuggestedMessage(String message) {
    setState(() {
      _messageController.text = message;
    });
  }

  /// Envoie le message via WhatsApp
  Future<void> _sendMessage() async {
    final phone = widget.alert.phone;
    final message = _messageController.text.trim();

    // Validations
    if (phone == null || phone.isEmpty) {
      _showError('Numéro de téléphone manquant');
      return;
    }

    if (message.isEmpty) {
      _showError('Veuillez écrire un message');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _whatsappService.sendMessage(
        phone: phone,
        message: message,
      );

      if (!mounted) return;

      _showSuccess('Message envoyé avec succès');
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      _showError('Erreur lors de l\'envoi: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryError,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF25D366),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF25D366), size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Répondre via WhatsApp',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  Text(widget.alert.patientName,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Messages suggérés
          const Text('Messages suggérés',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          const SizedBox(height: 12),
          ..._suggestedMessages.map(
                (m) => _SuggestedMsg(
              text: m,
              onTap: () => _insertSuggestedMessage(m),
            ),
          ),
          const SizedBox(height: 20),

          // Message personnalisé
          const Text('Message personnalisé',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surface, width: 1.5),
            ),
            child: TextField(
              controller: _messageController,
              maxLines: 4,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                hintText: 'Écrire un message...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bouton d'envoi
          AppButton(
            text: _isLoading ? "Envoi en cours..." : "Envoyer sur WhatsApp",
            icon: _isLoading ? Icons.hourglass_empty_rounded : Icons.send_rounded,
            onTap: _isLoading ? () {} : _sendMessage,
          ),
        ],
      ),
    );
  }
}

// ─── Widget pour un message suggéré ──────────────────────────────────────────

class _SuggestedMsg extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestedMsg({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surface, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: AppColors.textMid, fontSize: 13, height: 1.4)),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }
}