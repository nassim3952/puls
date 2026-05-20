import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/auth_provider.dart';
import 'package:puls/features/Auth/presentation/widgets/loginButton.dart';
import 'package:puls/features/Auth/presentation/widgets/soft_blob.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  // ── Contrôleurs ──────────────────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _fonctionController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLogin = true;

  // Indique qu'on vient d'envoyer un email de reset (affiche le message de confirmation)
  bool _resetEmailSent = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _fonctionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  String? _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) return 'L\'email est requis.';
    if (!email.contains('@')) return 'Email invalide.';
    if (password.isEmpty) return 'Le mot de passe est requis.';
    if (password.length < 6) return 'Minimum 6 caractères.';

    if (!_isLogin) {
      if (_nameController.text.trim().isEmpty) return 'Le nom est requis.';
      if (_fonctionController.text.trim().isEmpty)
        return 'La fonction est requise.';
      if (_confirmPasswordController.text != password)
        return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      _showError(error);
      return;
    }

    if (_isLogin) {
      await ref.read(authProvider.notifier).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await ref.read(authProvider.notifier).signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        fonction: _fonctionController.text.trim(),
      );
    }

    // ⚠️ FIX DU TIMING : on lit l'état APRÈS le await, il est à jour
    if (!mounted) return;
    final authState = ref.read(authProvider);

    if (authState.status == AuthStatus.error &&
        authState.errorMessage != null) {
      _showError(authState.errorMessage!);
    }
    // needsEmailConfirmation est géré via ref.listen dans build()
  }

  // ── Mot de passe oublié ───────────────────────────────────────────────────
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError(
          'Entrez votre adresse email ci-dessus, puis appuyez sur "Mot de passe oublié".');
      return;
    }

    await ref.read(authProvider.notifier).resetPassword(email: email);

    if (!mounted) return;
    final authState = ref.read(authProvider);

    if (authState.status == AuthStatus.error &&
        authState.errorMessage != null) {
      _showError(authState.errorMessage!);
    } else {
      setState(() => _resetEmailSent = true);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryMentheError,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _resetEmailSent = false;
      _nameController.clear();
      _fonctionController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ── Écoute les changements d'état pour réagir sans rebuild de router ──
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!mounted) return;

      // Confirmation email envoyée → affiche le dialog
      if (next.status == AuthStatus.needsEmailConfirmation) {
        _showEmailConfirmationDialog();
      }
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.kBg,
      body: Stack(
        children: [
          // ── Blobs décoratifs ──────────────────────────────────────────────
          Positioned(
            top: -100,
            right: -80,
            child: SoftBlob(
              color: AppColors.primaryMenthe.withOpacity(0.12),
              size: 340,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: SoftBlob(
              color: AppColors.kBgAccent.withOpacity(0.12),
              size: 360,
            ),
          ),
          Positioned(
            top: 160,
            left: -60,
            child: SoftBlob(
              color: AppColors.primaryMenthe.withOpacity(0.07),
              size: 200,
            ),
          ),

          // ── Contenu principal ─────────────────────────────────────────────
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 280,
                        child: Image.asset('assets/logo.png', width: 280),
                      ),
                      const SizedBox(height: 32),

                      // ── Card ──────────────────────────────────────────────
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppColors.kCard,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.kBorder,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryMenthe
                                    .withOpacity(0.08),
                                blurRadius: 40,
                                spreadRadius: 4,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isLogin ? 'Connexion' : 'Créer un compte',
                                style: const TextStyle(
                                  color: AppColors.kText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),

                              // Nom (inscription uniquement)
                              if (!_isLogin) ...[
                                LoginField(
                                  controller: _nameController,
                                  hint: 'Nom complet',
                                  icon: Icons.badge_outlined,
                                ),
                                const SizedBox(height: 14),
                                LoginField(
                                  controller: _fonctionController,
                                  hint: 'Votre fonction (ex: Directeur médical)',
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

                              // Mot de passe (caché si on vient d'envoyer un reset)
                              if (!_resetEmailSent) ...[
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
                                      color: AppColors.kTextSub,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                                  ),
                                ),

                                // Confirmation mot de passe (inscription uniquement)
                                if (!_isLogin) ...[
                                  const SizedBox(height: 14),
                                  LoginField(
                                    controller: _confirmPasswordController,
                                    hint: 'Confirmer le mot de passe',
                                    icon: Icons.lock_outline_rounded,
                                    obscure: _obscureConfirm,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.kTextSub,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() =>
                                      _obscureConfirm = !_obscureConfirm),
                                    ),
                                  ),
                                ],
                              ],

                              // ── Message reset envoyé ──────────────────────
                              if (_resetEmailSent) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.primaryMenthe
                                            .withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.mark_email_read_outlined,
                                          color: AppColors.primaryMenthe,
                                          size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Un email de réinitialisation a été envoyé à ${_emailController.text.trim()}. Vérifiez votre boîte mail.',
                                          style: const TextStyle(
                                            color: AppColors.kText,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 28),

                              // Bouton principal
                              isLoading
                                  ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryMenthe,
                                ),
                              )
                                  : _resetEmailSent
                                  ? TextButton(
                                onPressed: () => setState(() {
                                  _resetEmailSent = false;
                                  _passwordController.clear();
                                }),
                                child: const Text(
                                  'Retour à la connexion',
                                  style: TextStyle(
                                      color: AppColors.primaryMenthe,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                                  : LoginButton(onTap: _submit),

                              const SizedBox(height: 16),

                              // Forgot password (login uniquement, email non vide)
                              if (_isLogin && !_resetEmailSent)
                                Center(
                                  child: TextButton(
                                    onPressed: _forgotPassword,
                                    child: const Text(
                                      'Mot de passe oublié ?',
                                      style: TextStyle(
                                        color: AppColors.primaryMenthe,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                              // Toggle login ↔ inscription
                              if (!_resetEmailSent)
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

  // ── Dialog confirmation email ─────────────────────────────────────────────
  void _showEmailConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.kCard,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.mark_email_unread_outlined,
                  color: AppColors.primaryMenthe, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Confirmez votre email',
              style: TextStyle(
                color: AppColors.kText,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: Text(
          'Un email de confirmation a été envoyé à\n${_emailController.text.trim()}\n\nCliquez sur le lien dans l\'email pour activer votre compte, puis connectez-vous.',
          style: const TextStyle(
            color: AppColors.kTextSub,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Repasse en mode login pour que l'utilisateur se connecte après confirmation
              setState(() {
                _isLogin = true;
                _passwordController.clear();
                _confirmPasswordController.clear();
                _nameController.clear();
                _fonctionController.clear();
              });
            },
            child: const Text(
              'Compris',
              style: TextStyle(
                color: AppColors.primaryMenthe,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}