import 'package:material_ui/material_ui.dart';

import '../theme/app_typography.dart';

/// Smoothly tweens between numeric values and renders them via [format].
///
/// Uses [TweenAnimationBuilder], so only the [Text] rebuilds per frame.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
  });

  final double value;
  final String Function(double value) format;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double animated, Widget? _) {
        return Text(
          format(animated),
          maxLines: 1,
          style: (style ?? const TextStyle()).copyWith(
            fontFeatures: AppTypography.tabularFigures,
          ),
        );
      },
    );
  }
}
