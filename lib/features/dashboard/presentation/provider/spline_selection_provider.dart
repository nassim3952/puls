import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplineSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {
      'OUI TOTALEMENT',
    };
  }

  void toggleSpline(String name) {
    final upperName = name.toUpperCase();
    final newState = {...state};
    if (newState.contains(upperName)) {
      newState.remove(upperName);
    } else {
      newState.add(upperName);
    }
    state = newState;
  }
}

final splineSelectionProvider = NotifierProvider<SplineSelectionNotifier, Set<String>>(() {
  return SplineSelectionNotifier();
});