import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

// ─── Widget animé ─────────────────────────────────────────────────────────────

class AnimatedSparkline extends StatefulWidget {
  final List<double> data;
  final Color? color;
  final Duration duration;

  const AnimatedSparkline({
    super.key,
    required this.data,
    this.color,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<AnimatedSparkline> createState() => _AnimatedSparklineState();
}

class _AnimatedSparklineState extends State<AnimatedSparkline>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    // Démarre après le premier frame pour que le widget soit bien monté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(AnimatedSparkline old) {
    super.didUpdateWidget(old);
    // Rejoue l'animation si les données changent (filtre)
    if (old.data != widget.data) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, __) => CustomPaint(
        painter: SparklinePainter(
          data: widget.data,
          color: widget.color,
          progress: _progress.value,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color? color;

  /// 0.0 → 1.0 : fraction de la courbe dessinée (animation gauche → droite)
  final double progress;

  const SparklinePainter({
    required this.data,
    this.color,
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    const double minVal = 0;
    const double maxVal = 5;
    final resolvedColor = color ?? AppColors.primaryBlue;

    final linePaint = Paint()
      ..color = resolvedColor.withValues(alpha: 0.7)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          resolvedColor.withValues(alpha: 0.15),
          resolvedColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    Offset toOffset(int i) {
      final x = i * size.width / (data.length - 1);
      final y = size.height -
          ((data[i] - minVal) / (maxVal - minVal)) * size.height;
      return Offset(x, y.clamp(0.0, size.height));
    }

    // Courbe de Bézier complète
    Path buildFullPath() {
      final path = Path();
      path.moveTo(toOffset(0).dx, toOffset(0).dy);
      for (int i = 0; i < data.length - 1; i++) {
        final p0 = toOffset(i);
        final p1 = toOffset(i + 1);
        final cpX = (p1.dx - p0.dx) * 0.35;
        path.cubicTo(
          p0.dx + cpX, p0.dy,
          p1.dx - cpX, p1.dy,
          p1.dx, p1.dy,
        );
      }
      return path;
    }

    final fullPath = buildFullPath();

    // Clip : on ne révèle que progress * width (gauche → droite)
    final revealWidth = size.width * progress;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, revealWidth, size.height));

    // Fill
    final fillPath = Path.from(fullPath)
      ..lineTo(toOffset(data.length - 1).dx, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, fillPaint);

    // Ligne
    canvas.drawPath(fullPath, linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(SparklinePainter old) =>
      old.data != data || old.color != color || old.progress != progress;
}