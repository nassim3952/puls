import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/model/domain/filtred_state.dart';


class DashboardFilterNotifier extends Notifier<DashboardFilterState> {
  @override
  DashboardFilterState build() {
    return const DashboardFilterState(); // État initial vide
  }

  void updateService(String? val) => state = state.copyWith(service: val);

  void updateType(String? val) => state = state.copyWith(type: val);

  void updateExploration(String? val) => state = state.copyWith(exploration: val);

  void updateSortie(String? val) => state = state.copyWith(sortie: val);

  void updatePeriode(DateTimeRange? range) => state = state.copyWith(periode: range);

  void reset() => state = const DashboardFilterState();
}

// Le Provider global pour ton UI
final filterProvider = NotifierProvider<DashboardFilterNotifier, DashboardFilterState>(() {
  return DashboardFilterNotifier();
});