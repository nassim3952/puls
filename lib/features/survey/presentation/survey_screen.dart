import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/filter_tab.dart';
import 'package:puls/features/survey/presentation/provider/global_refs_provider.dart';
import 'package:puls/features/survey/presentation/provider/pending_survey_provider.dart';
import 'package:puls/features/survey/presentation/provider/survey_provider.dart';
import 'package:puls/features/survey/presentation/widgets/form_fields.dart';
import 'package:puls/features/survey/presentation/widgets/form_modal.dart';
import 'package:puls/features/survey/presentation/widgets/survey_card.dart';

import '../../../core/color.dart';

class SurveyScreen extends ConsumerStatefulWidget {
  const SurveyScreen({super.key});

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  String _currentTab = 'pending'; // 'pending' ou 'sent'

  @override
  Widget build(BuildContext context) {
    final surveysAsync = ref.watch(pendingSurveysProvider(_currentTab));

    return Scaffold(
      backgroundColor: AppColors.primaryBG,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SurveyScreenHeader(
            count: surveysAsync.value?.length,
            currentTab: _currentTab,
            onTabChanged: (tab) => setState(() => _currentTab = tab),
            onAdd: () => _showFormModal(context, ref),
          ),
          Expanded(
            child: surveysAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.primaryError,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur: $e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              data: (surveys) => surveys.isEmpty
                  ? _buildEmptyState()
                  : _buildSurveyList(context, ref, surveys),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSent = _currentTab == 'sent';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSent ? Icons.mark_email_read_outlined : Icons.assignment_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            isSent ? 'Aucune enquête envoyée' : 'Aucune enquête en attente',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSent
                ? 'Les enquêtes envoyées apparaîtront ici.'
                : 'Ajoutez un patient pour démarrer.',
            style: const TextStyle(fontSize: 13, color: AppColors.kTextSub),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyList(
      BuildContext context,
      WidgetRef ref,
      List<PendingSurveyItem> surveys,
      ) {
    final isSent = _currentTab == 'sent';
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: surveys.length,
      itemBuilder: (context, index) {
        final survey = surveys[index];
        return SurveyCard(
          survey: survey,
          isSent: isSent,
          onEdit: isSent ? null : () => _showEditModal(context, ref, survey),
          onDelete: isSent ? null : () => _showDeleteConfirm(context, ref, survey),
          onSend: isSent ? null : () => _showSendOptions(context, ref, survey),
        );
      },
    );
  }

  void _showFormModal(BuildContext context, WidgetRef ref) {
    ref.read(sendSurveyProvider.notifier).reset();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          FormModal(onClose: () => Navigator.pop(context), isEdit: false),
    );
  }

  void _showEditModal(
      BuildContext context,
      WidgetRef ref,
      PendingSurveyItem survey,
      ) {
    ref.read(sendSurveyProvider.notifier).reset();
    ref.read(sendSurveyProvider.notifier).setIpp(survey.ipp ?? '');
    ref.read(sendSurveyProvider.notifier).setLastName(survey.lastName);
    ref.read(sendSurveyProvider.notifier).setFirstName(survey.firstName);
    ref.read(sendSurveyProvider.notifier).setPhone(survey.phone ?? '');
    ref.read(sendSurveyProvider.notifier).setService(survey.service);
    ref.read(sendSurveyProvider.notifier).setVisitType(survey.visitType);
    ref.read(sendSurveyProvider.notifier).setExploration(survey.exploration);
    ref.read(sendSurveyProvider.notifier).setAftercare(survey.aftercare);
    ref
        .read(sendSurveyProvider.notifier)
        .setDoctorAssigned(survey.doctorAssigned);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FormModal(
        onClose: () => Navigator.pop(context),
        isEdit: true,
        visitId: survey.visitId,
      ),
    );
  }

  void _showDeleteConfirm(
      BuildContext context,
      WidgetRef ref,
      PendingSurveyItem survey,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.redFaint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.primaryError,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Supprimer de la file ?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Cette action retirera ${survey.fullName} de la file d\'envoi.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(pendingSurveysNotifierProvider.notifier)
                            .deleteFromQueue(survey.visitId);
                        ref.invalidate(pendingSurveysProvider);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Supprimée de la file d'attente"),
                            ),
                          );
                        }
                      } catch (e) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $e'),
                              backgroundColor: AppColors.primaryError,
                            ),
                          );
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryError,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Supprimer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSendOptions(
      BuildContext context,
      WidgetRef ref,
      PendingSurveyItem survey,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Envoyer l\'enquête',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.redFaint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text: 'L\'enquête sera envoyée par WhatsApp à ',
                  ),
                  TextSpan(
                    text: survey.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (survey.phone != null) ...[
                    const TextSpan(text: ' ('),
                    TextSpan(text: survey.phone),
                    const TextSpan(text: ')'),
                  ],
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _sendSurvey(context, ref, survey);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Envoyer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendSurvey(
      BuildContext context,
      WidgetRef ref,
      PendingSurveyItem survey,
      ) async {
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          backgroundColor: AppColors.surface,
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primaryBlue),
              SizedBox(width: 16),
              Expanded(child: Text('Envoi en cours...')),
            ],
          ),
        ),
      );
    }

    await ref
        .read(sendSurveyProvider.notifier)
        .sendFromQueue(
      visitId: survey.visitId,
      patientId: survey.patientId,
      ipp: survey.ipp ?? '',
      firstName: survey.firstName,
      lastName: survey.lastName,
      phone: survey.phone,
      service: survey.service,
      visitType: survey.visitType,
      exploration: survey.exploration,
      aftercare: survey.aftercare,
      doctorAssigned: survey.doctorAssigned,
      date: survey.date,
    );

    if (context.mounted) Navigator.pop(context);

    final result = ref.read(sendSurveyProvider);

    if (!context.mounted) return;

    if (result.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage!),
          backgroundColor: AppColors.primaryError,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: AppColors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Enquête envoyée')),
            ],
          ),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
    }
  }
}

// ── Header de la section enquêtes ────────────────────────────────────────────
class _SurveyScreenHeader extends StatelessWidget {
  final int? count;
  final String currentTab;
  final ValueChanged<String> onTabChanged;
  final VoidCallback onAdd;

  const _SurveyScreenHeader({
    this.count,
    required this.currentTab,
    required this.onTabChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enquêtes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (count != null)
                    Text(
                      currentTab == 'sent'
                          ? (count == 0 ? 'Aucune envoyée' : '$count envoyée(s)')
                          : (count == 0 ? 'Aucune en attente' : '$count en attente'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => onAdd(),
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: const Text('Ajouter'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Spacer(),
              TabFilter(
                current: currentTab,
                onChanged: onTabChanged,
                tabs: const [
                  ('pending', 'En attente'),
                  ('sent', 'Envoyées'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}