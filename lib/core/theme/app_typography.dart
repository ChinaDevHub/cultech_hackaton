import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Typography helpers that complement the Material [TextTheme].
abstract final class AppTypography {
  static const String monoFamily = 'JetBrainsMono';

  /// Monospaced style for API keys, hashes, console logs and code snippets.
  ///
  /// The bundled font is variable, so the weight is applied through
  /// [FontVariation] in addition to [FontWeight] for platforms that map it.
  static TextStyle mono({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0,
    double height = 1.5,
  }) {
    return TextStyle(
      fontFamily: monoFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontVariations: <FontVariation>[
        FontVariation.weight(fontWeight.value.toDouble()),
      ],
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static const List<FontFeature> tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];
}
