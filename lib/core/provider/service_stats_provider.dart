import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:puls/core/models/patient.dart';
import '../models/service_stats_model.dart';
import 'patient_provider.dart';

/// Provider pour le patient sélectionné dans la vue détail
final selectedPatientProvider = StateNotifierProvider<SelectedPatientNotifier, String?>((ref) {
  return SelectedPatientNotifier();
});

class SelectedPatientNotifier extends StateNotifier<String?> {
  SelectedPatientNotifier() : super(null);

  void setPatient(String? patientId) {
    state = patientId;
  }

  void clear() {
    state = null;
  }
}

/// Provider qui retourne la liste de tous les services avec leurs stats
final serviceStatsListProvider = Provider<AsyncValue<List<ServiceStats>>>((ref) {
  final patientsAsync = ref.watch(patientsListProvider);

  return patientsAsync.whenData((patients) {
    // Extraire tous les services uniques
    final servicesSet = <String>{};
    for (final patient in patients) {
      for (final visit in patient.visits) {
        if (visit.service.isNotEmpty) {
          servicesSet.add(visit.service);
        }
      }
    }

    // Créer les stats pour chaque service
    final stats = servicesSet
        .map((serviceName) => ServiceStats.fromPatients(serviceName, patients))
        .toList();

    // Tri par nombre de visites (desc) puis par nom
    stats.sort((a, b) {
      final cmp = b.totalVisits.compareTo(a.totalVisits);
      return cmp != 0 ? cmp : a.serviceName.compareTo(b.serviceName);
    });

    return stats;
  });
});

/// Provider dérivé pour les filtres/tris spécifiques à l'écran services
class ServiceFilterState {
  final String searchQuery;
  final ServiceSortColumn sortColumn;
  final SortDirection sortDirection;

  const ServiceFilterState({
    this.searchQuery = '',
    this.sortColumn = ServiceSortColumn.visits,
    this.sortDirection = SortDirection.desc,
  });

  ServiceFilterState copyWith({
    String? searchQuery,
    ServiceSortColumn? sortColumn,
    SortDirection? sortDirection,
  }) {
    return ServiceFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortColumn: sortColumn ?? this.sortColumn,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

enum ServiceSortColumn { name, visits, isgpp, alerts }
enum SortDirection { asc, desc }

class ServiceFilterNotifier extends Notifier<ServiceFilterState> {
  @override
  ServiceFilterState build() => const ServiceFilterState();

  void setSearch(String v) => state = state.copyWith(searchQuery: v);

  void reset() => state = const ServiceFilterState();

  void setSort(ServiceSortColumn col) {
    if (state.sortColumn == col) {
      state = state.copyWith(
        sortDirection: state.sortDirection == SortDirection.asc
            ? SortDirection.desc
            : SortDirection.asc,
      );
    } else {
      state = state.copyWith(sortColumn: col, sortDirection: SortDirection.desc);
    }
  }
}

final serviceFilterProvider =
NotifierProvider<ServiceFilterNotifier, ServiceFilterState>(
    ServiceFilterNotifier.new);

/// Provider dérivé : liste filtrée + triée des services
final filteredServiceStatsProvider =
Provider<AsyncValue<List<ServiceStats>>>((ref) {
  final statsAsync = ref.watch(serviceStatsListProvider);
  final filters = ref.watch(serviceFilterProvider);

  return statsAsync.whenData((stats) {
    var result = stats.where((s) {
      final q = filters.searchQuery.toLowerCase().trim();
      if (q.isEmpty) return true;
      return s.serviceName.toLowerCase().contains(q);
    }).toList();

    // Tri
    final asc = filters.sortDirection == SortDirection.asc;
    switch (filters.sortColumn) {
      case ServiceSortColumn.name:
        result.sort((a, b) {
          final cmp = a.serviceName.compareTo(b.serviceName);
          return asc ? cmp : -cmp;
        });
        break;
      case ServiceSortColumn.visits:
        result.sort((a, b) {
          final cmp = a.totalVisits.compareTo(b.totalVisits);
          return asc ? cmp : -cmp;
        });
        break;
      case ServiceSortColumn.isgpp:
        result.sort((a, b) {
          final cmp = a.averageIsgpp.compareTo(b.averageIsgpp);
          return asc ? cmp : -cmp;
        });
        break;
      case ServiceSortColumn.alerts:
        result.sort((a, b) {
          final cmp = a.alertCount.compareTo(b.alertCount);
          return asc ? cmp : -cmp;
        });
        break;
    }

    return result;
  });
});