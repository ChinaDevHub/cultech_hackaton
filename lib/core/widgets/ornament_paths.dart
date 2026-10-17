import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

/// Vector geometry of classic Azerbaijani carpet motifs.
///
/// All builders are pure and allocation-only, so painters can cache the
/// returned [Path]s and reuse them across frames.
abstract final class OrnamentPaths {
  /// Səkkizguşə — the eight-pointed star formed by two overlapping squares.
  static Path eightPointStar(Offset center, double radius) {
    final double inner = radius * math.cos(math.pi / 4) / math.cos(math.pi / 8);
    final Path path = Path();
    for (int i = 0; i < 16; i++) {
      final double angle = -math.pi / 2 + i * math.pi / 8;
      final double r = i.isEven ? radius : inner;
      final Offset point =
          center + Offset(math.cos(angle), math.sin(angle)) * r;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  /// Göl — the rhombic medallion with stepped "qarmaq" hooks on each edge,
  /// typical of the Qazax and Qarabağ schools.
  static Path hookedMedallion(Offset center, double radius) {
    final Path path = Path();
    final List<Offset> corners = <Offset>[
      center + Offset(0, -radius),
      center + Offset(radius, 0),
      center + Offset(0, radius),
      center + Offset(-radius, 0),
    ];
    path.addPolygon(corners, true);

    final double hook = radius * 0.16;
    for (int i = 0; i < 4; i++) {
      final Offset a = corners[i];
      final Offset b = corners[(i + 1) % 4];
      final Offset mid = Offset.lerp(a, b, 0.5)!;
      final Offset edge = b - a;
      final Offset normal =
          Offset(edge.dy, -edge.dx) / edge.distance; // points outward
      final Offset tangent = edge / edge.distance;
      final Offset tip = mid + normal * hook;
      path
        ..moveTo(mid.dx, mid.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(tip.dx + tangent.dx * hook, tip.dy + tangent.dy * hook)
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - tangent.dx * hook, tip.dy - tangent.dy * hook);
    }

    final double innerRadius = radius * 0.78;
    path.addPolygon(<Offset>[
      center + Offset(0, -innerRadius),
      center + Offset(innerRadius, 0),
      center + Offset(0, innerRadius),
      center + Offset(-innerRadius, 0),
    ], true);
    return path;
  }

  /// Buta (boteh) — the teardrop/paisley motif of the Şirvan school, with an
  /// inner echo line. [rotation] is in radians, `0` points the tip upwards.
  static Path boteh(Offset center, double size, {double rotation = 0}) {
    Path teardrop(double s) {
      return Path()
        ..moveTo(0, 0.62 * s)
        ..cubicTo(
          -0.62 * s,
          0.6 * s,
          -0.66 * s,
          -0.12 * s,
          -0.18 * s,
          -0.42 * s,
        )
        ..cubicTo(0.08 * s, -0.6 * s, 0.34 * s, -0.66 * s, 0.24 * s, -0.98 * s)
        ..cubicTo(0.62 * s, -0.62 * s, 0.6 * s, 0.6 * s, 0, 0.62 * s)
        ..close();
    }

    final Path combined = Path()
      ..addPath(teardrop(size), Offset.zero)
      ..addPath(teardrop(size * 0.58), Offset(0, size * 0.12))
      ..addOval(
        Rect.fromCircle(center: Offset(0, size * 0.2), radius: size * 0.08),
      );

    final Float64List matrix = Float64List.fromList(<double>[
      math.cos(rotation), math.sin(rotation), 0, 0, //
      -math.sin(rotation), math.cos(rotation), 0, 0, //
      0, 0, 1, 0, //
      center.dx, center.dy, 0, 1, //
    ]);
    // Even-odd fill turns the inner echo into a negative-space outline, the
    // way butas are woven, while strokes are unaffected.
    return combined.transform(matrix)..fillType = PathFillType.evenOdd;
  }

  /// Full heritage medallion used by the splash screen, logo and samples:
  /// hooked göl + eight-point star + four butas on the diagonals.
  static Path medallion(Offset center, double radius) {
    final Path path = Path()
      ..addPath(hookedMedallion(center, radius), Offset.zero)
      ..addPath(eightPointStar(center, radius * 0.5), Offset.zero)
      ..addPath(eightPointStar(center, radius * 0.24), Offset.zero);
    for (int i = 0; i < 4; i++) {
      final double angle = -math.pi / 4 + i * math.pi / 2;
      final Offset position =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.92;
      path.addPath(
        boteh(position, radius * 0.26, rotation: angle + math.pi / 2),
        Offset.zero,
      );
    }
    return path;
  }

  /// Key vertices of [medallion] — used to anchor "vector node" overlays.
  static List<Offset> medallionNodes(Offset center, double radius) {
    final List<Offset> nodes = <Offset>[];
    for (int i = 0; i < 8; i++) {
      final double angle = -math.pi / 2 + i * math.pi / 4;
      nodes.add(
        center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.5,
      );
    }
    for (int i = 0; i < 4; i++) {
      final double angle = -math.pi / 2 + i * math.pi / 2;
      nodes.add(center + Offset(math.cos(angle), math.sin(angle)) * radius);
    }
    return nodes;
  }
}
