import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/shared_widget/action_button.dart';
import 'package:puls/features/alertsView/presentation/widgets/pain_score_bar.dart';
import 'package:puls/features/alertsView/presentation/widgets/plan_sheet.dart';
import 'package:puls/features/alertsView/presentation/widgets/section_title.dart';
import 'package:puls/features/alertsView/presentation/widgets/sheet_base.dart';
import 'package:puls/features/alertsView/presentation/widgets/whatsapp_sheet.dart';

import 'adaptativesheet.dart';
import 'alert_view.dart';
import 'detail_berbatime_card.dart';
import 'info_row.dart';

class DetailSheet extends StatelessWidget {
  final AlertView alert;

  const DetailSheet({required this.alert});

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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    alert.avatarInitials,
                    style: const TextStyle(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.patientName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    alert.patientId,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionTitle('Informations patient'),
          InfoRow(
            Icons.medical_information_outlined,
            'Type de visite',
            alert.source.latestVisit?.visitType ?? '–',
          ),
          InfoRow(
            Icons.local_hospital_outlined,
            'Service',
            alert.source.latestVisit?.service ?? '–',
          ),
          InfoRow(
            Icons.science_outlined,
            'Exploration',
            (alert.source.latestVisit?.exploration.isNotEmpty ?? false)
                ? alert.source.latestVisit!.exploration
                : 'N/A',
          ),
          InfoRow(
            Icons.calendar_today_outlined,
            'Date de visite',
            alert.lastVisit,
          ),
          InfoRow(Icons.badge_outlined, 'IPP', alert.source.ipp),
          const SizedBox(height: 20),
          SectionTitle('Verbatim patient'),
          // On affiche raconteParcours (q2) et suggestionsAmelioration (q4)
          if (alert
              .source
              .latestVisit
              ?.survey
              ?.raconteParcours
              .message
              .isNotEmpty ??
              false) ...[
            VerbatimCard(
              icon: Icons.thumb_up_outlined,
              color: AppColors.primaryBlue,
              bg: AppColors.primaryBlueLighter,
              label: 'Point positif',
              message:
              alert.source.latestVisit!.survey!.raconteParcours.message,
              classe: alert.source.latestVisit!.survey!.raconteParcours.classe,
            ),
            const SizedBox(height: 10),
          ],
          if (alert
              .source
              .latestVisit
              ?.survey
              ?.suggestionsAmelioration
              .message
              .isNotEmpty ??
              false) ...[
            VerbatimCard(
              icon: Icons.build_outlined,
              color: AppColors.primaryWarning,
              bg: AppColors.surface,
              label: 'Point à améliorer',
              message: alert
                  .source
                  .latestVisit!
                  .survey!
                  .suggestionsAmelioration
                  .message,
              classe: alert
                  .source
                  .latestVisit!
                  .survey!
                  .suggestionsAmelioration
                  .classe,
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 20),
          SectionTitle('Score de satisfaction'),
          const SizedBox(height: 10),
          PainScoreBar(score: alert.painScore),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'WhatsApp',
                  icon: Icons.chat_bubble_outline_rounded,
                  outlined: true,
                  onTap: () {
                    Navigator.pop(context); // ferme DetailSheet
                    // ← NOUVEAU : utilise showAdaptiveSheet
                    showAdaptiveSheet(
                      context,
                      child: WhatsappSheet(alert: alert),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  text: 'Plan d\'action',
                  icon: Icons.assignment_outlined,
                  onTap: () {
                    Navigator.pop(context); // ferme DetailSheet
                    // ← NOUVEAU : utilise showAdaptiveSheet
                    showAdaptiveSheet(
                      context,
                      child: PlanSheet(alert: alert),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}