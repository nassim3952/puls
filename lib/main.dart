import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes/root_manager.dart';
// 1. L'import indispensable

void main() {

  debugPaintSizeEnabled = false;
  // 2. C'est ICI que ça se joue :
  // runApp doit recevoir le ProviderScope en premier.
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: RouteManager.home,
      onGenerateRoute: RouteManager.generateRoute,
      debugShowCheckedModeBanner: false,
      title: 'Satisfactive',
      // 3. Ici, ton écran principal sera capable de trouver le ProviderScope
      // car il est un "enfant" de MyApp, qui est un enfant de ProviderScope.
    );
  }
}