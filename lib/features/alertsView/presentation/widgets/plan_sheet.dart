import 'package:flutter/material.dart';
import 'package:puls/features/alertsView/presentation/widgets/plan_step_card.dart';
import 'package:puls/features/alertsView/presentation/widgets/section_title.dart';
import 'package:puls/features/alertsView/presentation/widgets/sheet_base.dart';

import '../../../../core/color.dart';
import 'alert_view.dart';
import 'green_button.dart';

class PlanSheet extends StatelessWidget {
  final AlertView alert;
  const PlanSheet({required this.alert});

  @override
  Widget build(BuildContext context) {
    final steps = [
      PlanStep(
        icon: Icons.phone_in_talk_outlined,
        color: AppColors.urgentText,
        title: 'Appel prioritaire',
        desc: 'Contacter le patient dans les 2h pour évaluation clinique rapide.',
        delay: 'Immédiat',
      ),
      PlanStep(
        icon: Icons.medical_services_outlined,
        color: AppColors.warningText,
        title: 'Réévaluation médicale',
        desc: 'Programmer une consultation avec le médecin référent sous 24h.',
        delay: '< 24h',
      ),
      PlanStep(
        icon: Icons.chat_bubble_outline_rounded,
        color: const Color(0xFF25D366),
        title: 'Message de suivi',
        desc: 'Envoyer un formulaire de réévaluation via WhatsApp.',
        delay: 'Après appel',
      ),
      PlanStep(
        icon: Icons.monitor_heart_outlined,
        color: AppColors.primary,
        title: 'Monitoring renforcé',
        desc:
        'Activer les alertes quotidiennes pour ce patient pendant 7 jours.',
        delay: 'Continu',
      ),
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
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_outlined,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Plan d'action",
                        style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    Text(alert.patientName,
                        style: const TextStyle(
                            color: AppColors.textLight, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.urgentBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Généré par IA',
                    style: TextStyle(
                        color: AppColors.urgentText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Plan suggéré basé sur : ${alert.source.visitType.toLowerCase()}, score satisfaction ${alert.source.patientResponse.q0}/5.',
                    style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionTitle('Étapes recommandées'),
          const SizedBox(height: 12),
          ...steps
              .asMap()
              .entries
              .map((e) => PlanStepCard(step: e.value, index: e.key + 1)),
          const SizedBox(height: 20),
          GreenBtn(
            label: "Appliquer le plan d'action",
            icon: Icons.check_circle_outline_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 10),
          GreenBtn(
            label: 'Régénérer le plan',
            icon: Icons.refresh_rounded,
            outlined: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
