import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/data/fake_data.dart';

// On définit l'état du provider (ici, la liste des noms sélectionnés)
class SplineSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    // État initial : on sélectionne tout par défaut
    return splineData1.map((e) => e.name).toSet();
  }

  void toggleSpline(String name) {
    // En Riverpod, on crée une nouvelle copie du state pour notifier l'UI
    if (state.contains(name)) {
      state = {...state}..remove(name);
    } else {
      state = {...state, name};
    }
  }
}

// Le provider global
final splineSelectionProvider = NotifierProvider<SplineSelectionNotifier, Set<String>>(() {
  return SplineSelectionNotifier();
});