import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

// ─── Palette PULS ─────────────────────────────────────────────────────────────
const _blue       = PdfColor.fromInt(0xFF1E6FDB);
const _blueDark   = PdfColor.fromInt(0xFF1450A8);
const _blueLighter= PdfColor.fromInt(0xFFE8F0FB);
const _bg         = PdfColor.fromInt(0xFFF5F7FA);
const _surface    = PdfColor.fromInt(0xFFFFFFFF);
const _textPrimary= PdfColor.fromInt(0xFF1A1D23);
const _textSub    = PdfColor.fromInt(0xFF6B7280);
const _border     = PdfColor.fromInt(0xFFE5E7EB);
const _green      = PdfColor.fromInt(0xFF10B981);
const _orange     = PdfColor.fromInt(0xFFF59E0B);
const _red        = PdfColor.fromInt(0xFFEF4444);

// ─── Modèle de données ────────────────────────────────────────────────────────
class DashboardPdfData {
  final double isgppScore;
  final int    totalPatients;
  final int    patientsWithAlert;
  final String? serviceFilter;
  final String? typeFilter;
  final String? periodeLabel;
  final DateTime generatedAt;

  const DashboardPdfData({
    required this.isgppScore,
    required this.totalPatients,
    required this.patientsWithAlert,
    this.serviceFilter,
    this.typeFilter,
    this.periodeLabel,
    required this.generatedAt,
  });
}

