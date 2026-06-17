// ── Modal du formulaire ───────────────────────────────────────────────────────
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/color.dart';
import '../provider/global_refs_provider.dart';
import '../provider/pending_survey_provider.dart';
import '../provider/survey_provider.dart';
import 'form_fields.dart';

class FormModal extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final bool isEdit;
  final String? visitId;

  const FormModal({required this.onClose, required this.isEdit, this.visitId});

  @override
  ConsumerState<FormModal> createState() => _FormModalState();
}

class _FormModalState extends ConsumerState<FormModal> {
  final _phoneCtrl   = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _formKey     = GlobalKey<FormState>();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(sendSurveyProvider);
      _phoneCtrl.text    = state.phone;
      _lastNameCtrl.text = state.lastName;
      // En mode édition, on pre-charge le patient résolu
      if (widget.isEdit && state.resolvedPatientId == null && state.phone.isNotEmpty) {
        ref.read(sendSurveyProvider.notifier).searchPatientByPhone();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _phoneCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String v) {
    ref.read(sendSurveyProvider.notifier).setPhone(v);
    ref.read(sendSurveyProvider.notifier).clearResolvedPatient();
    _lastNameCtrl.clear();
    _debounce?.cancel();
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 9) {
      _debounce = Timer(const Duration(milliseconds: 600), () {
        ref.read(sendSurveyProvider.notifier).searchPatientByPhone();
      });
    }
  }

  void _openEditPatientModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _PatientInfoModal(parentRef: ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState  = ref.watch(sendSurveyProvider);
    final refsAsync  = ref.watch(globalRefsProvider);

    ref.listen<SendSurveyFormState>(sendSurveyProvider, (prev, next) {
      if (next.success && !(prev?.success ?? false)) {
        Navigator.pop(context);
        ref.read(sendSurveyProvider.notifier).reset();
        ref.invalidate(pendingSurveysProvider);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.isEdit ? 'Enquête mise à jour' : 'Enquête ajoutée à la file'),
          backgroundColor: AppColors.primaryBlue,
        ));
      }
    });

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 600,
        child: refsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
          ),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (refs) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Header ───────────────────────────────────────────────
                    Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            widget.isEdit ? Icons.edit_rounded : Icons.person_add_alt_1_rounded,
                            color: AppColors.primaryBlue, size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isEdit ? 'Modifier l\'enquête' : 'Ajouter un patient',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              Text(
                                widget.isEdit ? 'Mettez à jour les informations de la visite' : 'Entrez le numéro WhatsApp du patient',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.kTextSub),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 20),

                    // ── Zone 1 : WhatsApp + résolution patient ───────────────
                    SectionLabel(label: 'Patient *'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryBG,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Champ WhatsApp
                          CustomTextField(
                            controller: _phoneCtrl,
                            label: 'Numéro WhatsApp *',
                            hint: '0612345678',
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\+]'))],
                            onChanged: _onPhoneChanged,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Obligatoire';
                              final digits = v.replaceAll(RegExp(r'\D'), '');
                              if (digits.length < 9) return 'Numéro invalide';
                              return null;
                            },
                          ),

                          // ── Indicateur de recherche ──────────────────────
                          if (formState.isSearching) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: const [
                                SizedBox(width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                                ),
                                SizedBox(width: 10),
                                Text('Recherche en cours...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],

                          // ── Patient trouvé : chip vert ───────────────────
                          if (!formState.isSearching && formState.hasPatient) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.25)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _initials(formState.resolvedPatientName ?? ''),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formState.resolvedPatientName ?? '',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        ),
                                        const Text('Patient trouvé', style: TextStyle(fontSize: 11, color: AppColors.primaryBlue)),
                                      ],
                                    ),
                                  ),
                                  // Bouton modifier infos perso
                                  TextButton.icon(
                                    onPressed: () => _openEditPatientModal(context),
                                    icon: const Icon(Icons.edit_outlined, size: 14),
                                    label: const Text('Modifier', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // ── Patient inconnu : champ Nom + bouton créer ───
                          if (!formState.isSearching && !formState.hasPatient &&
                              _phoneCtrl.text.replaceAll(RegExp(r'\D'), '').length >= 9) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryWarning.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.primaryWarning.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.person_off_outlined, size: 14, color: AppColors.primaryWarning),
                                      SizedBox(width: 6),
                                      Text('Patient inconnu — créez-le', style: TextStyle(fontSize: 12, color: AppColors.primaryWarning, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextField(
                                    controller: _lastNameCtrl,
                                    label: 'Nom *',
                                    hint: 'ex. KHELIFI',
                                    textCapitalization: TextCapitalization.words,
                                    onChanged: ref.read(sendSurveyProvider.notifier).setLastName,
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: formState.isLoading || _lastNameCtrl.text.trim().isEmpty
                                          ? null
                                          : () async {
                                        if (_formKey.currentState!.validate()) {
                                          await ref.read(sendSurveyProvider.notifier).createPatient();
                                        }
                                      },
                                      icon: const Icon(Icons.person_add_outlined, size: 16),
                                      label: Text(formState.isLoading ? '...' : 'Créer le patient'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Zone 2 : Visite (visible uniquement si patient résolu) ──
                    if (formState.hasPatient) ...[
                      SectionLabel(label: 'Visite'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryBG,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownField<String>(
                                    label: 'Service *',
                                    value: formState.service,
                                    items: refs.services.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                    onChanged: ref.read(sendSurveyProvider.notifier).setService,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownField<String>(
                                    label: 'Type de visite *',
                                    value: formState.visitType,
                                    items: refs.visitTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                    onChanged: ref.read(sendSurveyProvider.notifier).setVisitType,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownField<String>(
                                    label: 'Exploration *',
                                    value: formState.exploration,
                                    items: refs.explorations.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                    onChanged: ref.read(sendSurveyProvider.notifier).setExploration,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownField<String>(
                                    label: 'Suite du séjour *',
                                    value: formState.aftercare,
                                    items: refs.aftercares.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                                    onChanged: ref.read(sendSurveyProvider.notifier).setAftercare,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _DoctorField(parentRef: ref),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DateField(
                                    label: 'Date de visite *',
                                    value: formState.visitDate,
                                    initialDate: DateTime.now(),
                                    onChanged: ref.read(sendSurveyProvider.notifier).setVisitDate,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Erreur ─────────────────────────────────────────────
                      if (formState.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.redFaint,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.urgentBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppColors.primaryError, size: 18),
                              const SizedBox(width: 10),
                              Expanded(child: Text(formState.errorMessage!, style: const TextStyle(color: AppColors.primaryError, fontSize: 12))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Boutons (visibles seulement si visite valide) ──────
                      if (formState.isVisitValid)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: widget.onClose, child: const Text('Annuler')),
                            const Spacer(),
                            if (!widget.isEdit)
                              SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: formState.isLoading ? null : () async {
                                    await ref.read(sendSurveyProvider.notifier).submitToQueue();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryWarning,
                                    side: const BorderSide(color: AppColors.primaryWarning),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(formState.isLoading ? '...' : "Ajouter à la file d'attente"),
                                ),
                              ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 48,
                              child: FilledButton.icon(
                                onPressed: formState.isLoading ? null : () async {
                                  if (widget.isEdit && widget.visitId != null) {
                                    try {
                                      await ref.read(pendingSurveysNotifierProvider.notifier).updatePendingSurvey(
                                        visitId:       widget.visitId!,
                                        service:       ref.read(sendSurveyProvider).service,
                                        visitType:     ref.read(sendSurveyProvider).visitType,
                                        exploration:   ref.read(sendSurveyProvider).exploration,
                                        aftercare:     ref.read(sendSurveyProvider).aftercare,
                                        doctorAssigned:ref.read(sendSurveyProvider).doctorAssigned,
                                      );
                                      ref.invalidate(pendingSurveysProvider);
                                      if (mounted) {
                                        Navigator.pop(context);
                                        ref.read(sendSurveyProvider.notifier).reset();
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text('Enquête mise à jour'),
                                          backgroundColor: AppColors.primaryBlue,
                                        ));
                                      }
                                    } catch (e) {
                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.primaryError),
                                      );
                                    }
                                  } else {
                                    await ref.read(sendSurveyProvider.notifier).submitAndSend();
                                  }
                                },
                                icon: const Icon(Icons.send_rounded, size: 18),
                                label: Text(formState.isLoading ? '...' : (widget.isEdit ? 'Mettre à jour' : 'Envoyer')),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                      // Hint discret quand la visite n'est pas encore complète
                        TextButton(onPressed: widget.onClose, child: const Text('Annuler')),
                    ],

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// ── Champ Médecin (controller local) ─────────────────────────────────────────
class _DoctorField extends ConsumerStatefulWidget {
  final WidgetRef parentRef;
  const _DoctorField({required this.parentRef});

  @override
  ConsumerState<_DoctorField> createState() => _DoctorFieldState();
}

class _DoctorFieldState extends ConsumerState<_DoctorField> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl.text = ref.read(sendSurveyProvider).doctorAssigned ?? '';
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => CustomTextField(
    controller: _ctrl,
    label: 'Médecin assigné',
    hint: 'Optionnel',
    onChanged: (v) => ref.read(sendSurveyProvider.notifier).setDoctorAssigned(v.isEmpty ? null : v),
  );
}

// ── Modal infos personnelles (par-dessus le modal principal) ─────────────────
class _PatientInfoModal extends ConsumerStatefulWidget {
  final WidgetRef parentRef;
  const _PatientInfoModal({required this.parentRef});

  @override
  ConsumerState<_PatientInfoModal> createState() => _PatientInfoModalState();
}

class _PatientInfoModalState extends ConsumerState<_PatientInfoModal> {
  final _lastNameCtrl  = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _ippCtrl       = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _formKey       = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final s = ref.read(sendSurveyProvider);
    _lastNameCtrl.text  = s.lastName;
    _firstNameCtrl.text = s.firstName ?? '';
    _ippCtrl.text       = s.ipp;
    _emailCtrl.text     = s.email ?? '';
  }

  @override
  void dispose() {
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _ippCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(sendSurveyProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Informations personnelles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.kTextSub),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),

                  // Nom + Prénom
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _lastNameCtrl,
                          label: 'Nom *',
                          hint: 'ex. KHELIFI',
                          textCapitalization: TextCapitalization.words,
                          onChanged: ref.read(sendSurveyProvider.notifier).setLastName,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _firstNameCtrl,
                          label: 'Prénom',
                          hint: 'ex. Nassim',
                          textCapitalization: TextCapitalization.words,
                          onChanged: (v) => ref.read(sendSurveyProvider.notifier).setFirstName(v.isEmpty ? null : v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Sexe + Date de naissance
                  Row(
                    children: [
                      Expanded(
                        child: DropdownField<String>(
                          label: 'Sexe',
                          value: formState.sex,
                          items: const [
                            DropdownMenuItem(value: 'M', child: Text('Masculin')),
                            DropdownMenuItem(value: 'F', child: Text('Féminin')),
                          ],
                          onChanged: ref.read(sendSurveyProvider.notifier).setSex,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DateField(
                          label: 'Date de naissance',
                          value: formState.dateOfBirth,
                          onChanged: ref.read(sendSurveyProvider.notifier).setDateOfBirth,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // IPP
                  CustomTextField(
                    controller: _ippCtrl,
                    label: 'IPP',
                    hint: 'ex. 7JHYBS4R81NWX85Q',
                    textCapitalization: TextCapitalization.characters,
                    onChanged: ref.read(sendSurveyProvider.notifier).setIpp,
                  ),
                  const SizedBox(height: 14),

                  // Email
                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'ex. patient@email.com',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => ref.read(sendSurveyProvider.notifier).setEmail(v.isEmpty ? null : v),
                  ),
                  const SizedBox(height: 20),

                  // Erreur
                  if (formState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.redFaint,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.urgentBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.primaryError, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(formState.errorMessage!, style: const TextStyle(color: AppColors.primaryError, fontSize: 12))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Boutons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: formState.isLoading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            await ref.read(sendSurveyProvider.notifier).updatePatientInfo();
                            if (mounted && ref.read(sendSurveyProvider).errorMessage == null) {
                              Navigator.pop(context);
                            }
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(formState.isLoading ? '...' : 'Enregistrer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}