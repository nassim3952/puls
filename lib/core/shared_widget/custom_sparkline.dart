import 'package:flutter/material.dart';

import '../color.dart';

class SparklinePainter extends CustomPainter {
  final List<double> data;
  const SparklinePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    const double minVal = 0;
    const double maxVal = 5;

    final linePaint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.fill;

    double xStep = size.width / (data.length - 1);

    Offset toOffset(int i) {
      final x = i * xStep;
      final y = size.height - ((data[i] - minVal) / (maxVal - minVal)) * size.height;
      return Offset(x, y.clamp(0.0, size.height));
    }

    // Fill path
    final fillPath = Path();
    fillPath.moveTo(0, size.height);
    for (int i = 0; i < data.length; i++) {
      fillPath.lineTo(toOffset(i).dx, toOffset(i).dy);
    }
    fillPath.lineTo((data.length - 1) * xStep, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Line path
    final linePath = Path();
    linePath.moveTo(toOffset(0).dx, toOffset(0).dy);
    for (int i = 1; i < data.length; i++) {
      linePath.lineTo(toOffset(i).dx, toOffset(i).dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots sur chaque point
    for (int i = 0; i < data.length; i++) {
      canvas.drawCircle(toOffset(i), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(SparklinePainter old) => old.data != data;
}
