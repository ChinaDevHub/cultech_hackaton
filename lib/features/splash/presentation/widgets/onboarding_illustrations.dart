import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/ornament_paths.dart';

/// Base for looping illustrations; owns a repeating controller.
abstract class _LoopingIllustrationState<T extends StatefulWidget>
    extends State<T>
    with SingleTickerProviderStateMixin {
  Duration get period;

  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: period,
  )..repeat();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// Slide 1 — a heritage medallion wrapped in a rotating "AI DNA" helix.
class DnaHelixIllustration extends StatefulWidget {
  const DnaHelixIllustration({super.key});

  @override
  State<DnaHelixIllustration> createState() => _DnaHelixIllustrationState();
}

class _DnaHelixIllustrationState
    extends _LoopingIllustrationState<DnaHelixIllustration> {
  @override
  Duration get period => const Duration(seconds: 6);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _HelixPainter(controller),
      ),
    );
  }
}

class _HelixPainter extends CustomPainter {
  _HelixPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  Size? _cachedSize;
  Path _medallion = Path();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide * 0.3;
    final double phase = animation.value * math.pi * 2;
    if (_cachedSize != size) {
      _cachedSize = size;
      _medallion = OrnamentPaths.medallion(center, radius * 0.72);
    }

    canvas.drawCircle(
      center,
      radius * 1.5,
      Paint()
        ..shader = ui.Gradient.radial(center, radius * 1.5, <Color>[
          AppColors.gold.withValues(alpha: 0.14),
          AppColors.gold.withValues(alpha: 0),
        ]),
    );

    canvas.drawPath(
      _medallion,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = AppColors.gold.withValues(alpha: 0.85),
    );

    // Two interleaved strands orbiting the medallion like a DNA helix.
    const int beads = 44;
    final Paint rung = Paint()..strokeWidth = 1;
    final Paint bead = Paint();
    for (int i = 0; i < beads; i++) {
      final double a = i / beads * math.pi * 2;
      final double wave = math.sin(a * 3 + phase);
      final double r1 = radius * (1.12 + 0.12 * wave);
      final double r2 = radius * (1.12 - 0.12 * wave);
      final Offset p1 =
          center +
          Offset(math.cos(a + phase / 4), math.sin(a + phase / 4)) * r1;
      final Offset p2 =
          center +
          Offset(math.cos(a + phase / 4), math.sin(a + phase / 4)) * r2;
      final double depth = (wave + 1) / 2;
      if (i.isEven) {
        rung.color = AppColors.cyan.withValues(alpha: 0.18);
        canvas.drawLine(p1, p2, rung);
      }
      bead.color = AppColors.cyan.withValues(alpha: 0.35 + 0.65 * depth);
      canvas.drawCircle(p1, 1.6 + 1.6 * depth, bead);
      bead.color = AppColors.goldLight.withValues(
        alpha: 0.35 + 0.65 * (1 - depth),
      );
      canvas.drawCircle(p2, 1.6 + 1.6 * (1 - depth), bead);
    }
  }

  @override
  bool shouldRepaint(_HelixPainter oldDelegate) => false;
}

/// Slide 2 — radar sweep detecting infringing generative-AI platforms.
class RadarIllustration extends StatefulWidget {
  const RadarIllustration({super.key});

  @override
  State<RadarIllustration> createState() => _RadarIllustrationState();
}

