import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';
import 'package:puls/features/Auth/presentation/widgets/soft_blob.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned(
            top: -100, right: -80,
            child: SoftBlob(color: AppColors.primaryBlue.withOpacity(0.10), size: 320),
          ),
          Positioned(
            bottom: -100, left: -80,
            child: SoftBlob(color: AppColors.primaryBlueLighter.withOpacity(0.10), size: 300),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlueLighter,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_unread_outlined,
                        color: AppColors.primaryBlue,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Vérifiez votre boîte mail',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Un lien de confirmation vous a été envoyé.\nCliquez dessus pour activer votre compte.',
                      style: TextStyle(
                        color: AppColors.kTextSub,
                        fontSize: 14,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pensez à vérifier vos spams.',
                      style: TextStyle(
                        color: AppColors.kTextSub,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}