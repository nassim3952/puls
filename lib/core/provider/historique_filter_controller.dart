import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/historique/presentation/historique_screen.dart';

// ─── Mode de recherche ────────────────────────────────────────────────────────
enum SearchMode { patient, keyword }

// 1. L'état qui regroupe tous les filtres de l'historique
class HistoriqueFilterState {
  final String searchQuery;
  final SearchMode searchMode;
  final String serviceFilter;
  final String typeFilter;
  final String alertFilter;
  final SortColumn sortColumn;
  final SortDirection sortDirection;

  const HistoriqueFilterState({
    this.searchQuery = '',
    this.searchMode = SearchMode.patient,
    this.serviceFilter = '',
    this.typeFilter = '',
    this.alertFilter = 'all',
    this.sortColumn = SortColumn.none,
    this.sortDirection = SortDirection.asc,
  });

  HistoriqueFilterState copyWith({
    String? searchQuery,
    SearchMode? searchMode,
    String? serviceFilter,
    String? typeFilter,
    String? alertFilter,
    SortColumn? sortColumn,
    SortDirection? sortDirection,
  }) {
    return HistoriqueFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      searchMode: searchMode ?? this.searchMode,
      serviceFilter: serviceFilter ?? this.serviceFilter,
      typeFilter: typeFilter ?? this.typeFilter,
      alertFilter: alertFilter ?? this.alertFilter,
      sortColumn: sortColumn ?? this.sortColumn,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

// 2. Le Notifier
class HistoriqueFilterNotifier extends Notifier<HistoriqueFilterState> {
  @override
  HistoriqueFilterState build() => const HistoriqueFilterState();

  void setSearch(String v) => state = state.copyWith(searchQuery: v);

  void setSearchMode(SearchMode mode) =>
      state = state.copyWith(searchMode: mode, searchQuery: '');

  void setService(String v) => state = state.copyWith(serviceFilter: v);

  void setType(String v) => state = state.copyWith(typeFilter: v);

  void setAlert(String v) => state = state.copyWith(alertFilter: v);

  void reset() => state = const HistoriqueFilterState();

  void setSort(SortColumn col) {
    if (state.sortColumn == col) {
      state = state.copyWith(
        sortDirection: state.sortDirection == SortDirection.asc
            ? SortDirection.desc
            : SortDirection.asc,
      );
    } else {
      state = state.copyWith(sortColumn: col, sortDirection: SortDirection.asc);
    }
  }
}

// 3. Le provider public
final historiqueFilterProvider =
NotifierProvider<HistoriqueFilterNotifier, HistoriqueFilterState>(
    HistoriqueFilterNotifier.new);