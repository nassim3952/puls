import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puls/core/provider/auth_provider.dart';
import 'package:puls/core/provider/filter_controller.dart';

// ─── Palette PULS ─────────────────────────────────────────────────────────────
const _blue        = PdfColor.fromInt(0xFF1E6FDB);
const _blueDark    = PdfColor.fromInt(0xFF1450A8);
const _blueLighter = PdfColor.fromInt(0xFFE8F0FB);
const _bg          = PdfColor.fromInt(0xFFF5F7FA);
const _surface     = PdfColor.fromInt(0xFFFFFFFF);
const _textPrimary = PdfColor.fromInt(0xFF1A1D23);
const _textSub     = PdfColor.fromInt(0xFF6B7280);
const _border      = PdfColor.fromInt(0xFFE5E7EB);
const _green       = PdfColor.fromInt(0xFF10B981);
const _orange      = PdfColor.fromInt(0xFFF59E0B);
const _red         = PdfColor.fromInt(0xFFEF4444);

// ─── Modèle de données ────────────────────────────────────────────────────────
class PdfReportData {
  final Map<String, dynamic> kpi;
  final List<dynamic> q0Timeline;
  final List<dynamic> q1Dist;
  final List<dynamic> byService;
  final List<dynamic> alerts;
  final List<dynamic> verbatims;
  final String? serviceFilter;
  final String? typeFilter;
  final String? periodeLabel;
  final DateTime generatedAt;

  const PdfReportData({
    required this.kpi,
    required this.q0Timeline,
    required this.q1Dist,
    required this.byService,
    required this.alerts,
    required this.verbatims,
    this.serviceFilter,
    this.typeFilter,
    this.periodeLabel,
    required this.generatedAt,
  });

  factory PdfReportData.fromJson(Map<String, dynamic> json, {
    String? serviceFilter,
    String? typeFilter,
    String? periodeLabel,
  }) {
    return PdfReportData(
      kpi:          json['kpi'] as Map<String, dynamic>,
      q0Timeline:   json['q0_timeline'] as List? ?? [],
      q1Dist:       json['q1_dist'] as List? ?? [],
      byService:    json['by_service'] as List? ?? [],
      alerts:       json['alerts'] as List? ?? [],
      verbatims:    json['verbatims'] as List? ?? [],
      serviceFilter: serviceFilter,
      typeFilter:    typeFilter,
      periodeLabel:  periodeLabel,
      generatedAt:   DateTime.now(),
    );
  }
}

// ─── Service ──────────────────────────────────────────────────────────────────
class DashboardPdfService {

  // ── Fetch les données depuis Supabase puis génère le PDF ──────────────────
  static Future<Uint8List> generateFromSupabase(WidgetRef ref) async {
    final hospitalId = ref.read(authProvider).user?.hospitalId;
    final filters    = ref.read(filterProvider);

    if (hospitalId == null) throw Exception('Hôpital introuvable');

    final result = await Supabase.instance.client.rpc(
      'get_pdf_report',
      params: {
        'p_hospital_id': hospitalId,
        if (filters.service?.isNotEmpty == true)     'p_service':     filters.service,
        if (filters.type?.isNotEmpty == true)        'p_type':        filters.type,
        if (filters.exploration?.isNotEmpty == true) 'p_exploration': filters.exploration,
        if (filters.sortie?.isNotEmpty == true)      'p_sortie':      filters.sortie,
        if (filters.periode != null) 'p_date_start': filters.periode!.start.toIso8601String(),
        if (filters.periode != null) 'p_date_end':   filters.periode!.end.toIso8601String(),
      },
    );

    String? periodeLabel;
    if (filters.periode != null) {
      final fmt = DateFormat('dd/MM/yyyy');
      periodeLabel =
      '${fmt.format(filters.periode!.start)} – ${fmt.format(filters.periode!.end)}';
    }

    final data = PdfReportData.fromJson(
      result as Map<String, dynamic>,
      serviceFilter: filters.service,
      typeFilter:    filters.type,
      periodeLabel:  periodeLabel,
    );

    return generate(data);
  }

