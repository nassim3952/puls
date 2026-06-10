import 'package:intl/intl.dart';
import '../../../../core/models/patient.dart';
import '../../../../core/models/visit_model.dart';

// ─── Alert level ──────────────────────────────────────────────────────────────
enum AlertLevel { urgent, warning, info }

// ─── Mapping VisitModel → niveau d'alerte ────────────────────────────────────
// On se base sur qualitePriseEnCharge (score satisfaction 1-5) :
// 1-2 → urgent, 3 → warning, 4-5 → info
AlertLevel levelFromVisit(VisitModel visit) {
  final score = visit.survey?.qualitePriseEnCharge ?? 5;
  if (score <= 2) return AlertLevel.urgent;
  if (score == 3) return AlertLevel.warning;
  return AlertLevel.info;
}

// ─── Vue adaptée depuis PatientModel + VisitModel explicite ──────────────────

class AlertView {
  final PatientModel source;
  final VisitModel visit; // visite concernée — plus de latestVisit implicite

  AlertView(this.source, this.visit);

  String get patientName => '${source.firstName} ${source.lastName}';
  String get patientId => source.ipp;
  String get avatarInitials {
    final f = source.firstName.isNotEmpty ? source.firstName[0] : '';
    final l = source.lastName.isNotEmpty ? source.lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  AlertLevel get level => levelFromVisit(visit);

  String get title {
    final score = visit.survey?.qualitePriseEnCharge ?? 0;
    switch (level) {
      case AlertLevel.urgent:
        return 'Satisfaction critique — score $score/5';
      case AlertLevel.warning:
        return 'Satisfaction modérée — score $score/5';
      case AlertLevel.info:
        return 'Suivi post-visite — score $score/5';
    }
  }

  // suggestionsAmelioration = q4
  String get description {
    final msg = visit.survey?.suggestionsAmelioration.message ?? '';
    return msg.isNotEmpty ? msg : 'Aucun commentaire renseigné.';
  }

  String get time => DateFormat('dd/MM/yyyy').format(visit.date);

  // ← CORRIGÉ : utilise le vrai numéro de téléphone du patient
  String? get phone => source.phone;

  String get condition => '${visit.visitType} · ${visit.service}';

  // Score douleur inversé depuis qualitePriseEnCharge : 1 = 8, 5 = 0
  double get painScore {
    final q = visit.survey?.qualitePriseEnCharge ?? 3;
    return ((6 - q) * 2).clamp(0, 10).toDouble();
  }

  String get lastVisit => DateFormat('dd/MM/yyyy').format(visit.date);
}