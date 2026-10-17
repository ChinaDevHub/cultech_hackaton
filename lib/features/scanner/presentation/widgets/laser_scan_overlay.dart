import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';

/// Laser-scan HUD drawn over the media while the AI DNA is extracted:
/// a sweeping laser line, a vector grid and a growing node network whose
/// density follows the pipeline [progress].
class LaserScanOverlay extends StatefulWidget {
  const LaserScanOverlay({
    super.key,
    required this.active,
    required this.progress,
    this.accent = AppColors.cyan,
    this.seed = 1,
  });

  final bool active;
  final double progress;
  final Color accent;
  final int seed;

  @override
  State<LaserScanOverlay> createState() => _LaserScanOverlayState();
}

class _LaserScanOverlayState extends State<LaserScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _laser = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(LaserScanOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _sync();
  }

  void _sync() {
    if (widget.active) {
      _laser.repeat(reverse: true);
    } else {
      _laser.stop();
    }
  }

  @override
  void dispose() {
    _laser.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _LaserPainter(
            laser: _laser,
            active: widget.active,
            progress: widget.progress,
            accent: widget.accent,
            seed: widget.seed,
          ),
        ),
      ),
    );
  }
}

class _LaserPainter extends CustomPainter {
  _LaserPainter({
    required this.laser,
    required this.active,
    required this.progress,
    required this.accent,
    required this.seed,
  }) : super(repaint: laser);

  final Animation<double> laser;
  final bool active;
  final double progress;
  final Color accent;
  final int seed;

  static const int _maxNodes = 54;

  Size? _nodesSize;
  List<Offset> _nodes = const <Offset>[];

  List<Offset> _nodesFor(Size size) {
    if (_nodesSize == size) return _nodes;
    _nodesSize = size;
    final math.Random random = math.Random(seed);
    return _nodes = List<Offset>.generate(_maxNodes, (_) {
      return Offset(
        size.width * (0.08 + random.nextDouble() * 0.84),
        size.height * (0.08 + random.nextDouble() * 0.84),
      );
    }, growable: false);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBrackets(canvas, size);
    if (!active) return;

    // Dimming veil + vector grid.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.navyDeep.withValues(alpha: 0.25),
    );
    final Paint grid = Paint()
      ..color = accent.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    const double spacing = 28;
    for (double x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Node network that densifies as the vectorisation advances.
    final int visible = (_maxNodes * progress.clamp(0.0, 1.0)).round();
    final List<Offset> nodes = _nodesFor(size);
    final Paint link = Paint()
      ..strokeWidth = 0.8
      ..color = accent.withValues(alpha: 0.35);
    final Paint dot = Paint()..color = accent;
    final Paint halo = Paint()..color = accent.withValues(alpha: 0.18);
    for (int i = 0; i < visible; i++) {
      if (i > 0) canvas.drawLine(nodes[i], nodes[i - 1], link);
      if (i > 2 && i.isEven) canvas.drawLine(nodes[i], nodes[i - 3], link);
      canvas.drawCircle(nodes[i], 6, halo);
      canvas.drawCircle(nodes[i], 2.2, dot);
    }

    // Sweeping laser with a trailing glow.
    final double t = Curves.easeInOutSine.transform(laser.value);
    final double y = size.height * t;
    final bool goingDown = laser.status == AnimationStatus.forward;
    const double glow = 70;
    final Rect trail = goingDown
        ? Rect.fromLTRB(0, y - glow, size.width, y)
        : Rect.fromLTRB(0, y, size.width, y + glow);
    canvas.drawRect(
      trail,
      Paint()
        ..shader = ui.Gradient.linear(
          goingDown ? trail.topCenter : trail.bottomCenter,
          goingDown ? trail.bottomCenter : trail.topCenter,
          <Color>[accent.withValues(alpha: 0), accent.withValues(alpha: 0.28)],
        ),
    );
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..strokeWidth = 4
        ..color = accent.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..strokeWidth = 1.6
        ..shader = ui.Gradient.linear(
          Offset(0, y),
          Offset(size.width, y),
          <Color>[
            accent.withValues(alpha: 0.2),
            Colors.white,
            accent.withValues(alpha: 0.2),
          ],
          const <double>[0, 0.5, 1],
        ),
    );
  }

  void _drawBrackets(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = active ? accent : AppColors.gold.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final double arm = math.min(size.shortestSide * 0.12, 34);
    const double inset = 14;
    final List<(Offset, Offset, Offset)> corners = <(Offset, Offset, Offset)>[
      (const Offset(inset, inset), const Offset(1, 0), const Offset(0, 1)),
      (
        Offset(size.width - inset, inset),
        const Offset(-1, 0),
        const Offset(0, 1),
      ),
      (
        Offset(inset, size.height - inset),
        const Offset(1, 0),
        const Offset(0, -1),
      ),
      (
        Offset(size.width - inset, size.height - inset),
        const Offset(-1, 0),
        const Offset(0, -1),
      ),
    ];
    for (final (Offset corner, Offset h, Offset v) in corners) {
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx + h.dx * arm, corner.dy + h.dy * arm)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx + v.dx * arm, corner.dy + v.dy * arm),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LaserPainter oldDelegate) =>
      oldDelegate.active != active ||
      oldDelegate.progress != progress ||
      oldDelegate.accent != accent ||
      oldDelegate.seed != seed;
}
