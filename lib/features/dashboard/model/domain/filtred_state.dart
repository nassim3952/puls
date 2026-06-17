import 'package:flutter/material.dart';

/// Valeur sentinelle interne utilisée par [DashboardFilterState.copyWith]
/// pour distinguer "paramètre non fourni" de "paramètre fourni avec la
/// valeur null". Sans ça, `copyWith(periode: null)` ne pouvait jamais
/// effacer la période (il gardait l'ancienne valeur via `?? this.periode`),
/// ce qui empêchait le bouton "Tout" de fonctionner correctement.
const Object _sentinel = Object();

class DashboardFilterState {
  final DateTimeRange? periode;
  final String? type;
  final String? service;
  final String? exploration;
  final String? sortie;
  final String searchQuery; // 👈 ajoute ça

  const DashboardFilterState({
    this.periode,
    this.type,
    this.service,
    this.exploration,
    this.sortie,
    this.searchQuery = '', // 👈
  });

  DashboardFilterState copyWith({
    Object? periode = _sentinel,
    Object? type = _sentinel,
    Object? service = _sentinel,
    Object? exploration = _sentinel,
    Object? sortie = _sentinel,
    String? searchQuery, // 👈
  }) {
    return DashboardFilterState(
      periode: periode == _sentinel ? this.periode : periode as DateTimeRange?,
      type: type == _sentinel ? this.type : type as String?,
      service: service == _sentinel ? this.service : service as String?,
      exploration: exploration == _sentinel ? this.exploration : exploration as String?,
      sortie: sortie == _sentinel ? this.sortie : sortie as String?,
      searchQuery: searchQuery ?? this.searchQuery, // 👈
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardFilterState &&
        other.periode == periode &&
        other.type == type &&
        other.service == service &&
        other.exploration == exploration &&
        other.sortie == sortie &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode => Object.hash(periode, type, service, exploration, sortie, searchQuery);
}