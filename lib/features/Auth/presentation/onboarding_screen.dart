import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/shared_widget/action_button.dart';
import 'package:puls/features/Auth/presentation/widgets/auth_form.dart';
import 'package:puls/features/Auth/presentation/widgets/soft_blob.dart';

import '../provider/onboarding_provider.dart';


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
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _hospitalNameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _citeController = TextEditingController();

  String? _selectedWilaya;
  String? _selectedCommune;

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _whatsappController.dispose();
    _citeController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_hospitalNameController.text.trim().isEmpty)
      return 'Le nom de l\'hôpital est requis.';
    return null;
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.primaryError,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    await ref.read(onboardingProvider.notifier).createHospitalAndOwner(
      hospitalName: _hospitalNameController.text.trim(),
      whatsappPhone: _whatsappController.text.trim(),
      wilaya: _selectedWilaya,
      commune: _selectedCommune,
      cite: _citeController.text.trim(),
    );

    final state = ref.read(onboardingProvider);
    if (state.status == OnboardingStatus.error && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Erreur inconnue'),
          backgroundColor: AppColors.primaryError,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    // GoRouter redirige automatiquement vers /dashboard si success
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final isLoading = state.status == OnboardingStatus.loading;

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
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlueLighter,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.local_hospital_outlined,
                                    color: AppColors.primaryBlue,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Configurer votre hôpital',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Ces informations seront liées à votre compte.',
                                        style: TextStyle(
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

                            // ── Section hôpital ───────────────────────────
                            _SectionLabel('Informations hôpital'),
                            const SizedBox(height: 12),

                            LoginField(
                              controller: _hospitalNameController,
                              hint: 'Nom de l\'hôpital *',
                              icon: Icons.business_outlined,
                            ),
                            const SizedBox(height: 14),
                            LoginField(
                              controller: _whatsappController,
                              hint: 'Numéro WhatsApp (facultatif)',
                              icon: Icons.phone_outlined,
                            ),

                            const SizedBox(height: 24),

                            // ── Section localisation ──────────────────────
                            _SectionLabel('Localisation (facultatif)'),
                            const SizedBox(height: 12),

                            // Dropdown Wilaya
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

                            // Dropdown Commune (synchronisé avec wilaya)
                            _StyledDropdown<String>(
                              hint: 'Commune',
                              icon: Icons.location_on_outlined,
                              value: _selectedCommune,
                              items: _selectedWilaya != null
                                  ? _wilayasCommunes[_selectedWilaya]!
                                  : [],
                              onChanged: _selectedWilaya != null
                                  ? (val) =>
                                  setState(() => _selectedCommune = val)
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            LoginField(
                              controller: _citeController,
                              hint: 'Cité / Adresse (facultatif)',
                              icon: Icons.home_outlined,
                            ),

                            const SizedBox(height: 28),

                            // Bouton
                            isLoading
                                ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryBlue,
                              ),
                            )
                                : AppButton(onTap: _submit, text: "S'inscrire"),
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