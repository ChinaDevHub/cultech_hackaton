import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Stable identity colors for generative-AI platforms across the app.
abstract final class PlatformPalette {
  static const Map<String, Color> _known = <String, Color>{
    'Midjourney': AppColors.violet,
    'Suno': AppColors.amber,
    'Stable Diffusion': AppColors.cyan,
    'Stable Audio': Color(0xFF2DD4BF),
    'DALL·E': AppColors.emerald,
    'Udio': Color(0xFFEC4899),
    'Runway': Color(0xFF3B82F6),
    'Adobe Firefly': Color(0xFFF97316),
    'Leonardo AI': Color(0xFFA3E635),
    'MusicGen': Color(0xFF60A5FA),
  };

  static const List<Color> _fallback = <Color>[
    AppColors.cyan,
    AppColors.violet,
    AppColors.amber,
    AppColors.emerald,
  ];

  static Color of(String platform) {
    return _known[platform] ??
        _fallback[platform.hashCode.abs() % _fallback.length];
  }

  /// Two-letter monogram used in avatars (`Stable Diffusion` → `SD`).
  static String monogram(String platform) {
    final List<String> words = platform
        .split(RegExp(r'[\s·]+'))
        .where((String w) => w.isNotEmpty)
        .toList(growable: false);
    if (words.length >= 2) return '${words[0][0]}${words[1][0]}'.toUpperCase();
    return platform.substring(0, platform.length >= 2 ? 2 : 1).toUpperCase();
  }
}
