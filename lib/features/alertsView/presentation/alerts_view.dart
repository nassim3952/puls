import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/provider/alert_provider.dart';
import 'package:intl/intl.dart';

// ─── Color palette ────────────────────────────────────────────────────────────
class AppColorss {
  static const primary = Color(0xFF10B982);
  static const primaryDark = Color(0xFF059669);
  static const primaryLight = Color(0xFFD1FAE5);
  static const bg = Color(0xFFF0FDF8);
  static const card = Colors.white;
  static const textDark = Color(0xFF0F2E22);
  static const textMid = Color(0xFF4B5563);
  static const textLight = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5F7F0);

  static const urgentBg = Color(0xFFFFF1F2);
  static const urgentText = Color(0xFFE11D48);
  static const urgentBorder = Color(0xFFFFCDD5);

  static const warningBg = Color(0xFFFFFBEB);
  static const warningText = Color(0xFFD97706);
  static const warningBorder = Color(0xFFFDE68A);

  static const infoBg = Color(0xFFEFF6FF);
  static const infoText = Color(0xFF3B82F6);
  static const infoBorder = Color(0xFFBFDBFE);
}

// ─── Alert level ──────────────────────────────────────────────────────────────
enum AlertLevel { urgent, warning, info }

// ─── Mapping PatientModel → niveau d'alerte ──────────────────────────────────
// On se base sur q0 (score satisfaction 1-5) :
// 1-2 → urgent, 3 → warning, 4-5 → info
AlertLevel _levelFromPatient(PatientModel p) {
  final score = int.tryParse(p.patientResponse.q0) ?? 5;
  if (score <= 2) return AlertLevel.urgent;
  if (score == 3) return AlertLevel.warning;
  return AlertLevel.info;
}

// ─── Vue adaptée depuis PatientModel ─────────────────────────────────────────
class _AlertView {
  final PatientModel source;

  _AlertView(this.source);

