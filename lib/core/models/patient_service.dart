import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/models/patient.dart';

// Le provider qui expose l'instance de ton service
final patientServiceProvider = Provider<PatientService>((ref) {
  return PatientService();
});

class PatientService {
  // Cette fonction va lire le fichier et retourner une liste de patients
  Future<List<PatientModel>> fetchPatients() async {
    try {
      // 1. Charger le contenu du fichier JSON depuis les assets
      // Vérifie bien que ton chemin vers db.json est correct dans ton pubspec.yaml
      final String response = await rootBundle.loadString('assets/db.json');

      // 2. Décoder la String en une liste dynamique
      final List<dynamic> data = json.decode(response);

      // 3. Convertir chaque élément du JSON en PatientModel
      return data.map((json) => PatientModel.fromJson(json)).toList();
    } catch (e) {
      // En cas d'erreur (chemin faux, JSON mal formé), on renvoie une liste vide
      print("Erreur lors du chargement des patients : $e");
      return [];
    }
  }
}