// ─── Service ──────────────────────────────────────────────────────────────────
class DashboardPdfService {
  static Future<Uint8List> generate(DashboardPdfData d) async {
    final doc = pw.Document(
      title: 'Rapport PULS – Dashboard',
      author: 'PULS Analytics',
    );

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => _coverPage(d),
    ));

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 28),
      build: (ctx) => _indicatorsPage(d, ctx),
    ));

    return doc.save();
  }

  // ── PAGE 1 : Couverture ────────────────────────────────────────────────────
  static pw.Widget _coverPage(DashboardPdfData d) {
    final hasFilters = d.serviceFilter != null ||
        d.typeFilter != null ||
        d.periodeLabel != null;

    return pw.Stack(children: [
      // Bande bleue du haut
      pw.Positioned(top: 0, left: 0, right: 0,
          child: pw.Container(height: 380, color: _blue)),

      // Cercles décoratifs
      pw.Positioned(top: -80, right: -80,
          child: _circle(300, PdfColor.fromInt(0x18FFFFFF))),
      pw.Positioned(top: 140, right: 30,
          child: _circle(150, PdfColor.fromInt(0x12FFFFFF))),
      pw.Positioned(top: 260, left: -40,
          child: _circle(120, PdfColor.fromInt(0x10FFFFFF))),

      // Contenu zone bleue
      pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(44, 36, 44, 0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Logo + badge
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
                color: PdfColor.fromInt(0xCCFFFFFF), fontSize: 13, letterSpacing: 0.6)),
            pw.SizedBox(height: 10),
            pw.Text('Dashboard\nAnalytique', style: pw.TextStyle(
                color: _surface, fontSize: 38,
                fontWeight: pw.FontWeight.bold, lineSpacing: 6)),
            pw.SizedBox(height: 18),
            pw.Container(width: 56, height: 3,
                decoration: pw.BoxDecoration(
                    color: _surface,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)))),

            pw.SizedBox(height: 44),

            // Filtres actifs
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
                        fontWeight: pw.FontWeight.bold, letterSpacing: 0.5)),
                    pw.SizedBox(height: 8),
                    pw.Wrap(spacing: 8, runSpacing: 6, children: [
                      if (d.serviceFilter != null) _chip('Service : ${d.serviceFilter}'),
                      if (d.typeFilter != null)    _chip('Type : ${d.typeFilter}'),
                      if (d.periodeLabel != null)  _chip('Période : ${d.periodeLabel}'),
                    ]),
                  ],
                ),
              ),

            // Date de génération (toujours dans la zone bleue, en bas)
            pw.SizedBox(height: 20),
            pw.Container(height: 1, color: PdfColor.fromInt(0x30FFFFFF)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                    'Généré le ${DateFormat("dd MMMM yyyy 'à' HH:mm", 'fr_FR').format(d.generatedAt)}',
                    style: pw.TextStyle(
                        color: PdfColor.fromInt(0x99FFFFFF), fontSize: 9)),
                pw.Text('puls.app', style: pw.TextStyle(
                    color: PdfColor.fromInt(0x99FFFFFF), fontSize: 9,
                    fontStyle: pw.FontStyle.italic)),
              ],
            ),
          ],
        ),
      ),

      // KPIs en bas (zone claire)
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
                pw.Expanded(child: _kpi(
                    'ISGPP', '${d.isgppScore.toInt()}%',
                    'Satisfaction globale', _scoreColor(d.isgppScore))),
                pw.SizedBox(width: 14),
                pw.Expanded(child: _kpi(
                    'Patients', '${d.totalPatients}',
                    'Réponses collectées', _blue)),
                pw.SizedBox(width: 14),
                pw.Expanded(child: _kpi(
                    'Alertes', '${d.patientsWithAlert}',
                    'Patients à suivre',
                    d.patientsWithAlert > 0 ? _orange : _green)),
                pw.SizedBox(width: 14),
                pw.Expanded(child: _kpi(
                    'Taux alerte',
                    d.totalPatients > 0
                        ? '${((d.patientsWithAlert / d.totalPatients) * 100).toStringAsFixed(1)}%'
                        : '—',
                    'Sur la période', _blueDark)),
              ]),
            ],
          ),
        ),
      ),
    ]);
  }

  // ── PAGE 2 : Indicateurs détaillés ────────────────────────────────────────
  static pw.Widget _indicatorsPage(DashboardPdfData d, pw.Context ctx) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // En-tête de page
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Détail des indicateurs', style: pw.TextStyle(
                  fontSize: 19, fontWeight: pw.FontWeight.bold, color: _textPrimary)),
              pw.SizedBox(height: 3),
              pw.Text('Analyse qualitative du parcours patient',
                  style: pw.TextStyle(fontSize: 10, color: _textSub)),
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
        pw.Container(height: 2,
            decoration: pw.BoxDecoration(
                color: _blue,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1)))),
        pw.SizedBox(height: 22),

        // Grille 2×3
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: _indCard('ISGPP',
              'Indice de Satisfaction Globale du Parcours Patient',
              "Mesure la satisfaction globale du patient sur l'ensemble de son parcours de soins.",
              score: d.isgppScore)),
          pw.SizedBox(width: 14),
          pw.Expanded(child: _indCard('EMP',
              'Efficacité Médicale Perçue',
              "Évalue la perception du patient quant à la qualité et l'efficacité des soins prodigués.")),
        ]),
        pw.SizedBox(height: 14),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: _indCard('VQPS',
              'Vécu Qualitatif du Parcours de Soins',
              "Analyse le ressenti qualitatif du patient à travers ses verbatims sur le parcours.")),
          pw.SizedBox(width: 14),
          pw.Expanded(child: _indCard('MCR',
              'Moments Critiques & Réputation',
              "Identifie les moments clés positifs ou négatifs qui impactent la réputation de l'établissement.")),
        ]),
        pw.SizedBox(height: 14),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: _indCard('IAR',
              "Indice d'Amélioration & de Réputation",
              "Synthétise les axes d'amélioration suggérés et leur impact sur la réputation.")),
          pw.SizedBox(width: 14),
          pw.Expanded(child: _indCard('Consentement',
              'Indice de Consentement',
              "Suivi du taux de consentement des patients aux enquêtes de satisfaction.")),
        ]),

        pw.Spacer(),

        // Footer
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
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static pw.Widget _circle(double size, PdfColor color) => pw.Container(
      width: size, height: size,
      decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: color));

  static pw.Widget _chip(String label) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0x30FFFFFF),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
          border: pw.Border.all(color: PdfColor.fromInt(0x40FFFFFF))),
      child: pw.Text(label,
          style: pw.TextStyle(color: _surface, fontSize: 8)));

  static pw.Widget _kpi(String label, String value, String sub, PdfColor color) =>
      pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
            color: _surface,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            border: pw.Border.all(color: _border)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label, style: pw.TextStyle(
                  color: _textSub, fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Container(width: 7, height: 7,
                  decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle)),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(value, style: pw.TextStyle(
              color: color, fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 3),
          pw.Text(sub, style: pw.TextStyle(color: _textSub, fontSize: 8)),
        ]),
      );

  static pw.Widget _indCard(String code, String fullName, String desc,
      {double? score}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
          color: _surface,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
          border: pw.Border.all(color: _border)),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: pw.BoxDecoration(
                  color: _blueLighter,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
              child: pw.Text(code, style: pw.TextStyle(
                  color: _blue, fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ),
            if (score != null)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: pw.BoxDecoration(
                    color: _scoreColor(score),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
                child: pw.Text('${score.toInt()}%', style: pw.TextStyle(
                    color: _surface, fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ),
          ],
        ),
        pw.SizedBox(height: 9),
        pw.Text(fullName, style: pw.TextStyle(
            color: _textPrimary, fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(desc, style: pw.TextStyle(
            color: _textSub, fontSize: 8, lineSpacing: 2)),
        if (score != null) ...[
          pw.SizedBox(height: 10),
          pw.Stack(children: [
            pw.Container(
                height: 5,
                decoration: pw.BoxDecoration(
                    color: _bg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)))),
            pw.Container(
                height: 5,
                width: (595 / 2 - 44 - 28) * (score.clamp(0, 100) / 100),
                decoration: pw.BoxDecoration(
                    color: _scoreColor(score),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)))),
          ]),
        ],
      ]),
    );
  }

  static PdfColor _scoreColor(double s) =>
      s > 70 ? _green : s > 40 ? _orange : _red;
}