  String get patientName => '${source.firstName} ${source.lastName}';
  String get patientId => source.ipp;
  String get avatarInitials {
    final f = source.firstName.isNotEmpty ? source.firstName[0] : '';
    final l = source.lastName.isNotEmpty ? source.lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  AlertLevel get level => _levelFromPatient(source);

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

// ─── Main Screen ──────────────────────────────────────────────────────────────
class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen>
    with SingleTickerProviderStateMixin {
  AlertLevel? _filterLevel;
  late AnimationController _animController;

  // Liste locale pour gérer la suppression (dismiss) en session
  // On garde les IDs supprimés pour filtrer la liste
  final Set<String> _dismissed = {};

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<_AlertView> _applyFilters(List<PatientModel> patients) {
    return patients
        .where((p) => !_dismissed.contains(p.id))
        .map((p) => _AlertView(p))
        .where((a) => _filterLevel == null || a.level == _filterLevel)
        .toList();
  }

  int _countByLevel(List<PatientModel> patients, AlertLevel l) {
    return patients
        .where((p) => !_dismissed.contains(p.id))
        .where((p) => _levelFromPatient(p) == l)
        .length;
  }

  void _dismissAlert(String id) {
    setState(() => _dismissed.add(id));
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: AppColorss.bg,
      body: alertsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColorss.primary),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColorss.urgentText, size: 48),
              const SizedBox(height: 12),
              Text('Erreur de chargement',
                  style: const TextStyle(
                      color: AppColorss.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const SizedBox(height: 6),
              Text(err.toString(),
                  style: const TextStyle(
                      color: AppColorss.textLight, fontSize: 12)),
            ],
          ),
        ),
        data: (patients) {
          final filtered = _applyFilters(patients);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatBar(patients),
              _buildFilters(),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _AlertCard(
                    alert: filtered[i],
                    onDelete: () => _dismissAlert(filtered[i].source.id),
                    onWhatsapp: () =>
                        _showWhatsappSheet(context, filtered[i]),
                    onDetail: () => _showDetailSheet(context, filtered[i]),
                    onPlan: () => _showPlanSheet(context, filtered[i]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatBar(List<PatientModel> patients) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          _StatChip(
            label: 'Urgentes',
            count: _countByLevel(patients, AlertLevel.urgent),
            color: AppColorss.urgentText,
            bg: AppColorss.urgentBg,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Modérées',
            count: _countByLevel(patients, AlertLevel.warning),
            color: AppColorss.warningText,
            bg: AppColorss.warningBg,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Info',
            count: _countByLevel(patients, AlertLevel.info),
            color: AppColorss.infoText,
            bg: AppColorss.infoBg,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [null, AlertLevel.urgent, AlertLevel.warning, AlertLevel.info];
    final labels = ['Toutes', 'Urgentes', 'Modérées', 'Info'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (ctx, i) {
          final selected = _filterLevel == filters[i];
          return GestureDetector(
            onTap: () => setState(() => _filterLevel = filters[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColorss.primary : AppColorss.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColorss.primary : AppColorss.border,
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [
                  BoxShadow(
                      color: AppColorss.primary.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
                    : [],
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: selected ? Colors.white : AppColorss.textMid,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 64, color: AppColorss.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Aucune alerte',
              style: TextStyle(
                  color: AppColorss.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Bottom Sheets ─────────────────────────────────────────────────────────

  void _showWhatsappSheet(BuildContext context, _AlertView alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WhatsappSheet(alert: alert),
    );
  }

  void _showDetailSheet(BuildContext context, _AlertView alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(alert: alert),
    );
  }

  void _showPlanSheet(BuildContext context, _AlertView alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanSheet(alert: alert),
    );
  }
}

// ─── Alert Card ───────────────────────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final _AlertView alert;
  final VoidCallback onDelete;
  final VoidCallback onWhatsapp;
  final VoidCallback onDetail;
  final VoidCallback onPlan;

  const _AlertCard({
    required this.alert,
    required this.onDelete,
    required this.onWhatsapp,
    required this.onDetail,
    required this.onPlan,
  });

  (Color, Color, Color, IconData) get _levelStyle {
    switch (alert.level) {
      case AlertLevel.urgent:
        return (AppColorss.urgentBg, AppColorss.urgentText,
        AppColorss.urgentBorder, Icons.warning_rounded);
      case AlertLevel.warning:
        return (AppColorss.warningBg, AppColorss.warningText,
        AppColorss.warningBorder, Icons.info_outline_rounded);
      case AlertLevel.info:
        return (AppColorss.infoBg, AppColorss.infoText,
        AppColorss.infoBorder, Icons.notifications_outlined);
    }
  }

  String get _levelLabel {
    switch (alert.level) {
      case AlertLevel.urgent:
        return 'Urgent';
      case AlertLevel.warning:
        return 'Modéré';
      case AlertLevel.info:
        return 'Info';
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, borderColor, icon) = _levelStyle;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColorss.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColorss.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top: patient info + badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColorss.primary, AppColorss.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      alert.avatarInitials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            alert.patientName,
                            style: const TextStyle(
                              color: AppColorss.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          // Level badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 12, color: textColor),
                                const SizedBox(width: 4),
                                Text(_levelLabel,
                                    style: TextStyle(
                                        color: textColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${alert.patientId} · ${alert.condition}',
                        style: const TextStyle(
                            color: AppColorss.textLight, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Alert info box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.description,
                    style: const TextStyle(
                        color: AppColorss.textMid, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          // Time + actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                const Icon(Icons.schedule_outlined,
                    size: 13, color: AppColorss.textLight),
                const SizedBox(width: 4),
                Text(alert.time,
                    style: const TextStyle(
                        color: AppColorss.textLight, fontSize: 12)),
                const Spacer(),
                _ActionBtn(
                  icon: Icons.delete_outline_rounded,
                  color: AppColorss.urgentText,
                  bg: AppColorss.urgentBg,
                  onTap: onDelete,
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: const Color(0xFF25D366),
                  bg: const Color(0xFFECFDF5),
                  onTap: onWhatsapp,
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  icon: Icons.person_search_outlined,
                  color: AppColorss.infoText,
                  bg: AppColorss.infoBg,
                  onTap: onDetail,
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  icon: Icons.assignment_outlined,
                  color: AppColorss.primary,
                  bg: AppColorss.primaryLight,
                  onTap: onPlan,
                  label: "Plan",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Button ─────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  final String? label;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: label != null ? 10 : 8, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(label!,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Stat Chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bg;

  const _StatChip(
      {required this.label,
        required this.count,
        required this.color,
        required this.bg});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─── Sheet base ───────────────────────────────────────────────────────────────
class _SheetBase extends StatelessWidget {
  final Widget child;
  const _SheetBase({required this.child});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColorss.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColorss.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── WhatsApp Sheet ───────────────────────────────────────────────────────────
class _WhatsappSheet extends StatelessWidget {
  final _AlertView alert;
  const _WhatsappSheet({required this.alert});

  @override
  Widget build(BuildContext context) {
    final messages = [
      'Bonjour ${alert.source.firstName}, nous avons bien reçu votre retour. Comment vous sentez-vous aujourd\'hui ?',
      'Suite à votre signalement, votre médecin a été informé. Pouvez-vous préciser l\'intensité de vos symptômes ?',
      'Nous vous rappelons votre prochain rendez-vous. Avez-vous des questions ?',
    ];

    return _SheetBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF25D366), size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Répondre via WhatsApp',
                      style: TextStyle(
                          color: AppColorss.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  Text(alert.patientName,
                      style:
                      const TextStyle(color: AppColorss.textLight, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Messages suggérés',
              style: TextStyle(
                  color: AppColorss.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          const SizedBox(height: 12),
          ...messages.map((m) => _SuggestedMsg(text: m)),
          const SizedBox(height: 20),
          const Text('Message personnalisé',
              style: TextStyle(
                  color: AppColorss.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColorss.bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColorss.border, width: 1.5),
            ),
            child: const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Écrire un message...',
                hintStyle: TextStyle(color: AppColorss.textLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _GreenBtn(
            label: 'Envoyer sur WhatsApp',
            icon: Icons.send_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _SuggestedMsg extends StatelessWidget {
  final String text;
  const _SuggestedMsg({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColorss.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorss.border, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColorss.textMid, fontSize: 13, height: 1.4)),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColorss.primary),
        ],
      ),
    );
  }
}

// ─── Detail Sheet ─────────────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final _AlertView alert;
  const _DetailSheet({required this.alert});

  @override
  Widget build(BuildContext context) {
    return _SheetBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColorss.primary, AppColorss.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(alert.avatarInitials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.patientName,
                      style: const TextStyle(
                          color: AppColorss.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  Text(alert.patientId,
                      style: const TextStyle(
                          color: AppColorss.textLight, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle('Informations patient'),
          _InfoRow(Icons.medical_information_outlined, 'Type de visite',
              alert.source.visitType),
          _InfoRow(Icons.local_hospital_outlined, 'Service',
              alert.source.service),
          _InfoRow(Icons.science_outlined, 'Exploration',
              alert.source.exploration.isNotEmpty
                  ? alert.source.exploration
                  : 'N/A'),
          _InfoRow(Icons.calendar_today_outlined, 'Date de visite',
              alert.lastVisit),
          _InfoRow(Icons.badge_outlined, 'IPP', alert.source.ipp),
          const SizedBox(height: 20),
          _SectionTitle('Verbatim patient'),
          // On affiche q2 (point positif) et q4 (point à améliorer)
          if (alert.source.patientResponse.q2.message.isNotEmpty) ...[
            _VerbatimCard(
              icon: Icons.thumb_up_outlined,
              color: AppColorss.primary,
              bg: AppColorss.primaryLight,
              label: 'Point positif',
              message: alert.source.patientResponse.q2.message,
              classe: alert.source.patientResponse.q2.classe,
            ),
            const SizedBox(height: 10),
          ],
          if (alert.source.patientResponse.q4.message.isNotEmpty) ...[
            _VerbatimCard(
              icon: Icons.build_outlined,
              color: AppColorss.warningText,
              bg: AppColorss.warningBg,
              label: 'Point à améliorer',
              message: alert.source.patientResponse.q4.message,
              classe: alert.source.patientResponse.q4.classe,
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 20),
          _SectionTitle('Score de satisfaction'),
          const SizedBox(height: 10),
          _PainScoreBar(score: alert.painScore),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _GreenBtn(
                  label: 'WhatsApp',
                  icon: Icons.chat_bubble_outline_rounded,
                  outlined: true,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GreenBtn(
                  label: 'Plan d\'action',
                  icon: Icons.assignment_outlined,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Verbatim Card (nouveau widget pour le detail sheet) ─────────────────────
class _VerbatimCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final String label;
  final String message;
  final String classe;

  const _VerbatimCard({
    required this.icon,
    required this.color,
    required this.bg,
    required this.label,
    required this.message,
    required this.classe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  classe.replaceAll('_', ' '),
                  style: TextStyle(
                      color: color, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(
                  color: AppColorss.textMid, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

class _PainScoreBar extends StatelessWidget {
  final double score;
  const _PainScoreBar({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(10, (i) {
            final filled = i < score;
            Color c;
            if (i < 4)
              c = AppColorss.primary;
            else if (i < 7)
              c = AppColorss.warningText;
            else
              c = AppColorss.urgentText;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 3),
                height: 10,
                decoration: BoxDecoration(
                  color: filled ? c : AppColorss.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Faible',
                style:
                TextStyle(color: AppColorss.textLight, fontSize: 11)),
            Text('${score.toInt()}/10',
                style: const TextStyle(
                    color: AppColorss.urgentText,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
            const Text('Critique',
                style:
                TextStyle(color: AppColorss.textLight, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

// ─── Plan Sheet ───────────────────────────────────────────────────────────────
class _PlanSheet extends StatelessWidget {
  final _AlertView alert;
  const _PlanSheet({required this.alert});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _PlanStep(
        icon: Icons.phone_in_talk_outlined,
        color: AppColorss.urgentText,
        title: 'Appel prioritaire',
        desc: 'Contacter le patient dans les 2h pour évaluation clinique rapide.',
        delay: 'Immédiat',
      ),
      _PlanStep(
        icon: Icons.medical_services_outlined,
        color: AppColorss.warningText,
        title: 'Réévaluation médicale',
        desc: 'Programmer une consultation avec le médecin référent sous 24h.',
        delay: '< 24h',
      ),
      _PlanStep(
        icon: Icons.chat_bubble_outline_rounded,
        color: const Color(0xFF25D366),
        title: 'Message de suivi',
        desc: 'Envoyer un formulaire de réévaluation via WhatsApp.',
        delay: 'Après appel',
      ),
      _PlanStep(
        icon: Icons.monitor_heart_outlined,
        color: AppColorss.primary,
        title: 'Monitoring renforcé',
        desc:
        'Activer les alertes quotidiennes pour ce patient pendant 7 jours.',
        delay: 'Continu',
      ),
    ];

    return _SheetBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColorss.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_outlined,
                    color: AppColorss.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Plan d'action",
                        style: TextStyle(
                            color: AppColorss.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    Text(alert.patientName,
                        style: const TextStyle(
                            color: AppColorss.textLight, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColorss.urgentBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Généré par IA',
                    style: TextStyle(
                        color: AppColorss.urgentText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColorss.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColorss.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Plan suggéré basé sur : ${alert.source.visitType.toLowerCase()}, score satisfaction ${alert.source.patientResponse.q0}/5.',
                    style: const TextStyle(
                        color: AppColorss.primaryDark,
                        fontSize: 12,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle('Étapes recommandées'),
          const SizedBox(height: 12),
          ...steps
              .asMap()
              .entries
              .map((e) => _PlanStepCard(step: e.value, index: e.key + 1)),
          const SizedBox(height: 20),
          _GreenBtn(
            label: "Appliquer le plan d'action",
            icon: Icons.check_circle_outline_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 10),
          _GreenBtn(
            label: 'Régénérer le plan',
            icon: Icons.refresh_rounded,
            outlined: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _PlanStep {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final String delay;

  const _PlanStep({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.delay,
  });
}

class _PlanStepCard extends StatelessWidget {
  final _PlanStep step;
  final int index;
  const _PlanStepCard({required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColorss.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColorss.border, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
            Center(child: Icon(step.icon, color: step.color, size: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColorss.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('$index',
                          style: const TextStyle(
                              color: AppColorss.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    Text(step.title,
                        style: const TextStyle(
                            color: AppColorss.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: step.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(step.delay,
                          style: TextStyle(
                              color: step.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(step.desc,
                    style: const TextStyle(
                        color: AppColorss.textMid,
                        fontSize: 12,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(
              color: AppColorss.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 14)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColorss.primary),
          const SizedBox(width: 10),
          Text('$label : ',
              style:
              const TextStyle(color: AppColorss.textLight, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColorss.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _GreenBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  const _GreenBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: outlined
              ? null
              : const LinearGradient(
            colors: [AppColorss.primary, AppColorss.primaryDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          color: outlined ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(14),
          border: outlined
              ? Border.all(color: AppColorss.primary, width: 1.5)
              : null,
          boxShadow: outlined
              ? []
              : [
            BoxShadow(
              color: AppColorss.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: outlined ? AppColorss.primary : Colors.white),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: outlined ? AppColorss.primary : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}