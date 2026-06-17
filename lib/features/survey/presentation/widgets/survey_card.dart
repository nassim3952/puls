// ── Card pour chaque enquête ──────────────────────────────────────────────────
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/color.dart';
import '../provider/pending_survey_provider.dart';

class SurveyCard extends StatelessWidget {
  final PendingSurveyItem survey;
  final bool isSent;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSend;

  const SurveyCard({
    required this.survey,
    this.isSent = false,
    this.onEdit,
    this.onDelete,
    this.onSend,
  });

  String get _initials {
    final parts = survey.fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return survey.fullName.isNotEmpty
        ? survey.fullName.substring(0, 1).toUpperCase()
        : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: avatar + identity + status badge ──────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar initiales
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nom + IPP + téléphone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        survey.fullName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (survey.ipp != null && survey.ipp!.isNotEmpty) ...[
                            const Icon(
                              Icons.tag_rounded,
                              size: 12,
                              color: AppColors.kTextSub,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              survey.ipp!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (survey.phone != null) ...[
                            const Icon(
                              Icons.phone_iphone_rounded,
                              size: 12,
                              color: AppColors.kTextSub,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              survey.phone!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isSent
                        ? AppColors.primaryBlue
                        : AppColors.primaryWarning)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSent
                              ? AppColors.primaryBlue
                              : AppColors.primaryWarning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isSent ? 'Envoyée' : 'En attente',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isSent
                              ? AppColors.primaryBlue
                              : AppColors.primaryWarning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Métadonnées visite en chips ────────────────────────────────
          if (survey.service != null ||
              survey.visitType != null ||
              survey.doctorAssigned != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (survey.service != null)
                    _MetaChip(
                      icon: Icons.local_hospital_outlined,
                      label: survey.service!,
                    ),
                  if (survey.visitType != null)
                    _MetaChip(
                      icon: Icons.calendar_today_outlined,
                      label: survey.visitType!,
                    ),
                  if (survey.doctorAssigned != null)
                    _MetaChip(
                      icon: Icons.person_outline_rounded,
                      label: survey.doctorAssigned!,
                    ),
                ],
              ),
            ),

          // ── Séparateur ────────────────────────────────────────────────
          if (!isSent) const Divider(height: 1, color: AppColors.border),

          // ── Actions en bas ────────────────────────────────────────────
          if (!isSent)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  // Modifier
                  _ActionButton(
                    icon: Icons.edit_rounded,
                    label: 'Modifier',
                    color: AppColors.primaryBlue,
                    onTap: onEdit!,
                  ),
                  const SizedBox(width: 8),
                  // Supprimer
                  _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Supprimer',
                    color: AppColors.primaryError,
                    onTap: onDelete!,
                  ),
                  const Spacer(),
                  // Envoyer — CTA principal
                  FilledButton.icon(
                    onPressed: () => onSend!(),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Envoyer'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}
// ── Chip métadonnée ───────────────────────────────────────────────────────────
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBG,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.kTextSub),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bouton action texte+icon ──────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}