import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Elevated surface with a hairline gradient border — the base container for
/// every card in the app.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.accent,
    this.radius = AppTheme.radiusMd,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Optional accent color that tints the top edge of the border.
  final Color? accent;
  final double radius;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    final Color edge = accent ?? AppColors.outline;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            edge.withValues(alpha: accent == null ? 0.7 : 0.55),
            AppColors.outline.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius - 1),
            gradient:
                gradient ??
                const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xF21B263B), Color(0xF2131C2E)],
                ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
