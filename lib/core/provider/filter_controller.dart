import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/presentation/model/domain/filtred_state.dart';

// On utilise Notifier au lieu de StateNotifier
class FilterNotifier extends Notifier<DashboardFilterState> {
  @override
  DashboardFilterState build() {
    // C'est ici qu'on définit l'état initial
    return const DashboardFilterState();
  }

  // Méthodes pour modifier l'état
  void updateService(String? val) {
    state = state.copyWith(service: val);
  }

  void updateType(String? val) {
    state = state.copyWith(type: val);
  }

  void reset() => state = const DashboardFilterState();

  void applyFilters() {
    // Ici on accède à l'état interne 'state'
    print('Application des filtres : ${state.service} / ${state.type}');
    // Plus tard, c'est ici que tu appelleras ton repository
  }

}

// Le Provider utilise NotifierProvider
final filterProvider = NotifierProvider<FilterNotifier, DashboardFilterState>(() {
  return FilterNotifier();
}



);