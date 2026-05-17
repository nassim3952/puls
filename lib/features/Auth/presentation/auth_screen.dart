import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/routes/root_manager.dart';
import 'package:puls/features/Auth/presentation/widgets/loginButton.dart';
import 'package:puls/features/Auth/presentation/widgets/soft_blob.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      body: Stack(
        children: [
          // Soft decorative blobs
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
          // Main content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    SizedBox(
                      width: 280,
                      child: Image.asset('assets/logo.png', width: 280),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 6),
                    const SizedBox(height: 32),
                    // Card
                    Container(
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
                            color: AppColors.primaryMenthe.withOpacity(0.08),
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
                          LoginField(
                            controller: _usernameController,
                            hint: 'Username',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 16),
                          LoginField(
                            controller: _passwordController,
                            hint: 'Password',
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
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          LoginButton(onTap: () {

                            //logique du login
                            Navigator.pushNamed(context, RouteManager.dashBoard);

                          }),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(

                              onPressed: () {

                                //logique du forgot password

                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: AppColors.primaryMenthe,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
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
        ],
      ),
    );
  }
}
