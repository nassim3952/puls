import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/text.dart';

import '../../../../core/utils/kpi_info.dart';

class KpiHelpDialog extends StatefulWidget {
  final String kpiTitle;

  const KpiHelpDialog({super.key, required this.kpiTitle});

  @override
  State<KpiHelpDialog> createState() => _KpiHelpDialogState();
}

class _KpiHelpDialogState extends State<KpiHelpDialog> {
  bool _showFull = false;

  @override
  Widget build(BuildContext context) {
    final info = kpiInfoMap[widget.kpiTitle];

    if (info == null) {
      return const AlertDialog(
        title: Text('Aide'),
        content: Text('Aucune information disponible pour ce KPI.'),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    info.title,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    info.fullName,
                    style: AppTextStyles.cardTitle,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Question
            _SectionLabel(label: 'Question posée au patient'),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBG,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                '« ${info.question} »',
                style: AppTextStyles.body.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Équipe
            _SectionLabel(label: 'Équipe ciblée'),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.group_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    info.targetTeam,
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),

            // Verbatims (mode complet seulement)
            if (_showFull && info.verbatims != null) ...[
              const SizedBox(height: 14),
              _SectionLabel(label: 'Verbatims analysés'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: info.verbatims!
                    .map(
                      (v) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      v,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ],

            const SizedBox(height: 20),

            // Toggle court/complet
            if (info.verbatims != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => _showFull = !_showFull),
                  icon: Icon(
                    _showFull ? Icons.unfold_less : Icons.unfold_more,
                    size: 16,
                  ),
                  label: Text(_showFull ? 'Réduire' : 'Voir les verbatims'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    textStyle: AppTextStyles.caption,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}