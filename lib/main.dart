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

  // ── Intercepte les erreurs Supabase dans l'URL (Flutter Web) ──
  if (kIsWeb) {
    final uri = Uri.parse(html.window.location.href);
    final fragmentUri = Uri.parse(uri.fragment);
    final errorCode = fragmentUri.queryParameters['error_code'];

    if (errorCode != null) {
      pendingOtpError = errorCode; // ← stocke avant runApp
      html.window.history.replaceState(null, '', '/#/auth');
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