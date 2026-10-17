import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import 'ornament_paths.dart';

/// The CultGuard mark: a heraldic shield guarding an eight-point star with
/// circuit nodes — heritage protected by AI.
class CultGuardLogo extends StatelessWidget {
  const CultGuardLogo({super.key, this.size = 40, this.glow = false});

  /// Shared Hero tag so the mark can fly between splash, onboarding and shell.
  static const String heroTag = 'cultguard-logo';

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _LogoPainter(glow: glow)),
      ),
    );
  }
}

/// Logo + wordmark, used by the sidebar and page headers.
class CultGuardWordmark extends StatelessWidget {
  const CultGuardWordmark({
    super.key,
    this.logoSize = 36,
    this.showTagline = true,
    this.heroEnabled = true,
  });

  final double logoSize;
  final bool showTagline;
  final bool heroEnabled;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Widget logo = CultGuardLogo(size: logoSize);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (heroEnabled)
          Hero(tag: CultGuardLogo.heroTag, child: logo)
        else
          logo,
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'CultGuard',
                maxLines: 1,
                style: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              if (showTagline)
                Text(
                  'AI Heritage Shield',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall?.copyWith(
                    color: AppColors.gold,
                    letterSpacing: 1.6,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter({required this.glow});

  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Rect bounds = Offset.zero & size;

    final Path shield = Path()
      ..moveTo(w * 0.5, h * 0.03)
      ..lineTo(w * 0.9, h * 0.17)
      ..cubicTo(w * 0.9, h * 0.55, w * 0.78, h * 0.8, w * 0.5, h * 0.97)
      ..cubicTo(w * 0.22, h * 0.8, w * 0.1, h * 0.55, w * 0.1, h * 0.17)
      ..close();

    if (glow) {
      canvas.drawPath(
        shield,
        Paint()
          ..color = AppColors.gold.withValues(alpha: 0.45)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.12),
      );
    }

    canvas.drawPath(
      shield,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF1B2740), AppColors.navyDeep],
        ).createShader(bounds),
    );
    canvas.drawPath(
      shield,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, w * 0.045)
        ..strokeJoin = StrokeJoin.round
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.goldGradient,
        ).createShader(bounds),
    );

    final Offset center = Offset(w * 0.5, h * 0.47);
    final Path star = OrnamentPaths.eightPointStar(center, w * 0.25);
    canvas.drawPath(
      star,
      Paint()..color = AppColors.gold.withValues(alpha: 0.16),
    );
    canvas.drawPath(
      star,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, w * 0.03)
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.goldLight,
    );

    // Circuit core: the "AI DNA" node in the heart of the star.
    final Paint nodePaint = Paint()..color = AppColors.cyan;
    canvas.drawCircle(center, w * 0.055, nodePaint);
    final Paint trace = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.8)
      ..strokeWidth = math.max(0.8, w * 0.018)
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final double angle = math.pi / 4 + i * math.pi / 2;
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center + dir * w * 0.08, center + dir * w * 0.15, trace);
      canvas.drawCircle(center + dir * w * 0.16, w * 0.022, nodePaint);
    }
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => oldDelegate.glow != glow;
}
