import 'package:flutter/material.dart';

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
    DateTimeRange? periode,
    String? type,
    String? service,
    String? exploration,
    String? sortie,
    String? searchQuery, // 👈
  }) {
    return DashboardFilterState(
      periode: periode ?? this.periode,
      type: type ?? this.type,
      service: service ?? this.service,
      exploration: exploration ?? this.exploration,
      sortie: sortie ?? this.sortie,
      searchQuery: searchQuery ?? this.searchQuery, // 👈
    );
  }
}