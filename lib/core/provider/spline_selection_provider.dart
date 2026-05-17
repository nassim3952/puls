import 'package:flutter_riverpod/flutter_riverpod.dart';

// On définit l'état du provider (ici, la liste des noms sélectionnés)
class SplineSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    // On définit manuellement les clés de référence pour éviter les surprises du fake_data
    return {
      'OUI TOTALEMENT',
      'EN PARTIE',
      'NON',
      'EN ATTENTE',
    };
  }

  void toggleSpline(String name) {
    final upperName = name.toUpperCase();

    // On crée une copie locale pour manipuler le Set tranquillement
    final newState = {...state};

    if (newState.contains(upperName)) {
      newState.remove(upperName);
    } else {
      newState.add(upperName);
    }

    // On réassigne l'état pour notifier les widgets
    state = newState;
  }}
// Le provider global
final splineSelectionProvider = NotifierProvider<SplineSelectionNotifier, Set<String>>(() {
  return SplineSelectionNotifier();
});