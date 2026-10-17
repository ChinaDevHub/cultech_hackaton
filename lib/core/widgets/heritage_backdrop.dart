import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import 'ornament_paths.dart';

/// Static background: a faint carpet lattice of eight-point stars woven into
/// a digital vector grid. Painted once and cached by a [RepaintBoundary].
class HeritageBackdrop extends StatelessWidget {
  const HeritageBackdrop({super.key, required this.child, this.intensity = 1});

  final Widget child;

  /// Multiplies the pattern opacity (0 – 1).
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.8, -1),
          radius: 1.6,
          colors: <Color>[Color(0xFF172238), AppColors.navy],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          RepaintBoundary(
            child: CustomPaint(painter: _LatticePainter(intensity: intensity)),
          ),
          child,
        ],
      ),
    );
  }
}

class _LatticePainter extends CustomPainter {
  const _LatticePainter({required this.intensity});

  final double intensity;

  static const double _cell = 120;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.025 * intensity)
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += _cell / 4) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y <= size.height; y += _cell / 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final Paint motif = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.gold.withValues(alpha: 0.045 * intensity);
    final Paint node = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.08 * intensity);

    int row = 0;
    for (double y = _cell / 2; y < size.height + _cell; y += _cell, row++) {
      final double offset = row.isOdd ? _cell / 2 : 0;
      for (double x = offset; x < size.width + _cell; x += _cell) {
        final Offset c = Offset(x, y);
        canvas.drawPath(OrnamentPaths.eightPointStar(c, _cell * 0.18), motif);
        canvas.drawCircle(c, 1.6, node);
      }
    }
  }

  @override
  bool shouldRepaint(_LatticePainter oldDelegate) =>
      oldDelegate.intensity != intensity;
}
