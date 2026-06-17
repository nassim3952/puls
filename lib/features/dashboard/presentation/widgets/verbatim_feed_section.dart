import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/patient_provider.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

enum VerbatimSentiment { positive, negative, neutral }

class VerbatimEntry {
  final String text;
  final String service;
  final DateTime date;
  final VerbatimSentiment sentiment;

  const VerbatimEntry({
    required this.text,
    required this.service,
    required this.date,
    required this.sentiment,
  });
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final verbatimEntriesProvider = Provider<AsyncValue<List<VerbatimEntry>>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);

  return patientsAsync.whenData((patients) {
    final entries = <VerbatimEntry>[];

    for (final patient in patients) {
      for (final visit in patient.visits) {
        final survey = visit.survey;
        if (survey == null) continue;

        final score = survey.qualitePriseEnCharge ?? 0;
        final sentiment = visit.hasAlert
            ? VerbatimSentiment.negative
            : score >= 4
            ? VerbatimSentiment.positive
            : score <= 2
            ? VerbatimSentiment.negative
            : VerbatimSentiment.neutral;

        void add(String? msg) {
          if (msg == null || msg.trim().isEmpty) return;
          entries.add(VerbatimEntry(
            text: msg.trim(),
            service: visit.service,
            date: visit.date,
            sentiment: sentiment,
          ));
        }

        add(survey.raconteParcours.message);
        add(survey.momentMarquant.message);
        add(survey.suggestionsAmelioration.message);
      }
    }

    entries.shuffle(Random());
    return entries;
  });
});

// ─── Public widget ────────────────────────────────────────────────────────────

class VerbatimFeedSection extends ConsumerWidget {
  const VerbatimFeedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(verbatimEntriesProvider);
    return async.when(
      loading: () => const _FeedSkeleton(),
      error: (e, _) => Center(
          child: Text('Erreur : $e',
              style: const TextStyle(color: AppColors.primaryError))),
      data: (entries) =>
      entries.isEmpty ? const _EmptyFeed() : _ScrollingFeed(entries: entries),
    );
  }
}

// ─── Scrolling feed — Ticker based, zero jank ────────────────────────────────

class _ScrollingFeed extends StatefulWidget {
  final List<VerbatimEntry> entries;
  const _ScrollingFeed({required this.entries});

  @override
  State<_ScrollingFeed> createState() => _ScrollingFeedState();
}

class _ScrollingFeedState extends State<_ScrollingFeed>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollCtrl;
  Ticker? _ticker;

  // px/sec — ajuste ici pour changer la vitesse
  static const double _speed = 18.0;
  static const double _cardHeight = 88.0;

  Duration _lastTime = Duration.zero;
  double _offset = 0;
  double _halfListHeight = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _halfListHeight = widget.entries.length * _cardHeight;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ticker = createTicker(_onTick)..start();
    });
  }

  void _onTick(Duration elapsed) {
    if (!_scrollCtrl.hasClients) return;

    final dt = _lastTime == Duration.zero
        ? 0.0
        : (elapsed - _lastTime).inMicroseconds / 1e6;
    _lastTime = elapsed;

    _offset += _speed * dt;

    // Reset silencieux au milieu (fin de la première copie)
    if (_offset >= _halfListHeight) {
      _offset -= _halfListHeight;
    }

    _scrollCtrl.jumpTo(_offset);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doubled = [...widget.entries, ...widget.entries];

    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white,
          Colors.white,
          Colors.transparent,
        ],
        stops: [0.0, 0.1, 0.9, 1.0],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: ListView.builder(
        controller: _scrollCtrl,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: doubled.length,
        itemExtent: _cardHeight,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _VerbatimCard(entry: doubled[i]),
        ),
      ),
    );
  }
}

// ─── Card sobre ───────────────────────────────────────────────────────────────

class _VerbatimCard extends StatelessWidget {
  final VerbatimEntry entry;
  const _VerbatimCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dotColor = switch (entry.sentiment) {
      VerbatimSentiment.positive => AppColors.primarySuccess,
      VerbatimSentiment.negative => AppColors.primaryError,
      VerbatimSentiment.neutral  => AppColors.primaryNeutral,
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            entry.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                entry.service.isEmpty ? '—' : entry.service,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              const Text('·',
                  style: TextStyle(color: AppColors.kTextSub, fontSize: 10)),
              const SizedBox(width: 6),
              Text(
                _relativeDate(entry.date),
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.kTextSub,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _relativeDate(DateTime d) {
    final diff = DateTime.now().difference(d).inDays;
    if (diff == 0) return "aujourd'hui";
    if (diff == 1) return 'hier';
    if (diff < 7) return 'il y a $diff j';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _FeedSkeleton extends StatefulWidget {
  const _FeedSkeleton();
  @override
  State<_FeedSkeleton> createState() => _FeedSkeletonState();
}

class _FeedSkeletonState extends State<_FeedSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Column(
        children: List.generate(
          4,
              (i) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Opacity(
                opacity: (0.3 + _ctrl.value * 0.3) - i * 0.04,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLighter,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty ────────────────────────────────────────────────────────────────────

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Aucun verbatim disponible',
        style: TextStyle(fontSize: 13, color: AppColors.kTextSub),
      ),
    );
  }
}