  // ── Génère le PDF depuis les données ──────────────────────────────────────
  static Future<Uint8List> generate(PdfReportData d) async {
    final doc = pw.Document(
      title:  'Rapport PULS – Dashboard',
      author: 'PULS Analytics',
    );

    // Page 1 : Couverture
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => _coverPage(d),
    ));

    // Page 2 : KPI globaux
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 28),
      build: (ctx) => _kpiPage(d, ctx),
    ));

    // Page 3 : Satisfaction Q0
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 28),
      build: (ctx) => _q0Page(d, ctx),
    ));

    // Page 4 : Efficacité médicale Q1
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 28),
      build: (ctx) => _q1Page(d, ctx),
    ));

    // Page 5 : Répartition par service
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 28),
      build: (ctx) => _servicePage(d, ctx),
    ));

    // Page 6 : Alertes détaillées
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 28),
      build: (ctx) => _alertsPage(d, ctx),
    ));

    // Page 7 : Verbatims
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 28),
      build: (ctx) => _verbatimsPage(d, ctx),
    ));

    return doc.save();
  }

  // ── PAGE 1 : Couverture ───────────────────────────────────────────────────
  static pw.Widget _coverPage(PdfReportData d) {
    final hasFilters = d.serviceFilter != null ||
        d.typeFilter != null ||
        d.periodeLabel != null;

    final isgpp = (d.kpi['isgpp_score'] as num?)?.toDouble() ?? 0;
    final totalPatients = d.kpi['total_patients'] as int? ?? 0;
    final totalAlerts   = d.kpi['total_alerts']   as int? ?? 0;

    return pw.Stack(children: [
      pw.Positioned(top: 0, left: 0, right: 0,
          child: pw.Container(height: 380, color: _blue)),
      pw.Positioned(top: -80, right: -80,
          child: _circle(300, PdfColor.fromInt(0x18FFFFFF))),
      pw.Positioned(top: 140, right: 30,
          child: _circle(150, PdfColor.fromInt(0x12FFFFFF))),
      pw.Positioned(top: 260, left: -40,
          child: _circle(120, PdfColor.fromInt(0x10FFFFFF))),

      pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(44, 36, 44, 0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(children: [
                  pw.Container(width: 4, height: 28, color: _surface),
                  pw.SizedBox(width: 10),
                  pw.Text('PULS', style: pw.TextStyle(
                      color: _surface, fontSize: 20,
                      fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
                ]),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0x30FFFFFF),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20))),
                  child: pw.Text('CONFIDENTIEL', style: pw.TextStyle(
                      color: _surface, fontSize: 8,
                      fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                ),
              ],
            ),
            pw.SizedBox(height: 56),
            pw.Text('Rapport de Performance', style: pw.TextStyle(
                color: PdfColor.fromInt(0xCCFFFFFF), fontSize: 13)),
            pw.SizedBox(height: 10),
            pw.Text('Dashboard\nAnalytique', style: pw.TextStyle(
                color: _surface, fontSize: 38,
                fontWeight: pw.FontWeight.bold, lineSpacing: 6)),
            pw.SizedBox(height: 18),
            pw.Container(width: 56, height: 3,
                decoration: pw.BoxDecoration(color: _surface,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)))),
            pw.SizedBox(height: 44),

            if (hasFilters)
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0x25FFFFFF),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10))),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Filtres appliqués', style: pw.TextStyle(
                        color: PdfColor.fromInt(0xCCFFFFFF), fontSize: 9,
                        fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Wrap(spacing: 8, runSpacing: 6, children: [
                      if (d.serviceFilter != null) _chip('Service : ${d.serviceFilter}'),
                      if (d.typeFilter != null)    _chip('Type : ${d.typeFilter}'),
                      if (d.periodeLabel != null)  _chip('Période : ${d.periodeLabel}'),
                    ]),
                  ],
                ),
              ),

            pw.SizedBox(height: 20),
            pw.Container(height: 1, color: PdfColor.fromInt(0x30FFFFFF)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                    'Généré le ${DateFormat("dd MMMM yyyy 'à' HH:mm", 'fr_FR').format(d.generatedAt)}',
                    style: pw.TextStyle(color: PdfColor.fromInt(0x99FFFFFF), fontSize: 9)),
                pw.Text('puls.app', style: pw.TextStyle(
                    color: PdfColor.fromInt(0x99FFFFFF), fontSize: 9,
                    fontStyle: pw.FontStyle.italic)),
              ],
            ),
          ],
        ),
      ),

      pw.Positioned(bottom: 0, left: 0, right: 0,
        child: pw.Container(
          color: _bg,
          padding: const pw.EdgeInsets.fromLTRB(44, 28, 44, 32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Indicateurs clés', style: pw.TextStyle(
                  color: _textPrimary, fontSize: 13,
                  fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 18),
              pw.Row(children: [
                pw.Expanded(child: _kpiCard(
                    'ISGPP', '${isgpp.toInt()}%',
                    'Satisfaction globale', _scoreColor(isgpp))),
                pw.SizedBox(width: 14),
                pw.Expanded(child: _kpiCard(
                    'Patients', '$totalPatients',
                    'Réponses collectées', _blue)),
                pw.SizedBox(width: 14),
                pw.Expanded(child: _kpiCard(
                    'Alertes', '$totalAlerts',
                    'Alertes détectées', _red)),
              ]),
            ],
          ),
        ),
      ),
    ]);
  }

  // ── PAGE 2 : KPI Globaux ──────────────────────────────────────────────────
  static pw.Widget _kpiPage(PdfReportData d, pw.Context ctx) {
    final kpi = d.kpi;
    final isgpp        = (kpi['isgpp_score']    as num?)?.toDouble() ?? 0;
    final totalP       = kpi['total_patients']  as int? ?? 0;
    final totalV       = kpi['total_visits']    as int? ?? 0;
    final totalR       = kpi['total_responses'] as int? ?? 0;
    final totalA       = kpi['total_alerts']    as int? ?? 0;
    final totalRes     = kpi['total_resolved']  as int? ?? 0;
    final totalPend    = kpi['total_pending']   as int? ?? 0;
    final totalVal     = kpi['total_validated'] as int? ?? 0;
    final responseRate = (kpi['response_rate']  as num?)?.toDouble() ?? 0;
    final consentRate  = (kpi['consent_rate']   as num?)?.toDouble() ?? 0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _pageHeader('KPI Globaux', 'Vue d\'ensemble des indicateurs clés', ctx),
        pw.SizedBox(height: 22),

        // Ligne 1
        pw.Row(children: [
          pw.Expanded(child: _kpiCard('Patients', '$totalP', 'Total patients', _blue)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _kpiCard('Visites', '$totalV', 'Total visites', _blue)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _kpiCard('Réponses', '$totalR', 'Total réponses', _green)),
        ]),
        pw.SizedBox(height: 12),

        // Ligne 2
        pw.Row(children: [
          pw.Expanded(child: _kpiCard('Taux réponse', '${responseRate.toStringAsFixed(1)}%', 'Réponses / Visites', _blue)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _kpiCard('Consentement', '${consentRate.toStringAsFixed(1)}%', 'Accord rappel', _green)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _kpiCard('ISGPP', '${isgpp.toInt()}%', 'Score satisfaction', _scoreColor(isgpp))),
        ]),
        pw.SizedBox(height: 12),

        // Ligne 3 : alertes
        pw.Row(children: [
          pw.Expanded(child: _kpiCard('Alertes', '$totalA', 'Total alertes', _red)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _kpiCard('En attente', '$totalPend', 'Plan en cours', _orange)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _kpiCard('Résolues', '$totalRes', 'Alertes traitées', _green)),
        ]),
        pw.SizedBox(height: 12),

        // Ligne 4 : validées
        pw.Row(children: [
          pw.Expanded(child: _kpiCard('Validées', '$totalVal', 'Plans validés', _green)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: pw.SizedBox()),
          pw.SizedBox(width: 12),
          pw.Expanded(child: pw.SizedBox()),
        ]),

        pw.Spacer(),
        _footer(d, ctx),
      ],
    );
  }

  // ── PAGE 3 : Satisfaction Q0 ──────────────────────────────────────────────
  static pw.Widget _q0Page(PdfReportData d, pw.Context ctx) {
    final isgpp = (d.kpi['isgpp_score'] as num?)?.toDouble() ?? 0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _pageHeader('ISGPP – Satisfaction Globale', 'Indice de Satisfaction Globale du Parcours Patient', ctx),
        pw.SizedBox(height: 22),

        // Score global
        pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
              color: _surface, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              border: pw.Border.all(color: _border)),
          child: pw.Row(children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Score moyen', style: pw.TextStyle(color: _textSub, fontSize: 10)),
              pw.SizedBox(height: 4),
              pw.Text('${isgpp.toInt()}%', style: pw.TextStyle(
                  color: _scoreColor(isgpp), fontSize: 36, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              // Barre de progression
              pw.Container(
                width: 200,
                height: 8,
                decoration: pw.BoxDecoration(
                    color: _bg, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                child: pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Container(
                    width: 200 * (isgpp.clamp(0, 100) / 100),
                    height: 8,
                    decoration: pw.BoxDecoration(
                        color: _scoreColor(isgpp),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                  ),
                ),
              ),
            ]),
            pw.SizedBox(width: 40),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _legendItem(_green,  'Excellent (> 70%)'),
              pw.SizedBox(height: 6),
              _legendItem(_orange, 'Moyen (40% – 70%)'),
              pw.SizedBox(height: 6),
              _legendItem(_red,    'Insuffisant (< 40%)'),
            ]),
          ]),
        ),

        pw.SizedBox(height: 20),

        // Timeline
        pw.Text('Évolution dans le temps', style: pw.TextStyle(
            color: _textPrimary, fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),

        if (d.q0Timeline.isNotEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
                color: _surface, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                border: pw.Border.all(color: _border)),
            child: pw.Table(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(color: _border, width: 0.5),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: _blueLighter),
                  children: [
                    _tableHeader('Date'),
                    _tableHeader('Score moyen'),
                  ],
                ),
                ...d.q0Timeline.map((point) {
                  final p = point as Map<String, dynamic>;
                  final score = (p['y'] as num).toDouble();
                  return pw.TableRow(children: [
                    _tableCell(p['x'].toString()),
                    _tableCellColored('${score.toStringAsFixed(1)}%', _scoreColor(score)),
                  ]);
                }),
              ],
            ),
          ),

        pw.Spacer(),
        _footer(d, ctx),
      ],
    );
  }

  // ── PAGE 4 : Efficacité Médicale Q1 ──────────────────────────────────────
  static pw.Widget _q1Page(PdfReportData d, pw.Context ctx) {
    final q1Colors = {
      'Oui totalement': _green,
      'En partie':      _orange,
      'Non':            _red,
      'En attente':     _textSub,
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _pageHeader('EMP – Efficacité Médicale Perçue',
            'Perception du patient sur la qualité des soins', ctx),
        pw.SizedBox(height: 22),

        if (d.q1Dist.isNotEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
                color: _surface,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                border: pw.Border.all(color: _border)),
            child: pw.Column(children: [
              ...d.q1Dist.map((item) {
                final e     = item as Map<String, dynamic>;
                final label = e['label'] as String;
                final pct   = (e['pct'] as num).toDouble();
                final count = e['count'] as int;
                final color = q1Colors[label] ?? _blue;

                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Row(children: [
                    pw.SizedBox(
                      width: 120,
                      child: pw.Text(label, style: pw.TextStyle(
                          color: _textPrimary, fontSize: 10)),
                    ),
                    pw.Expanded(
                      child: pw.Stack(children: [
                        pw.Container(
                          height: 16,
                          decoration: pw.BoxDecoration(
                              color: _bg,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
                        ),
                        pw.Container(
                          height: 16,
                          width: (300 * pct / 100).clamp(0, 300),
                          decoration: pw.BoxDecoration(
                              color: color,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
                        ),
                      ]),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Text('${pct.toStringAsFixed(1)}% ($count)',
                        style: pw.TextStyle(color: _textSub, fontSize: 9)),
                  ]),
                );
              }),
            ]),
          ),

        pw.Spacer(),
        _footer(d, ctx),
      ],
    );
  }

  // ── PAGE 5 : Répartition par Service ──────────────────────────────────────
  static pw.Widget _servicePage(PdfReportData d, pw.Context ctx) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _pageHeader('Répartition par Service',
            'Performance et activité par service hospitalier', ctx),
        pw.SizedBox(height: 22),

        if (d.byService.isNotEmpty)
          pw.Container(
            decoration: pw.BoxDecoration(
                color: _surface,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                border: pw.Border.all(color: _border)),
            child: pw.Table(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(color: _border, width: 0.5),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
                5: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: _blueLighter),
                  children: [
                    _tableHeader('Service'),
                    _tableHeader('Visites'),
                    _tableHeader('Réponses'),
                    _tableHeader('Taux rép.'),
                    _tableHeader('ISGPP'),
                    _tableHeader('Alertes'),
                  ],
                ),
                ...d.byService.map((item) {
                  final s         = item as Map<String, dynamic>;
                  final isgpp     = (s['isgpp_score'] as num?)?.toDouble();
                  final taux      = (s['response_rate'] as num?)?.toDouble() ?? 0;
                  return pw.TableRow(children: [
                    _tableCell(s['service']?.toString() ?? '–'),
                    _tableCell('${s['nb_visits'] ?? 0}'),
                    _tableCell('${s['nb_responses'] ?? 0}'),
                    _tableCellColored('${taux.toStringAsFixed(1)}%',
                        taux >= 70 ? _green : taux >= 40 ? _orange : _red),
                    isgpp != null
                        ? _tableCellColored('${isgpp.toInt()}%', _scoreColor(isgpp))
                        : _tableCell('–'),
                    _tableCellColored('${s['nb_alerts'] ?? 0}',
                        (s['nb_alerts'] as int? ?? 0) > 0 ? _red : _green),
                  ]);
                }),
              ],
            ),
          ),

        pw.Spacer(),
        _footer(d, ctx),
      ],
    );
  }

  // ── PAGE 6 : Alertes détaillées ───────────────────────────────────────────
  static pw.Widget _alertsPage(PdfReportData d, pw.Context ctx) {
    final statutColor = {
      'Actif':      _red,
      'En attente': _orange,
      'Résolu':     _green,
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _pageHeader('Alertes Détaillées', 'Suivi des alertes patients', ctx),
        pw.SizedBox(height: 22),

        // Résumé
        pw.Row(children: [
          pw.Expanded(child: _kpiCard('Actives',
              '${d.kpi['total_alerts'] as int? ?? 0}', 'Non traitées', _red)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _kpiCard('En attente',
              '${d.kpi['total_pending'] as int? ?? 0}', 'Plan en cours', _orange)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _kpiCard('Résolues',
              '${d.kpi['total_validated'] as int? ?? 0}', 'Plans validés', _green)),
        ]),
        pw.SizedBox(height: 20),

        if (d.alerts.isNotEmpty)
          pw.Container(
            decoration: pw.BoxDecoration(
                color: _surface,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                border: pw.Border.all(color: _border)),
            child: pw.Table(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(color: _border, width: 0.5),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.2),
                4: const pw.FlexColumnWidth(1.2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: _blueLighter),
                  children: [
                    _tableHeader('Patient'),
                    _tableHeader('IPP'),
                    _tableHeader('Service'),
                    _tableHeader('Date'),
                    _tableHeader('Statut'),
                  ],
                ),
                ...d.alerts.map((item) {
                  final a      = item as Map<String, dynamic>;
                  final statut = a['statut'] as String? ?? '–';
                  return pw.TableRow(children: [
                    _tableCell(a['patient']?.toString() ?? '–'),
                    _tableCell(a['ipp']?.toString() ?? '–'),
                    _tableCell(a['service']?.toString() ?? 'N/A'),
                    _tableCell(a['date']?.toString() ?? '–'),
                    _tableCellColored(statut, statutColor[statut] ?? _textSub),
                  ]);
                }),
              ],
            ),
          ),

        pw.Spacer(),
        _footer(d, ctx),
      ],
    );
  }

  // ── PAGE 7 : Verbatims ────────────────────────────────────────────────────
  static pw.Widget _verbatimsPage(PdfReportData d, pw.Context ctx) {
    final polariteColor = {
      'Positive': _green,
      'Negative': _red,
      'Négative': _red,
      'Neutre':   _textSub,
    };

    // Grouper par question
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final v in d.verbatims) {
      final item = v as Map<String, dynamic>;
      final q    = item['question'] as String? ?? '–';
      grouped.putIfAbsent(q, () => []).add(item);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _pageHeader('Verbatims Patients',
            'Extraits qualitatifs classés par polarité', ctx),
        pw.SizedBox(height: 16),

        pw.Expanded(
          child: pw.ListView(children: [
            ...grouped.entries.map((entry) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: pw.BoxDecoration(
                      color: _blueLighter,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
                  child: pw.Text(entry.key, style: pw.TextStyle(
                      color: _blue, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 8),
                ...entry.value.map((v) {
                  final pol   = v['polarite'] as String? ?? 'Neutre';
                  final color = polariteColor[pol] ?? _textSub;
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                          color: _surface,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                          border: pw.Border.all(color: _border)),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 4, height: 40,
                            decoration: pw.BoxDecoration(
                                color: color,
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2))),
                          ),
                          pw.SizedBox(width: 10),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  v['message']?.toString() ?? '',
                                  style: pw.TextStyle(color: _textPrimary, fontSize: 9, lineSpacing: 2),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Row(children: [
                                  pw.Text(v['patient']?.toString() ?? '',
                                      style: pw.TextStyle(color: _textSub, fontSize: 8,
                                          fontStyle: pw.FontStyle.italic)),
                                  pw.SizedBox(width: 8),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: pw.BoxDecoration(
                                        color: color,
                                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                                    child: pw.Text(pol,
                                        style: pw.TextStyle(color: _surface, fontSize: 7,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  if (v['classe'] != null) ...[
                                    pw.SizedBox(width: 6),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: pw.BoxDecoration(
                                          color: _blueLighter,
                                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                                      child: pw.Text(v['classe'].toString(),
                                          style: pw.TextStyle(color: _blue, fontSize: 7)),
                                    ),
                                  ],
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                pw.SizedBox(height: 12),
              ],
            )),
          ]),
        ),

        _footer(d, ctx),
      ],
    );
  }

  // ── Helpers partagés ──────────────────────────────────────────────────────

  static pw.Widget _pageHeader(String title, String subtitle, pw.Context ctx) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(title, style: pw.TextStyle(
                fontSize: 19, fontWeight: pw.FontWeight.bold, color: _textPrimary)),
            pw.SizedBox(height: 3),
            pw.Text(subtitle, style: pw.TextStyle(fontSize: 10, color: _textSub)),
          ]),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
                color: _blueLighter,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
            child: pw.Text('PULS Analytics', style: pw.TextStyle(
                color: _blue, fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
      pw.SizedBox(height: 6),
      pw.Container(height: 2, decoration: pw.BoxDecoration(
          color: _blue, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1)))),
    ]);
  }

  static pw.Widget _footer(PdfReportData d, pw.Context ctx) {
    return pw.Column(children: [
      pw.Container(height: 1, color: _border),
      pw.SizedBox(height: 8),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
              'PULS – Rapport confidentiel · ${DateFormat('dd/MM/yyyy').format(d.generatedAt)}',
              style: pw.TextStyle(color: _textSub, fontSize: 8)),
          pw.Text('Page ${ctx.pageNumber} / ${ctx.pagesCount}',
              style: pw.TextStyle(color: _textSub, fontSize: 8)),
        ],
      ),
    ]);
  }

  static pw.Widget _kpiCard(String label, String value, String sub, PdfColor color) =>
      pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
            color: _surface,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            border: pw.Border.all(color: _border)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text(label, style: pw.TextStyle(
                color: _textSub, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.Container(width: 7, height: 7,
                decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle)),
          ]),
          pw.SizedBox(height: 6),
          pw.Text(value, style: pw.TextStyle(
              color: color, fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 3),
          pw.Text(sub, style: pw.TextStyle(color: _textSub, fontSize: 8)),
        ]),
      );

  static pw.Widget _circle(double size, PdfColor color) => pw.Container(
      width: size, height: size,
      decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: color));

  static pw.Widget _chip(String label) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0x30FFFFFF),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
          border: pw.Border.all(color: PdfColor.fromInt(0x40FFFFFF))),
      child: pw.Text(label, style: pw.TextStyle(color: _surface, fontSize: 8)));

  static pw.Widget _tableHeader(String text) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(text, style: pw.TextStyle(
          color: _blue, fontSize: 9, fontWeight: pw.FontWeight.bold)));

  static pw.Widget _tableCell(String text) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(text, style: pw.TextStyle(color: _textPrimary, fontSize: 9)));

  static pw.Widget _tableCellColored(String text, PdfColor color) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(text, style: pw.TextStyle(
          color: color, fontSize: 9, fontWeight: pw.FontWeight.bold)));

  static pw.Widget _legendItem(PdfColor color, String label) =>
      pw.Row(children: [
        pw.Container(width: 10, height: 10,
            decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle)),
        pw.SizedBox(width: 6),
        pw.Text(label, style: pw.TextStyle(color: _textSub, fontSize: 9)),
      ]);

  static PdfColor _scoreColor(double s) =>
      s > 70 ? _green : s > 40 ? _orange : _red;
}