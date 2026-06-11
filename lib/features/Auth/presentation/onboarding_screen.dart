import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/shared_widget/action_button.dart';
import 'package:puls/features/Auth/presentation/widgets/auth_form.dart';
import 'package:puls/features/Auth/presentation/widgets/soft_blob.dart';

import '../provider/onboarding_provider.dart';
import '../../../../core/provider/auth_provider.dart';


// ── Données Algérie (1 wilaya + communes pour l'instant) ─────────────────────
const Map<String, List<String>> _wilayasCommunes = {
  'Alger': [
    'Alger-Centre',
    'Sidi M\'Hamed',
    'El Madania',
    'Belouizdad',
    'Bab El Oued',
    'Bologhine',
    'Casbah',
    'Oued Koriche',
    'Bir Mourad Raïs',
    'El Biar',
    'Bouzareah',
    'Birkhadem',
    'El Harrach',
    'Baraki',
    'Oued Smar',
    'Bachdjerrah',
    'Hussein Dey',
    'Kouba',
    'Souidania',
    'Cheraga',
    'Ouled Fayet',
    'El Achour',
    'Draria',
    'Baba Hassen',
    'Khraicia',
    'Saoula',
    'Birtouta',
    'Tessala El Merdja',
    'Douera',
    'Bougara',
    'Staoueli',
    'Zeralda',
    'Mahelma',
    'Rahmania',
    'Sourp',
    'Ain Benian',
    'Reghaia',
    'Ain Taya',
    'Bordj El Bahri',
    'Marsa',
    'Rouiba',
    'Reghaïa',
  ],
};

class OnboardingScreen extends ConsumerStatefulWidget {
  final bool isInvite;
  const OnboardingScreen({super.key, this.isInvite = false});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  // ── Owner fields ──
  final _hospitalNameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _citeController = TextEditingController();
  String? _selectedWilaya;
  String? _selectedCommune;

