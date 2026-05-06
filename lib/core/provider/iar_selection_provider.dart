import 'package:flutter_riverpod/flutter_riverpod.dart';

// On définit le Notifier moderne
class IarSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    // État initial : on affiche tout par défaut
    return {
      "Accueil", "Attente", "Empathie", "Écoute", "Médecin",
      "Soins", "Douleur", "Explication", "Propreté"
    };
  }

  void toggleName(String name) {
    if (state.contains(name)) {
      state = { ...state }..remove(name);
    } else {
      state = { ...state, name };
    }
  }
}

// Le provider utilisant le nouveau Notifier
final iarSelectionProvider = NotifierProvider<IarSelectionNotifier, Set<String>>(
  IarSelectionNotifier.new,
);