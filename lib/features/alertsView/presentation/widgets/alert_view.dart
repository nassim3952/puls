import 'package:intl/intl.dart';

import '../../../../core/models/patient.dart';
import '../../../../core/models/visit_model.dart';
import '../alerts_view.dart';

// ─── Alert level ──────────────────────────────────────────────────────────────
enum AlertLevel { urgent, warning, info }

// ─── Mapping PatientModel → niveau d'alerte ──────────────────────────────────
// On se base sur qualitePriseEnCharge (score satisfaction 1-5) :
// 1-2 → urgent, 3 → warning, 4-5 → info
AlertLevel levelFromPatient(PatientModel p) {
  final score = p.latestVisit?.survey?.qualitePriseEnCharge ?? 5;
  if (score <= 2) return AlertLevel.urgent;
  if (score == 3) return AlertLevel.warning;
  return AlertLevel.info;
}

// ─── Vue adaptée depuis PatientModel ─────────────────────────────────────────

class AlertView {
  final PatientModel source;

  AlertView(this.source);

  VisitModel? get _visit => source.latestVisit;

  String get patientName => '${source.firstName} ${source.lastName}';
  String get patientId => source.ipp;
  String get avatarInitials {
    final f = source.firstName.isNotEmpty ? source.firstName[0] : '';
    final l = source.lastName.isNotEmpty ? source.lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  AlertLevel get level => levelFromPatient(source);

  String get title {
    final score = _visit?.survey?.qualitePriseEnCharge ?? 0;
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
    final msg = _visit?.survey?.suggestionsAmelioration.message ?? '';
    return msg.isNotEmpty ? msg : 'Aucun commentaire renseigné.';
  }

  String get time =>
      _visit != null ? DateFormat('dd/MM/yyyy').format(_visit!.date) : '–';

  String get phone => source.ipp;

  String get condition =>
      '${_visit?.visitType ?? ''} · ${_visit?.service ?? ''}';

  // Score douleur inversé depuis qualitePriseEnCharge : 1 = 8, 5 = 0
  double get painScore {
    final q = _visit?.survey?.qualitePriseEnCharge ?? 3;
    return ((6 - q) * 2).clamp(0, 10).toDouble();
  }

  String get lastVisit =>
      _visit != null ? DateFormat('dd/MM/yyyy').format(_visit!.date) : '–';
}