  // ── Invite fields ──
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _whatsappController.dispose();
    _citeController.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.isInvite) {
      await _submitInvite();
    } else {
      await _submitOwner();
    }
  }

  // ── Soumission owner ──────────────────────────────────────────────────────
  String? _validate() {
    if (_hospitalNameController.text.trim().isEmpty)
      return "Le nom de l'hôpital est requis.";
    return null;
  }

  Future<void> _submitOwner() async {
    final error = _validate();
    if (error != null) { _showError(error); return; }

    await ref.read(onboardingProvider.notifier).createHospitalAndOwner(
      hospitalName: _hospitalNameController.text.trim(),
      whatsappPhone: _whatsappController.text.trim(),
      wilaya: _selectedWilaya,
      commune: _selectedCommune,
      cite: _citeController.text.trim(),
    );

    final st = ref.read(onboardingProvider);
    if (st.status == OnboardingStatus.error && mounted) {
      _showError(st.errorMessage ?? 'Erreur inconnue');
    }
    // GoRouter redirige automatiquement vers /dashboard si success
  }

  // ── Soumission invité : définir le mot de passe ───────────────────────────
  Future<void> _submitInvite() async {
    final pwd     = _passwordCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (pwd.length < 6) {
      _showError('Le mot de passe doit contenir au moins 6 caractères.');
      return;
    }
    if (pwd != confirm) {
      _showError('Les mots de passe ne correspondent pas.');
      return;
    }

    await ref.read(authProvider.notifier).updatePassword(pwd);

    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.error && mounted) {
      _showError(authState.errorMessage ?? 'Erreur inconnue');
    }
    // GoRouter redirige automatiquement vers /dashboard si authenticated + profil ok
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.primaryError,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final onbState  = ref.watch(onboardingProvider);
    final authState = ref.watch(authProvider);
    final isLoading = onbState.status == OnboardingStatus.loading ||
        authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: SoftBlob(
              color: AppColors.primaryBlue.withOpacity(0.10),
              size: 320,
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: SoftBlob(
              color: AppColors.primaryBlueLighter.withOpacity(0.10),
              size: 300,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 240,
                        child: Image.asset('assets/logo.png', width: 240),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: AppColors.primaryBlueLighter, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color:
                              AppColors.primaryBlue.withOpacity(0.08),
                              blurRadius: 40,
                              spreadRadius: 4,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Header dynamique ────────────────────────────────────────────
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlueLighter,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    widget.isInvite
                                        ? Icons.lock_outline_rounded
                                        : Icons.local_hospital_outlined,
                                    color: AppColors.primaryBlue,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.isInvite
                                            ? 'Définir votre mot de passe'
                                            : 'Configurer votre hôpital',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.isInvite
                                            ? 'Choisissez un mot de passe pour accéder à votre compte.'
                                            : 'Ces informations seront liées à votre compte.',
                                        style: const TextStyle(
                                          color: AppColors.kTextSub,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // ── Contenu selon le type ─────────────────────
                            if (widget.isInvite) ...[
                              _PasswordField(
                                controller: _passwordCtrl,
                                hint: 'Nouveau mot de passe *',
                                obscure: _obscure1,
                                onToggle: () => setState(() => _obscure1 = !_obscure1),
                              ),
                              const SizedBox(height: 14),
                              _PasswordField(
                                controller: _confirmCtrl,
                                hint: 'Confirmer le mot de passe *',
                                obscure: _obscure2,
                                onToggle: () => setState(() => _obscure2 = !_obscure2),
                              ),
                            ] else ...[
                              _SectionLabel('Informations hôpital'),
                              const SizedBox(height: 12),
                              LoginField(
                                controller: _hospitalNameController,
                                hint: "Nom de l'hôpital *",
                                icon: Icons.business_outlined,
                              ),
                              const SizedBox(height: 14),
                              LoginField(
                                controller: _whatsappController,
                                hint: 'Numéro WhatsApp (facultatif)',
                                icon: Icons.phone_outlined,
                              ),
                              const SizedBox(height: 24),
                              _SectionLabel('Localisation (facultatif)'),
                              const SizedBox(height: 12),
                              _StyledDropdown<String>(
                                hint: 'Wilaya',
                                icon: Icons.location_city_outlined,
                                value: _selectedWilaya,
                                items: _wilayasCommunes.keys.toList(),
                                onChanged: (val) => setState(() {
                                  _selectedWilaya = val;
                                  _selectedCommune = null;
                                }),
                              ),
                              const SizedBox(height: 14),
                              _StyledDropdown<String>(
                                hint: 'Commune',
                                icon: Icons.location_on_outlined,
                                value: _selectedCommune,
                                items: _selectedWilaya != null
                                    ? _wilayasCommunes[_selectedWilaya]!
                                    : [],
                                onChanged: _selectedWilaya != null
                                    ? (val) => setState(() => _selectedCommune = val)
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              LoginField(
                                controller: _citeController,
                                hint: 'Cité / Adresse (facultatif)',
                                icon: Icons.home_outlined,
                              ),
                            ],

                            const SizedBox(height: 28),

                            // ── Bouton ────────────────────────────────────
                            isLoading
                                ? const Center(child: CircularProgressIndicator(
                                color: AppColors.primaryBlue))
                                : AppButton(
                              onTap: _submit,
                              text: widget.isInvite
                                  ? 'Accéder à mon compte'
                                  : "S'inscrire",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Satisfactive © 2026 · All Rights Reserved',
                        style: TextStyle(
                          color: AppColors.kTextSub,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets helpers ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final String hint;
  final IconData icon;
  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;

  const _StyledDropdown({
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });



  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlueLighter, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.textPrimary, width: 1.8),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem<T>(
        value: e,
        child: Text(e.toString(),
            style:
            const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
      ))
          .toList(),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary, size: 20),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

// ── Widget champ mot de passe avec toggle visibilité ─────────────────────────
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlueLighter, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.textPrimary, width: 1.8),
        ),
      ),
    );
  }
}