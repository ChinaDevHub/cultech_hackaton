import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/glass_panel.dart';

/// KPI card: icon, animated value, week-over-week delta and a sparkline.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.format,
    required this.unit,
    required this.icon,
    required this.accent,
    required this.delta,
    required this.trend,
    this.deltaIsPositive = true,
  });

  final String title;
  final double value;
  final String Function(double value) format;
  final String unit;
  final IconData icon;
  final Color accent;

  /// Week-over-week change ratio.
  final double delta;

  /// Whether growth is good news (false for violations).
  final bool deltaIsPositive;
  final List<double> trend;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool good = (delta >= 0) == deltaIsPositive;
    final Color deltaColor = good ? AppColors.emerald : AppColors.crimson;

    return Semantics(
      label: '$title: ${format(value)} $unit',
      child: GlassPanel(
        accent: accent,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(9),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AnimatedCounter(
                      value: value,
                      format: format,
                      style: text.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    unit,
                    style: text.titleSmall?.copyWith(color: accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Icon(
                  delta >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 16,
                  color: deltaColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${delta >= 0 ? '+' : ''}${(delta * 100).toStringAsFixed(1)}%',
                  style: text.labelMedium?.copyWith(
                    color: deltaColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'bu həftə',
                  style: text.labelSmall?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: SparklinePainter(points: trend, color: accent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  const SparklinePainter({required this.points, required this.color});

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    double min = points.first;
    double max = points.first;
    for (final double p in points) {
      if (p < min) min = p;
      if (p > max) max = p;
    }
    final double range = (max - min).abs() < 1e-9 ? 1 : max - min;
    final double dx = size.width / (points.length - 1);

    final Path line = Path();
    for (int i = 0; i < points.length; i++) {
      final Offset point = Offset(
        i * dx,
        size.height - 2 - (points[i] - min) / range * (size.height - 4),
      );
      if (i == 0) {
        line.moveTo(point.dx, point.dy);
      } else {
        final Offset previous = Offset(
          (i - 1) * dx,
          size.height - 2 - (points[i - 1] - min) / range * (size.height - 4),
        );
        final double midX = (previous.dx + point.dx) / 2;
        line.cubicTo(midX, previous.dy, midX, point.dy, point.dx, point.dy);
      }
    }

    final Path area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          <Color>[color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
        ),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(SparklinePainter oldDelegate) =>
      oldDelegate.color != color || !identical(oldDelegate.points, points);
}
