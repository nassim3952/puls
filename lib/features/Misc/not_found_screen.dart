import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:puls/core/color.dart';
import 'package:puls/features/Auth/presentation/widgets/soft_blob.dart';

class NotFoundScreen extends StatefulWidget {
  const NotFoundScreen({super.key});

  @override
  State<NotFoundScreen> createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<NotFoundScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ── Blobs décoratifs (même style qu'AuthScreen) ──────────────────
          Positioned(
            top: -100,
            right: -80,
            child: SoftBlob(
              color: AppColors.primaryBlue.withOpacity(0.12),
              size: 340,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: SoftBlob(
              color: AppColors.primaryBlueLighter.withOpacity(0.12),
              size: 360,
            ),
          ),
          Positioned(
            top: 160,
            left: -60,
            child: SoftBlob(
              color: AppColors.primaryBlue.withOpacity(0.07),
              size: 200,
            ),
          ),

          // ── Contenu centré ───────────────────────────────────────────────
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Icône illustrée ──────────────────────────────
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlueLighter,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryBlueLight,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.explore_off_rounded,
                            size: 44,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── "404" ────────────────────────────────────────
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                          child: const Text(
                            '404',
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              color: Colors.white, // masqué par ShaderMask
                              height: 1,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Titre ────────────────────────────────────────
                        const Text(
                          'Page introuvable',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // ── Sous-titre ───────────────────────────────────
                        const Text(
                          'L\'adresse que vous avez demandée\nn\'existe pas ou a été déplacée.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.55,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // ── Bouton retour accueil ────────────────────────
                        _HomeButton(),

                        const SizedBox(height: 40),

                        // ── Footer ───────────────────────────────────────
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
          ),
        ],
      ),
    );
  }
}

// ── Bouton "Retour à l'accueil" avec gradient ─────────────────────────────────
class _HomeButton extends StatefulWidget {
  @override
  State<_HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<_HomeButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: GestureDetector(
          onTap: () => context.go('/dashboard'),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.30),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Retour à l\'accueil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}