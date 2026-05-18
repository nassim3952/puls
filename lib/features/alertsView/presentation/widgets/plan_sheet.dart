import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/alert_provider.dart';
import 'package:puls/features/alertsView/presentation/widgets/section_title.dart';
import 'package:puls/features/alertsView/presentation/widgets/sheet_base.dart';

import '../../../../core/color.dart';
import 'alert_view.dart';
import 'green_button.dart';

// Labels des deux options disponibles
const String kPlanContact = 'Contact avec rapport';
const String kPlanDirect = 'Directement un rapport';

class PlanSheet extends ConsumerStatefulWidget {
  final AlertView alert;
  const PlanSheet({required this.alert, super.key});

  @override
  ConsumerState<PlanSheet> createState() => _PlanSheetState();
}

class _PlanSheetState extends ConsumerState<PlanSheet> {
  String? _selectedLabel;
  final _reportController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _selectedLabel != null && _reportController.text.trim().isNotEmpty;

  void _apply() {
    setState(() => _submitted = true);
    if (!_canSubmit) return;

    ref.read(alertsNotifierProvider.notifier).assignPlan(
      widget.alert.source,
      _selectedLabel!,
      _reportController.text.trim(),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SheetBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────
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
                    const Text(
                      "Plan d'action",
                      style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800),
                    ),
                    Text(
                      widget.alert.patientName,
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Contexte info ───────────────────────────────────────────────
          Container(
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
                    'Type de visite : ${widget.alert.source.visitType.toLowerCase()} · Score satisfaction ${widget.alert.source.patientResponse.q0}/5',
                    style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Sélection du type de plan ───────────────────────────────────
          SectionTitle("Type d'action"),
          const SizedBox(height: 12),
          _PlanOption(
            label: kPlanContact,
            icon: Icons.phone_in_talk_outlined,
            description:
            'Contacter le patient puis rédiger un rapport de suivi.',
            selected: _selectedLabel == kPlanContact,
            onTap: () => setState(() => _selectedLabel = kPlanContact),
          ),
          const SizedBox(height: 10),
          _PlanOption(
            label: kPlanDirect,
            icon: Icons.edit_note_rounded,
            description: 'Rédiger directement un rapport sans appel préalable.',
            selected: _selectedLabel == kPlanDirect,
            onTap: () => setState(() => _selectedLabel = kPlanDirect),
          ),
          if (_submitted && _selectedLabel == null) ...[
            const SizedBox(height: 6),
            const Text(
              'Veuillez sélectionner un type d\'action.',
              style: TextStyle(color: AppColors.urgentText, fontSize: 12),
            ),
          ],
          const SizedBox(height: 24),

          // ── Champ rapport ───────────────────────────────────────────────
          SectionTitle('Rapport'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (_submitted && _reportController.text.trim().isEmpty)
                    ? AppColors.urgentBorder
                    : AppColors.border,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _reportController,
              maxLines: 5,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Détaillez les actions menées ou à mener...',
                hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          if (_submitted && _reportController.text.trim().isEmpty) ...[
            const SizedBox(height: 6),
            const Text(
              'Le rapport ne peut pas être vide.',
              style: TextStyle(color: AppColors.urgentText, fontSize: 12),
            ),
          ],
          const SizedBox(height: 24),

          // ── Bouton appliquer ────────────────────────────────────────────
          GreenBtn(
            label: "Appliquer le plan d'action",
            icon: Icons.check_circle_outline_rounded,
            onTap: _apply,
          ),
        ],
      ),
    );
  }
}

// ─── Widget option sélectionnable ────────────────────────────────────────────
class _PlanOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _PlanOption({
    required this.label,
    required this.icon,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 20,
                  color: selected ? Colors.white : AppColors.textMid),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? AppColors.primaryDark
                          : AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                        height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color:
                  selected ? AppColors.primary : AppColors.textLight,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}