class _RadarIllustrationState
    extends _LoopingIllustrationState<RadarIllustration> {
  @override
  Duration get period => const Duration(milliseconds: 3800);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _RadarPainter(controller),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  static const List<(String, double, double)> _blips =
      <(String, double, double)>[
        ('Midjourney', 0.7, 0.62),
        ('Suno', 2.3, 0.82),
        ('Stable Diffusion', 3.6, 0.48),
        ('Udio', 5.1, 0.74),
      ];

  final Map<String, TextPainter> _labels = <String, TextPainter>{};

  TextPainter _label(String text) {
    return _labels.putIfAbsent(text, () {
      return TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide * 0.42;
    final double sweep = animation.value * math.pi * 2;

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.emerald.withValues(alpha: 0.22);
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, ring);
    }
    canvas.drawLine(
      center - Offset(radius, 0),
      center + Offset(radius, 0),
      ring,
    );
    canvas.drawLine(
      center - Offset(0, radius),
      center + Offset(0, radius),
      ring,
    );

    final Rect circle = Rect.fromCircle(center: center, radius: radius);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(sweep);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(
      circle,
      -math.pi / 2.4,
      math.pi / 2.4,
      true,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2.4,
          endAngle: 0,
          colors: <Color>[
            AppColors.emerald.withValues(alpha: 0),
            AppColors.emerald.withValues(alpha: 0.35),
          ],
        ).createShader(circle),
    );
    canvas.restore();

    for (final (String name, double angle, double distance) in _blips) {
      // How long ago the sweep passed this blip (0 = just now).
      final double since = ((sweep - angle) % (math.pi * 2)) / (math.pi * 2);
      final double intensity = (1 - since).clamp(0.0, 1.0);
      final Offset position =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * distance;
      canvas.drawCircle(
        position,
        4 + 10 * intensity,
        Paint()..color = AppColors.crimson.withValues(alpha: 0.25 * intensity),
      );
      canvas.drawCircle(
        position,
        3.5,
        Paint()
          ..color = AppColors.crimson.withValues(alpha: 0.4 + 0.6 * intensity),
      );
      final TextPainter label = _label(name);
      final Offset labelOffset = position + const Offset(10, -8);
      final Rect labelRect = Rect.fromLTWH(
        labelOffset.dx - 6,
        labelOffset.dy - 3,
        label.width + 12,
        label.height + 6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(6)),
        Paint()
          ..color = AppColors.navyDeep.withValues(
            alpha: 0.85 * (0.5 + intensity / 2),
          ),
      );
      label.paint(canvas, labelOffset);
    }

    canvas.drawCircle(center, 4, Paint()..color = AppColors.emerald);
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) => false;
}

/// Slide 3 — floating dataset cards feeding a licensing API.
class LicensingIllustration extends StatefulWidget {
  const LicensingIllustration({super.key});

  @override
  State<LicensingIllustration> createState() => _LicensingIllustrationState();
}

class _LicensingIllustrationState
    extends _LoopingIllustrationState<LicensingIllustration> {
  @override
  Duration get period => const Duration(seconds: 4);

  static const List<(IconData, String, String, Color)> _cards =
      <(IconData, String, String, Color)>[
        (
          Icons.grid_on_rounded,
          'Xalça Dataseti',
          '12,400 vektor',
          AppColors.gold,
        ),
        (
          Icons.graphic_eq_rounded,
          'Muğam Korpusu',
          '840 saat audio',
          AppColors.cyan,
        ),
        (Icons.api_rounded, 'Lisenziya API', 'cg_live_••••', AppColors.emerald),
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = math.min(constraints.maxWidth * 0.8, 300);
        return AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? _) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                for (int i = 0; i < _cards.length; i++)
                  Transform.translate(
                    offset: Offset(
                      (i - 1) * 26.0,
                      (i - 1) * 74.0 +
                          math.sin(controller.value * math.pi * 2 + i * 1.4) *
                              6,
                    ),
                    child: Transform.rotate(
                      angle: (i - 1) * -0.05,
                      child: SizedBox(
                        width: width,
                        child: _FloatingCard(data: _cards[i]),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _FloatingCard extends StatelessWidget {
  const _FloatingCard({required this.data});

  final (IconData, String, String, Color) data;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String title, String subtitle, Color color) = data;
    final TextTheme text = Theme.of(context).textTheme;
    return GlassPanel(
      accent: color,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: text.titleSmall),
                Text(
                  subtitle,
                  style: text.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_rounded,
            color: AppColors.emerald,
            size: 20,
          ),
        ],
      ),
    );
  }
}
