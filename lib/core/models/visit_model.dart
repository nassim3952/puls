import 'package:puls/core/models/survey_response.dart';

class VisitModel {
  final String id;
  final String service;
  final String visitType;
  final String exploration;
  final String afterCare;
  final DateTime date;

  // État alerte / plan d'action (appartient à survey_responses côté BDD)
  final bool hasAlert;
  final bool alertResolved;
  final bool? planIsValid;
  final String? planBy;
  final DateTime? resolvedAt;
  final String? actionPlanLabel;
  final String? actionPlanReport;

  // Réponses du patient — nullable : une visite peut ne pas encore avoir de réponse
  final SurveyResponse? survey;

  const VisitModel({
    required this.id,
    required this.service,
    required this.visitType,
    required this.exploration,
    required this.afterCare,
    required this.date,
    required this.hasAlert,
    required this.alertResolved,
    this.planIsValid,
    this.planBy,
    this.resolvedAt,
    this.actionPlanLabel,
    this.actionPlanReport,
    this.survey,
  });

  factory VisitModel.fromSupabase(Map<String, dynamic> visit) {
    final surveyList = _toList(visit['survey_responses']);
    final raw = surveyList.isNotEmpty
        ? Map<String, dynamic>.from(surveyList.first as Map)
        : <String, dynamic>{};



    final rawAnswers = raw['answers'];
    SurveyResponse? survey;
    if (rawAnswers is Map<String, dynamic> && rawAnswers.isNotEmpty) {
      survey = SurveyResponse.fromAnswersMap(rawAnswers);
    } else if (rawAnswers is List && rawAnswers.isNotEmpty) {
      // fallback ancien format liste (rétrocompatibilité)
      survey = SurveyResponse.fromAnswersMap(
        Map<String, dynamic>.fromEntries(
          rawAnswers
              .whereType<Map>()
              .map((e) => MapEntry(e['question_id']?.toString() ?? '', e)),
        ),
      );
    }

    return VisitModel(
      id: visit['id']?.toString() ?? '',
      service: visit['service']?.toString() ?? '',
      visitType: visit['visit_type']?.toString() ?? '',
      exploration: visit['exploration']?.toString() ?? '',
      afterCare: visit['aftercare']?.toString() ?? '',
      date: visit['date'] != null
          ? DateTime.parse(visit['date'] as String)
          : DateTime.now(),
      hasAlert: raw['has_alert'] as bool? ?? false,
      alertResolved: raw['alert_resolved'] as bool? ?? false,
      planIsValid: raw['plan_is_valid'] as bool?,
      planBy: raw['plan_by']?.toString(),
      resolvedAt: raw['resolved_at'] != null
          ? DateTime.parse(raw['resolved_at'] as String)
          : null,
      actionPlanLabel: raw['action_plan_label'] as String?,
      actionPlanReport: raw['action_plan_report'] as String?,
      survey: survey,
    );
  }

  // Mapping depuis la vue plate patient_visit_view
  factory VisitModel.fromFlatRow(Map<String, dynamic> r) {
    final rawAnswers = r['answers'];
    SurveyResponse? survey;

    if (rawAnswers is Map<String, dynamic> && rawAnswers.isNotEmpty) {
      survey = SurveyResponse.fromAnswersMap(rawAnswers);
    }

    return VisitModel(
      id:            r['visit_id']?.toString() ?? '',
      service:       r['service']?.toString() ?? '',
      visitType:     r['visit_type']?.toString() ?? '',
      exploration:   r['exploration']?.toString() ?? '',
      afterCare:     r['aftercare']?.toString() ?? '',
      date: r['date'] != null
          ? DateTime.parse(r['date'] as String)
          : DateTime.now(),
      hasAlert:      r['has_alert'] as bool? ?? false,
      alertResolved: r['alert_resolved'] as bool? ?? false,
      planIsValid:   r['plan_is_valid'] as bool?,
      planBy:        r['plan_by']?.toString(),
      resolvedAt: r['resolved_at'] != null
          ? DateTime.parse(r['resolved_at'] as String)
          : null,
      actionPlanLabel:  r['action_plan_label'] as String?,
      actionPlanReport: r['action_plan_report'] as String?,
      survey: survey,
    );
  }

  VisitModel copyWith({
    String? id,
    String? service,
    String? visitType,
    String? exploration,
    String? afterCare,
    DateTime? date,
    bool? hasAlert,
    bool? alertResolved,
    Object? planIsValid = _sentinel,
    Object? planBy = _sentinel,
    Object? resolvedAt = _sentinel,
    Object? actionPlanLabel = _sentinel,
    Object? actionPlanReport = _sentinel,
    Object? survey = _sentinel,
  }) {
    return VisitModel(
      id: id ?? this.id,
      service: service ?? this.service,
      visitType: visitType ?? this.visitType,
      exploration: exploration ?? this.exploration,
      afterCare: afterCare ?? this.afterCare,
      date: date ?? this.date,
      hasAlert: hasAlert ?? this.hasAlert,
      alertResolved: alertResolved ?? this.alertResolved,
      planIsValid: planIsValid == _sentinel ? this.planIsValid : planIsValid as bool?,
      planBy: planBy == _sentinel ? this.planBy : planBy as String?,
      resolvedAt: resolvedAt == _sentinel ? this.resolvedAt : resolvedAt as DateTime?,
      actionPlanLabel: actionPlanLabel == _sentinel ? this.actionPlanLabel : actionPlanLabel as String?,
      actionPlanReport: actionPlanReport == _sentinel ? this.actionPlanReport : actionPlanReport as String?,
      survey: survey == _sentinel ? this.survey : survey as SurveyResponse?,
    );
  }
}

const Object _sentinel = Object();

List<dynamic> _toList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value;
  if (value is Map) return [value];
  return [];
}