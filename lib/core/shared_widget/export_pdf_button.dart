import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/provider/filter_controller.dart';
import 'package:puls/core/provider/patient_provider.dart';
import 'package:intl/intl.dart';

import '../../features/dashboard/presentation/provider/q0_average_provider.dart';
import '../../features/dashboard/utils/dashboard_pdf_service.dart';

class ExportPdfButton extends ConsumerStatefulWidget {
  const ExportPdfButton({super.key});

  @override
  ConsumerState<ExportPdfButton> createState() => _ExportPdfButtonState();
}

class _ExportPdfButtonState extends ConsumerState<ExportPdfButton> {
  bool _loading = false;

  Future<void> _export() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final isgpp         = ref.read(q0AverageProvider);
      final filters       = ref.read(filterProvider);
      final patientsAsync = ref.read(filteredPatientsProvider);

      final patients = patientsAsync.when(
        data: (list) => list,
        loading: () => <PatientModel>[],
        error: (_, __) => <PatientModel>[],
      );

      final withAlert = patients
          .where((p) => p.latestVisit?.hasAlert == true)
          .length;

      String? periodeLabel;
      if (filters.periode != null) {
        final fmt = DateFormat('dd/MM/yyyy');
        periodeLabel =
        '${fmt.format(filters.periode!.start)} – ${fmt.format(filters.periode!.end)}';
      }

      final bytes = await DashboardPdfService.generateFromSupabase(ref);

      // Generation PDF


      // Telechargement via le navigateur
      final filename =
          'PULS_Dashboard_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

      final blob = html.Blob([bytes], 'application/pdf');
      final url  = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF telecharge avec succes'),
            backgroundColor: AppColors.primaryBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l export : $e'),
            backgroundColor: AppColors.primaryError,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Exporter en PDF',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _export,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _loading
                    ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryBlue,
                  ),
                )
                    : const Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 6),
                Text(
                  _loading ? 'Export...' : 'Exporter',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}