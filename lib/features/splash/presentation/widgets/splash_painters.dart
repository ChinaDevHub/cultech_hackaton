import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ornament_paths.dart';

/// Maps the global splash progress onto a sub-interval and eases it.
double _phase(
  double t,
  double begin,
  double end, [
  Curve curve = Curves.linear,
]) {
  final double local = ((t - begin) / (end - begin)).clamp(0.0, 1.0);
  return curve.transform(local);
}

/// Full-screen layer: a vector grid that radiates out from the centre,
/// flickering "pixels" and a laser scan line.
class SplashGridPainter extends CustomPainter {
  SplashGridPainter({required this.progress}) : super(repaint: progress);

  final Animation<double> progress;

  static const double _spacing = 32;

  Size? _cachedSize;
  late List<_Pixel> _pixels;

  void _prepare(Size size) {
    if (_cachedSize == size) return;
    _cachedSize = size;
    final math.Random random = math.Random(7);
    final Offset center = size.center(Offset.zero);
    final int cols = (size.width / _spacing).ceil();
    final int rows = (size.height / _spacing).ceil();
    _pixels = List<_Pixel>.generate(70, (_) {
      final Offset cell = Offset(
        random.nextInt(cols) * _spacing,
        random.nextInt(rows) * _spacing,
      );
      final double distance = (cell - center).distance;
      final double maxDistance = size.longestSide * 0.6;
      return _Pixel(
        rect: Rect.fromLTWH(
          cell.dx + 1,
          cell.dy + 1,
          _spacing - 2,
          _spacing - 2,
        ),
        appearAt: 0.12 + 0.5 * (distance / maxDistance).clamp(0.0, 1.0),
        phase: random.nextDouble() * math.pi * 2,
        color: random.nextInt(3) == 0 ? AppColors.gold : AppColors.cyan,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    _prepare(size);
    final double t = progress.value;
    final Offset center = size.center(Offset.zero);

    // 1. Radiating vector grid.
    final double reveal = _phase(t, 0, 0.45, Curves.easeOutCubic);
    if (reveal > 0) {
      final double radius = size.longestSide * 0.75 * reveal + 1;
      final Paint grid = Paint()
        ..strokeWidth = 1
        ..shader = ui.Gradient.radial(
          center,
          radius,
          <Color>[
            AppColors.cyan.withValues(alpha: 0.22),
            AppColors.cyan.withValues(alpha: 0.06),
            AppColors.cyan.withValues(alpha: 0),
          ],
          <double>[0, 0.7, 1],
        );
      for (double x = center.dx % _spacing; x <= size.width; x += _spacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      }
      for (double y = center.dy % _spacing; y <= size.height; y += _spacing) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
      }
    }

    // 2. Flickering pixels ("data being digitised").
    final Paint pixelPaint = Paint();
    for (final _Pixel pixel in _pixels) {
      if (t < pixel.appearAt) continue;
      final double life = _phase(t, pixel.appearAt, pixel.appearAt + 0.25);
      final double flicker = 0.5 + 0.5 * math.sin(pixel.phase + t * 40);
      final double fadeOut = 1 - _phase(t, 0.8, 1);
      pixelPaint.color = pixel.color.withValues(
        alpha: 0.28 * life * flicker * fadeOut,
      );
      canvas.drawRect(pixel.rect, pixelPaint);
    }

    // 3. Laser scan line sweeping top → bottom.
    final double sweep = _phase(t, 0.2, 0.85, Curves.easeInOutSine);
    if (sweep > 0 && sweep < 1) {
      final double y = size.height * sweep;
      final Rect band = Rect.fromLTWH(0, y - 90, size.width, 90);
      canvas.drawRect(
        band,
        Paint()
          ..shader =
              ui.Gradient.linear(band.topCenter, band.bottomCenter, <Color>[
                AppColors.cyan.withValues(alpha: 0),
                AppColors.cyan.withValues(alpha: 0.12),
              ]),
      );
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..strokeWidth = 1.5
          ..shader = ui.Gradient.linear(
            Offset(0, y),
            Offset(size.width, y),
            <Color>[
              AppColors.cyan.withValues(alpha: 0),
              AppColors.cyan,
              AppColors.goldLight,
              AppColors.cyan,
              AppColors.cyan.withValues(alpha: 0),
            ],
            <double>[0, 0.3, 0.5, 0.7, 1],
          ),
      );
    }

    // 4. Warm heritage glow behind the medallion.
    final double glow = _phase(t, 0.5, 1, Curves.easeOut);
    if (glow > 0) {
      canvas.drawCircle(
        center,
        size.shortestSide * 0.5,
        Paint()
          ..shader =
              ui.Gradient.radial(center, size.shortestSide * 0.5, <Color>[
                AppColors.gold.withValues(alpha: 0.16 * glow),
                AppColors.gold.withValues(alpha: 0),
              ]),
      );
    }
  }

  @override
  bool shouldRepaint(SplashGridPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Pixel {
  const _Pixel({
    required this.rect,
    required this.appearAt,
    required this.phase,
    required this.color,
  });

  final Rect rect;
  final double appearAt;
  final double phase;
  final Color color;
}

/// Traces the heritage medallion stroke-by-stroke, then overlays the
/// AI "vector nodes" network that represents its extracted DNA.
class MedallionTracePainter extends CustomPainter {
  MedallionTracePainter({required this.progress}) : super(repaint: progress);

  final Animation<double> progress;

  Size? _cachedSize;
  late Path _medallion;
  late List<ui.PathMetric> _metrics;
  late List<Offset> _nodes;
  late List<Offset> _ring;
  late double _radius;

  void _prepare(Size size) {
    if (_cachedSize == size) return;
    _cachedSize = size;
    final Offset center = size.center(Offset.zero);
    _radius = size.shortestSide * 0.36;
    _medallion = OrnamentPaths.medallion(center, _radius);
    _metrics = _medallion.computeMetrics().toList(growable: false);
    _nodes = OrnamentPaths.medallionNodes(center, _radius);
    _ring = List<Offset>.generate(24, (int i) {
      final double angle = i * math.pi * 2 / 24;
      return center + Offset(math.cos(angle), math.sin(angle)) * _radius * 1.32;
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    _prepare(size);
    final double t = progress.value;
    final Offset center = size.center(Offset.zero);
    final Rect bounds = Offset.zero & size;

    // Rotating dashed orbit.
    final double orbit = _phase(t, 0.05, 0.4, Curves.easeOut);
    if (orbit > 0) {
      final Paint dash = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.gold.withValues(alpha: 0.35 * orbit);
      final double rotation = t * math.pi / 3;
      const int segments = 48;
      for (int i = 0; i < segments; i++) {
        final double start = rotation + i * math.pi * 2 / segments;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: _radius * 1.32),
          start,
          math.pi / segments,
          false,
          dash,
        );
      }
    }

    // Progressive stroke trace of the ornament.
    final double trace = _phase(t, 0.1, 0.62, Curves.easeInOutCubic);
    if (trace > 0) {
      final Path partial = Path();
      for (final ui.PathMetric metric in _metrics) {
        partial.addPath(
          metric.extractPath(0, metric.length * trace),
          Offset.zero,
        );
      }
      canvas.drawPath(
        partial,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = AppColors.gold.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawPath(
        partial,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.goldGradient,
          ).createShader(bounds),
      );
    }

    // Soft fill once the trace completes.
    final double fill = _phase(t, 0.58, 0.8);
    if (fill > 0) {
      canvas.drawPath(
        _medallion,
        Paint()..color = AppColors.gold.withValues(alpha: 0.06 * fill),
      );
    }

    // AI vector network: ring nodes connected to the ornament vertices.
    final double network = _phase(t, 0.42, 0.82, Curves.easeOut);
    if (network > 0) {
      final Paint link = Paint()
        ..strokeWidth = 0.8
        ..color = AppColors.cyan.withValues(alpha: 0.35 * network);
      final Paint dot = Paint()
        ..color = AppColors.cyan.withValues(alpha: network);
      for (int i = 0; i < _ring.length; i++) {
        final Offset from = _ring[i];
        final Offset to = _nodes[i % _nodes.length];
        canvas.drawLine(from, Offset.lerp(from, to, network)!, link);
        canvas.drawCircle(from, 2.2, dot);
      }
      for (final Offset node in _nodes) {
        canvas.drawCircle(node, 3 * network, dot);
      }
    }
  }

  @override
  bool shouldRepaint(MedallionTracePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
