import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';
import 'package:puls/features/alertsView/presentation/widgets/pain_score_bar.dart';
import 'package:puls/features/alertsView/presentation/widgets/section_title.dart';
import 'package:puls/features/alertsView/presentation/widgets/sheet_base.dart';

import 'alert_view.dart';
import 'detail_berbatime_card.dart';
import 'green_button.dart';
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
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(alert.avatarInitials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.patientName,
                      style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  Text(alert.patientId,
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionTitle('Informations patient'),
          InfoRow(Icons.medical_information_outlined, 'Type de visite',
              alert.source.visitType),
          InfoRow(Icons.local_hospital_outlined, 'Service',
              alert.source.service),
          InfoRow(Icons.science_outlined, 'Exploration',
              alert.source.exploration.isNotEmpty
                  ? alert.source.exploration
                  : 'N/A'),
          InfoRow(Icons.calendar_today_outlined, 'Date de visite',
              alert.lastVisit),
          InfoRow(Icons.badge_outlined, 'IPP', alert.source.ipp),
          const SizedBox(height: 20),
          SectionTitle('Verbatim patient'),
          // On affiche q2 (point positif) et q4 (point à améliorer)
          if (alert.source.patientResponse.q2.message.isNotEmpty) ...[
            VerbatimCard(
              icon: Icons.thumb_up_outlined,
              color: AppColors.primary,
              bg: AppColors.primaryLight,
              label: 'Point positif',
              message: alert.source.patientResponse.q2.message,
              classe: alert.source.patientResponse.q2.classe,
            ),
            const SizedBox(height: 10),
          ],
          if (alert.source.patientResponse.q4.message.isNotEmpty) ...[
            VerbatimCard(
              icon: Icons.build_outlined,
              color: AppColors.warningText,
              bg: AppColors.warningBg,
              label: 'Point à améliorer',
              message: alert.source.patientResponse.q4.message,
              classe: alert.source.patientResponse.q4.classe,
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
                child: GreenBtn(
                  label: 'WhatsApp',
                  icon: Icons.chat_bubble_outline_rounded,
                  outlined: true,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GreenBtn(
                  label: 'Plan d\'action',
                  icon: Icons.assignment_outlined,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
