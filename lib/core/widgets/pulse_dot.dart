import 'package:material_ui/material_ui.dart';

/// A "live" indicator: a solid dot with an expanding, fading halo.
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, required this.color, this.size = 10});

  final Color color;
  final double size;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double extent = widget.size * 2.6;
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: extent,
        child: CustomPaint(
          painter: _PulsePainter(
            animation: _controller,
            color: widget.color,
            dotRadius: widget.size / 2,
          ),
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({
    required this.animation,
    required this.color,
    required this.dotRadius,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double t = Curves.easeOut.transform(animation.value);
    final double maxRadius = size.shortestSide / 2;
    canvas.drawCircle(
      center,
      dotRadius + (maxRadius - dotRadius) * t,
      Paint()..color = color.withValues(alpha: 0.45 * (1 - t)),
    );
    canvas.drawCircle(center, dotRadius, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dotRadius != dotRadius;
}
