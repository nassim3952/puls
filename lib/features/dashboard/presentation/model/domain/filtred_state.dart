import 'package:flutter/material.dart';

@immutable
class DashboardFilterState {
  final DateTimeRange? periode;
  final String? type;
  final String? service;
  final String? exploration;
  final String? sortie;

  const DashboardFilterState({
    this.periode,
    this.type,
    this.service,
    this.exploration,
    this.sortie,
  });

  DashboardFilterState copyWith({
    DateTimeRange? periode,
    String? type,
    String? service,
    String? exploration,
    String? sortie,
  }) {
    return DashboardFilterState(
      periode: periode ?? this.periode,
      type: type ?? this.type,
      service: service ?? this.service,
      exploration: exploration ?? this.exploration,
      sortie: sortie ?? this.sortie,
    );
  }
}