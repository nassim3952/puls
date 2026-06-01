import 'package:flutter/material.dart';
import 'package:puls/core/shared_widget/action_button.dart';
import 'package:puls/features/alertsView/presentation/widgets/sheet_base.dart';

import '../../../../core/color.dart';
import 'alert_view.dart';

class WhatsappSheet extends StatelessWidget {
  final AlertView alert;
  const WhatsappSheet({required this.alert});

  @override
  Widget build(BuildContext context) {
    final messages = [
      'Bonjour ${alert.source.firstName}, nous avons bien reçu votre retour. Comment vous sentez-vous aujourd\'hui ?',
      'Suite à votre signalement, votre médecin a été informé. Pouvez-vous préciser l\'intensité de vos symptômes ?',
      'Nous vous rappelons votre prochain rendez-vous. Avez-vous des questions ?',
    ];

    return SheetBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Text(alert.patientName,
                      style:
                      const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Messages suggérés',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          const SizedBox(height: 12),
          ...messages.map((m) => _SuggestedMsg(text: m)),
          const SizedBox(height: 20),
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
            child: const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Écrire un message...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: "Envoyer sur WhatsApp",
            icon: Icons.send_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _SuggestedMsg extends StatelessWidget {
  final String text;
  const _SuggestedMsg({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

