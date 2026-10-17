import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 270° radial gauge that animates up to [value] (0 – 1).
class SimilarityGauge extends StatelessWidget {
  const SimilarityGauge({
    super.key,
    required this.value,
    required this.color,
    this.size = 148,
  });

  final double value;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Oxşarlıq ${(value * 100).toStringAsFixed(1)} faiz',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value),
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double animated, Widget? _) {
          return SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _GaugePainter(value: animated, color: color),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${(animated * 100).toStringAsFixed(1)}%',
                      style: AppTypography.mono(
                        fontSize: size * 0.17,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'uyğunluq',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.value, required this.color});

  final double value;
  final Color color;

  static const double _start = math.pi * 0.75;
  static const double _sweep = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = size.width * 0.075;
    final Rect rect = (Offset.zero & size).deflate(stroke / 2 + 2);
    canvas.drawArc(
      rect,
      _start,
      _sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = AppColors.outline.withValues(alpha: 0.6),
    );
    if (value <= 0) return;
    canvas.drawArc(
      rect,
      _start,
      _sweep * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          endAngle: _sweep,
          colors: <Color>[color.withValues(alpha: 0.45), color],
          transform: const GradientRotation(_start),
        ).createShader(rect),
    );
    // Tick marks every 10%.
    final Paint tick = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    final Offset c = rect.center;
    final double r = rect.width / 2;
    for (int i = 0; i <= 10; i++) {
      final double a = _start + _sweep * i / 10;
      final Offset dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        c + dir * (r - stroke * 1.1),
        c + dir * (r - stroke * 1.6),
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}

/// The AI DNA embedding rendered as a genetic barcode.
class DnaBarcode extends StatelessWidget {
  const DnaBarcode({super.key, required this.vector, this.height = 44});

  final List<double> vector;
  final double height;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _BarcodePainter(vector)),
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  const _BarcodePainter(this.vector);

  final List<double> vector;

  @override
  void paint(Canvas canvas, Size size) {
    if (vector.isEmpty) return;
    final double slot = size.width / vector.length;
    final double mid = size.height / 2;
    final Paint paint = Paint()..strokeCap = StrokeCap.round;
    for (int i = 0; i < vector.length; i++) {
      final double v = vector[i];
      paint
        ..strokeWidth = math.max(1.5, slot * 0.6)
        ..color = Color.lerp(AppColors.cyan, AppColors.gold, v)!;
      final double h = (0.15 + 0.85 * v) * (mid - 1);
      final double x = i * slot + slot / 2;
      canvas.drawLine(Offset(x, mid - h), Offset(x, mid + h), paint);
    }
    canvas.drawLine(
      Offset(0, mid),
      Offset(size.width, mid),
      Paint()
        ..color = AppColors.navyDeep.withValues(alpha: 0.6)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_BarcodePainter oldDelegate) =>
      !identical(oldDelegate.vector, vector);
}
