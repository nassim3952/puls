import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/historique/presentation/historique_screen.dart';

// 1. L'état qui regroupe tous les filtres de l'historique
class HistoriqueFilterState {
  final String searchQuery;
  final String serviceFilter;
  final String typeFilter;
  final String alertFilter;
  final SortColumn sortColumn;
  final SortDirection sortDirection;

  const HistoriqueFilterState({
    this.searchQuery = '',
    this.serviceFilter = '',
    this.typeFilter = '',
    this.alertFilter = 'all',
    this.sortColumn = SortColumn.none,
    this.sortDirection = SortDirection.asc,
  });

  // copyWith permet de modifier un seul élément sans effacer les autres
  HistoriqueFilterState copyWith({
    String? searchQuery,
    String? serviceFilter,
    String? typeFilter,
    String? alertFilter,
    SortColumn? sortColumn,
    SortDirection? sortDirection,
  }) {
    return HistoriqueFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      serviceFilter: serviceFilter ?? this.serviceFilter,
      typeFilter: typeFilter ?? this.typeFilter,
      alertFilter: alertFilter ?? this.alertFilter,
      sortColumn: sortColumn ?? this.sortColumn,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

// 2. Le Notifier qui gère les actions de l'utilisateur
class HistoriqueFilterNotifier extends Notifier<HistoriqueFilterState> {
  @override
  HistoriqueFilterState build() {
    return const HistoriqueFilterState(); // État initial
  }

  // Méthodes pour mettre à jour l'état
  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateService(String service) {
    state = state.copyWith(serviceFilter: service);
  }

  void updateType(String type) {
    state = state.copyWith(typeFilter: type);
  }

  void updateAlert(String alert) {
    state = state.copyWith(alertFilter: alert);
  }

  // Gestion intelligente du tri (toggle asc/desc si on reclique sur la même colonne)
  void changeSort(SortColumn column) {
    if (state.sortColumn == column) {
      state = state.copyWith(
        sortDirection: state.sortDirection == SortDirection.asc
            ? SortDirection.desc
            : SortDirection.asc,
      );
    } else {
      state = state.copyWith(
        sortColumn: column,
        sortDirection: SortDirection.asc,
      );
    }
  }

  void reset() => state = const HistoriqueFilterState();
}

// 3. Le NotifierProvider public
final historiqueFilterProvider = NotifierProvider<HistoriqueFilterNotifier, HistoriqueFilterState>(() {
  return HistoriqueFilterNotifier();
});
