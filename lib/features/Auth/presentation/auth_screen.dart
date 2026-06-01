import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/auth_provider.dart';
import 'package:puls/features/Auth/presentation/widgets/auth_form.dart';

import 'package:puls/features/Auth/presentation/widgets/soft_blob.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/shared_widget/action_button.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  // ── Contrôleurs ────────────────────────────────────────────────────────────
  final _nameController        = TextEditingController();
  final _fonctionController    = TextEditingController();
  final _emailController       = TextEditingController();
  final _passwordController    = TextEditingController();
  final _confirmController     = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLogin         = true;

  late AnimationController _animController;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    // Écoute les changements d'état auth SANS ref.read après await
    // — évite le crash "widget unmounted"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(authProvider, (previous, next) {
        if (!mounted) return;
        if (next.status == AuthStatus.error && next.errorMessage != null) {
          _showSnack(next.errorMessage!, isError: true);
        }
        // Mot de passe incorrect : effacer uniquement le champ password
        if (next.status == AuthStatus.wrongPassword &&
            next.errorMessage != null) {
          _passwordController.clear();
          _showSnack(next.errorMessage!, isError: true);
        }
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _fonctionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────
  String? _validate() {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty)           return 'L\'email est requis.';
    if (!email.contains('@'))    return 'Adresse email invalide.';
    if (password.isEmpty)        return 'Le mot de passe est requis.';
    if (password.length < 6)     return 'Minimum 6 caractères.';

    if (!_isLogin) {
      if (_nameController.text.trim().isEmpty)
        return 'Le nom complet est requis.';
      if (_fonctionController.text.trim().isEmpty)
        return 'La fonction est requise.';
      if (_confirmController.text != password)
        return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }

  // ── Submit login / inscription ─────────────────────────────────────────────
  Future<void> _submit() async {
    final error = _validate();
    if (error != null) { _showSnack(error, isError: true); return; }

    if (_isLogin) {
      await ref.read(authProvider.notifier).signIn(
        email:    _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Le feedback erreur est géré par listenManual ci-dessus
      // GoRouter redirige automatiquement si succès
    } else {
      await ref.read(authProvider.notifier).signUp(
        email:    _emailController.text.trim(),
        password: _passwordController.text,
        name:     _nameController.text.trim(),
        fonction: _fonctionController.text.trim(),
      );
      // Si pas d'erreur = email de confirmation envoyé
      if (!mounted) return;
      final state = ref.read(authProvider);
      if (state.status != AuthStatus.error) {
        _showSnack(
          'Un email de confirmation a été envoyé. Vérifiez votre boîte mail.',
          isError: false,
        );
        _toggleMode(); // retour sur login
      }
    }
  }

  // ── Mot de passe oublié ────────────────────────────────────────────────────
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Entrez votre email d\'abord.', isError: true);
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      _showSnack(
        'Email de réinitialisation envoyé. Vérifiez votre boîte mail.',
        isError: false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    }
  }

  // ── Helpers UI ─────────────────────────────────────────────────────────────
  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.primaryError
            : AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _nameController.clear();
      _fonctionController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmController.clear();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Blobs décoratifs
          Positioned(top: -100, right: -80,
              child: SoftBlob(color: AppColors.primaryBlue.withOpacity(0.12), size: 340)),
          Positioned(bottom: -120, left: -100,
              child: SoftBlob(color: AppColors.primaryBlueLighter.withOpacity(0.12), size: 360)),
          Positioned(top: 160, left: -60,
              child: SoftBlob(color: AppColors.primaryBlue.withOpacity(0.07), size: 200)),

          // Contenu
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 280,
                        child: Image.asset('assets/logo.png', width: 280),
                      ),
                      const SizedBox(height: 32),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.primaryBlueLighter, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.08),
                                blurRadius: 40, spreadRadius: 4,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20, offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Titre
                              Text(
                                _isLogin ? 'Connexion' : 'Créer un compte',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),

                              // Nom + Fonction (inscription uniquement)
                              if (!_isLogin) ...[
                                LoginField(
                                  controller: _nameController,
                                  hint: 'Nom complet',
                                  icon: Icons.badge_outlined,
                                ),
                                const SizedBox(height: 14),
                                LoginField(
                                  controller: _fonctionController,
                                  hint: 'Votre fonction  (ex: Directeur médical)',
                                  icon: Icons.work_outline_rounded,
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Email
                              LoginField(
                                controller: _emailController,
                                hint: 'Adresse email',
                                icon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 14),

                              // Mot de passe
                              LoginField(
                                controller: _passwordController,
                                hint: 'Mot de passe',
                                icon: Icons.key_outlined,
                                obscure: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.kTextSub, size: 20,
                                  ),
                                  onPressed: () => setState(
                                          () => _obscurePassword = !_obscurePassword),
                                ),
                              ),

                              // Confirmation (inscription uniquement)
                              if (!_isLogin) ...[
                                const SizedBox(height: 14),
                                LoginField(
                                  controller: _confirmController,
                                  hint: 'Confirmer le mot de passe',
                                  icon: Icons.lock_outline_rounded,
                                  obscure: _obscureConfirm,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.kTextSub, size: 20,
                                    ),
                                    onPressed: () => setState(
                                            () => _obscureConfirm = !_obscureConfirm),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 28),

                              // Bouton principal
                              isLoading
                                  ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryBlue,
                                ),
                              )
                                  : AppButton(onTap: _submit, text: 'Se connecter',),

                              const SizedBox(height: 8),

                              // Mot de passe oublié (login uniquement)
                              if (_isLogin)
                                Center(
                                  child: TextButton(
                                    onPressed: _forgotPassword,
                                    child: const Text(
                                      'Mot de passe oublié ?',
                                      style: TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                              // Toggle login ↔ inscription
                              Center(
                                child: TextButton(
                                  onPressed: _toggleMode,
                                  child: Text(
                                    _isLogin
                                        ? 'Pas encore de compte ? Créer un compte'
                                        : 'Déjà un compte ? Se connecter',
                                    style: const TextStyle(
                                      color: AppColors.kTextSub,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
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