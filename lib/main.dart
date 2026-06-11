import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'core/provider/realtime_provider.dart';
import 'core/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await Supabase.initialize(
    url: 'https://yyohrbyjwemiqfpplmtj.supabase.co',
    anonKey: 'sb_publishable_3Kj_37TEdRIf0yIQoOoniA_6fGv_oXA',
  );

  // ── Intercepte les tokens/erreurs Supabase dans l'URL (Flutter Web) ──
  if (kIsWeb) {
    final fullUrl = html.window.location.href;
    // Supabase génère parfois une URL avec deux "#" :
    // http://localhost:3000/#/onboarding#access_token=...
    // On prend tout ce qui est après le DERNIER "#"
    final lastHash = fullUrl.lastIndexOf('#');
    final rawFragment = lastHash >= 0 ? fullUrl.substring(lastHash + 1) : '';
    final params = Uri.parse('?$rawFragment').queryParameters;

    final errorCode   = params['error_code'];
    final accessToken = params['access_token'];
    final refreshToken = params['refresh_token'];
    final type        = params['type']; // 'invite', 'recovery', etc.

    if (errorCode != null) {
      // Erreur OTP existante
      pendingOtpError = errorCode;
      html.window.history.replaceState(null, '', '/#/auth');

    } else if (accessToken != null && type == 'invite') {
      // ── Lien d'invitation : établir la session manuellement ──
      try {
        await Supabase.instance.client.auth.setSession(
          refreshToken ?? '',
          accessToken: accessToken,
        );
        pendingInvite = true;
      } catch (e) {
        print('setSession error: $e');
      }
      html.window.history.replaceState(null, '', '/#/onboarding');
    }
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(realtimeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Satisfactive',
    );
  }
}