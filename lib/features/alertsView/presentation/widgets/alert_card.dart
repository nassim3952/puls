import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

import 'action_button.dart';
import 'alert_view.dart';

class AlertCard extends StatelessWidget {
  final AlertView alert;
  final VoidCallback onDelete;
  final VoidCallback onWhatsapp;
  final VoidCallback onDetail;
  final VoidCallback onPlan;

  const AlertCard({
    required this.alert,
    required this.onDelete,
    required this.onWhatsapp,
    required this.onDetail,
    required this.onPlan,
  });

  (Color, Color, Color, IconData) get _levelStyle {
    switch (alert.level) {
      case AlertLevel.urgent:
        return (AppColors.urgentBg, AppColors.urgentText,
        AppColors.urgentBorder, Icons.warning_rounded);
      case AlertLevel.warning:
        return (AppColors.warningBg, AppColors.warningText,
        AppColors.warningBorder, Icons.info_outline_rounded);
      case AlertLevel.info:
        return (AppColors.infoBg, AppColors.infoText,
        AppColors.infoBorder, Icons.notifications_outlined);
    }
  }

  String get _levelLabel {
    switch (alert.level) {
      case AlertLevel.urgent:
        return 'Urgent';
      case AlertLevel.warning:
        return 'Modéré';
      case AlertLevel.info:
        return 'Info';
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, borderColor, icon) = _levelStyle;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top: patient info + badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      alert.avatarInitials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            alert.patientName,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          // Level badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 12, color: textColor),
                                const SizedBox(width: 4),
                                Text(_levelLabel,
                                    style: TextStyle(
                                        color: textColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${alert.patientId} · ${alert.condition}',
                        style: const TextStyle(
                            color: AppColors.textLight, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Alert info box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.description,
                    style: const TextStyle(
                        color: AppColors.textMid, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          // Time + actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                const Icon(Icons.schedule_outlined,
                    size: 13, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(alert.time,
                    style: const TextStyle(
                        color: AppColors.textLight, fontSize: 12)),
                const Spacer(),
                ActionBtn(
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.urgentText,
                  bg: AppColors.urgentBg,
                  onTap: onDelete,
                ),
                const SizedBox(width: 8),
                ActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: const Color(0xFF25D366),
                  bg: const Color(0xFFECFDF5),
                  onTap: onWhatsapp,
                ),
                const SizedBox(width: 8),
                ActionBtn(
                  icon: Icons.person_search_outlined,
                  color: AppColors.infoText,
                  bg: AppColors.infoBg,
                  onTap: onDetail,
                ),
                const SizedBox(width: 8),
                ActionBtn(
                  icon: Icons.assignment_outlined,
                  color: AppColors.primary,
                  bg: AppColors.primaryLight,
                  onTap: onPlan,
                  label: "Plan",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
