import 'package:intl/intl.dart';

import '../../../../core/models/patient.dart';
import '../alerts_view.dart';

// ─── Alert level ──────────────────────────────────────────────────────────────
enum AlertLevel { urgent, warning, info }

// ─── Mapping PatientModel → niveau d'alerte ──────────────────────────────────
// On se base sur q0 (score satisfaction 1-5) :
// 1-2 → urgent, 3 → warning, 4-5 → info
AlertLevel levelFromPatient(PatientModel p) {
  final score = int.tryParse(p.patientResponse.q0) ?? 5;
  if (score <= 2) return AlertLevel.urgent;
  if (score == 3) return AlertLevel.warning;
  return AlertLevel.info;
}

// ─── Vue adaptée depuis PatientModel ─────────────────────────────────────────

class AlertView {
  final PatientModel source;

  AlertView(this.source);

  String get patientName => '${source.firstName} ${source.lastName}';
  String get patientId => source.ipp;
  String get avatarInitials {
    final f = source.firstName.isNotEmpty ? source.firstName[0] : '';
    final l = source.lastName.isNotEmpty ? source.lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  AlertLevel get level => levelFromPatient(source);

  String get title {
    switch (level) {
      case AlertLevel.urgent:
        return 'Satisfaction critique — score ${source.patientResponse.q0}/5';
      case AlertLevel.warning:
        return 'Satisfaction modérée — score ${source.patientResponse.q0}/5';
      case AlertLevel.info:
        return 'Suivi post-visite — score ${source.patientResponse.q0}/5';
    }
  }

  // Le verbatim q4 (point d'amélioration) est la description de l'alerte
  String get description {
    final msg = source.patientResponse.q4.message;
    return msg.isNotEmpty ? msg : 'Aucun commentaire renseigné.';
  }

  String get time => DateFormat('dd/MM/yyyy').format(source.date);

  // On n'a pas le téléphone dans PatientModel — on affiche l'IPP en fallback
  // (tu peux ajouter phone dans PatientModel / patient_service quand tu veux)
  String get phone => source.ipp;

  String get condition => '${source.visitType} · ${source.service}';

  // Score douleur simulé depuis q0 inversé : satisfaction 1 = douleur 9, 5 = 1
  double get painScore {
    final q = int.tryParse(source.patientResponse.q0) ?? 3;
    return ((6 - q) * 2).clamp(0, 10).toDouble();
  }

  String get lastVisit => DateFormat('dd/MM/yyyy').format(source.date);
}
