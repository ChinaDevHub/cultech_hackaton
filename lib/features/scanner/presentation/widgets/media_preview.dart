import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/ornament_paths.dart';
import '../../domain/entities/scan_media.dart';

/// Renders whatever is being scanned: a decoded image, a procedural carpet
/// for built-in samples, or a waveform for audio.
class MediaPreview extends StatefulWidget {
  const MediaPreview({super.key, required this.media});

  final ScanMedia media;

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  late List<double> _bars = _computeBars(widget.media);

  @override
  void didUpdateWidget(MediaPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.id != widget.media.id) {
      _bars = _computeBars(widget.media);
    }
  }

  /// Amplitude envelope sampled from the raw bytes (cheap: 72 buckets with a
  /// bounded number of reads each, safe to run on the UI thread).
  static List<double> _computeBars(ScanMedia media) {
    const int count = 72;
    final Uint8List? bytes = media.bytes;
    if (bytes == null || bytes.isEmpty) {
      final math.Random random = math.Random(media.id.hashCode);
      return List<double>.generate(count, (int i) {
        final double envelope = math.sin(i / count * math.pi);
        return (0.25 + 0.75 * envelope) * (0.35 + 0.65 * random.nextDouble());
      });
    }
    final int bucket = math.max(1, bytes.length ~/ count);
    final int step = math.max(1, bucket ~/ 512);
    final List<double> bars = List<double>.filled(count, 0);
    double peak = 1e-6;
    for (int b = 0; b < count; b++) {
      final int start = b * bucket;
      final int end = math.min(bytes.length, start + bucket);
      double sum = 0;
      int n = 0;
      for (int i = start; i < end; i += step) {
        sum += (bytes[i] - 128).abs();
        n++;
      }
      bars[b] = n == 0 ? 0 : sum / n;
      peak = math.max(peak, bars[b]);
    }
    return bars.map((double v) => 0.12 + 0.88 * v / peak).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ScanMedia media = widget.media;
    if (media.kind == MediaKind.audio) {
      return _AudioPreview(media: media, bars: _bars);
    }
    final Uint8List? bytes = media.bytes;
    if (bytes == null) {
      return RepaintBoundary(
        child: CustomPaint(
          painter: CarpetSamplePainter(variant: media.sampleId ?? media.id),
        ),
      );
    }
    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      cacheWidth: 1400,
      gaplessPlayback: true,
      semanticLabel: media.name,
      errorBuilder: (BuildContext context, Object error, StackTrace? _) {
        return const _UnsupportedPreview();
      },
    );
  }
}

class _AudioPreview extends StatelessWidget {
  const _AudioPreview({required this.media, required this.bars});

  final ScanMedia media;
  final List<double> bars;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: <Color>[Color(0xFF16233A), AppColors.navyDeep],
          radius: 1.1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 56),
        child: Column(
          children: <Widget>[
            const Icon(
              Icons.graphic_eq_rounded,
              color: AppColors.cyan,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              media.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.mono(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: WaveformPainter(bars: bars),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnsupportedPreview extends StatelessWidget {
  const _UnsupportedPreview();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.navyDeep,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              'Önizləmə mümkün deyil — skan yenə də işləyəcək',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  const WaveformPainter({required this.bars});

  final List<double> bars;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    final double slot = size.width / bars.length;
    final double barWidth = math.max(1.5, slot * 0.55);
    final double mid = size.height / 2;
    final Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth
      ..shader = ui.Gradient.linear(
        Offset(0, mid),
        Offset(size.width, mid),
        const <Color>[AppColors.cyan, AppColors.goldLight, AppColors.cyan],
        const <double>[0, 0.5, 1],
      );
    for (int i = 0; i < bars.length; i++) {
      final double x = i * slot + slot / 2;
      final double h = bars[i] * (size.height / 2 - 2);
      canvas.drawLine(Offset(x, mid - h), Offset(x, mid + h), paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) =>
      !identical(oldDelegate.bars, bars);
}

/// Procedural Azerbaijani carpet used as the preview of built-in samples.
class CarpetSamplePainter extends CustomPainter {
  const CarpetSamplePainter({required this.variant});

  final String variant;

  bool get _isQazax => variant.contains('qazax');

  @override
  void paint(Canvas canvas, Size size) {
    final Color field = _isQazax
        ? const Color(0xFF7F1D1D)
        : const Color(0xFF1E2A5A);
    final Color border = _isQazax
        ? const Color(0xFF1E2A5A)
        : const Color(0xFF7F1D1D);
    const Color ivory = Color(0xFFF1E4C3);
    const Color gold = AppColors.gold;

    final Rect rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = border);

    // Border band with a running row of eight-point stars.
    final double band = size.shortestSide * 0.09;
    final Paint ivoryStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = ivory;
    final Paint goldFill = Paint()..color = gold.withValues(alpha: 0.9);
    final int starsAcross = (size.width / band).floor();
    final int starsDown = (size.height / band).floor();
    for (int i = 0; i < starsAcross; i++) {
      final double x = band / 2 + i * size.width / starsAcross;
      canvas.drawPath(
        OrnamentPaths.eightPointStar(Offset(x, band / 2), band * 0.3),
        goldFill,
      );
      canvas.drawPath(
        OrnamentPaths.eightPointStar(
          Offset(x, size.height - band / 2),
          band * 0.3,
        ),
        goldFill,
      );
    }
    for (int i = 0; i < starsDown; i++) {
      final double y = band / 2 + i * size.height / starsDown;
      canvas.drawPath(
        OrnamentPaths.eightPointStar(Offset(band / 2, y), band * 0.3),
        goldFill,
      );
      canvas.drawPath(
        OrnamentPaths.eightPointStar(
          Offset(size.width - band / 2, y),
          band * 0.3,
        ),
        goldFill,
      );
    }

    final Rect inner = rect.deflate(band);
    canvas.drawRect(inner, Paint()..color = field);
    canvas.drawRect(inner.deflate(3), ivoryStroke);

    canvas.save();
    canvas.clipRect(inner.deflate(4));
    if (_isQazax) {
      // Three stacked hooked göls — the Qazax signature.
      final double radius = math.min(inner.width * 0.3, inner.height / 6.4);
      for (int i = 0; i < 3; i++) {
        final Offset c = Offset(
          inner.center.dx,
          inner.top + inner.height * (i + 0.5) / 3,
        );
        canvas.drawPath(
          OrnamentPaths.hookedMedallion(c, radius),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4
            ..color = ivory,
        );
        canvas.drawPath(
          OrnamentPaths.eightPointStar(c, radius * 0.42),
          goldFill,
        );
      }
    } else {
      // Rows of alternating butas — the Şirvan signature.
      final double cell = inner.shortestSide / 4.2;
      int row = 0;
      for (
        double y = inner.top + cell * 0.6;
        y < inner.bottom;
        y += cell, row++
      ) {
        int col = 0;
        for (
          double x = inner.left + cell * (row.isOdd ? 1.0 : 0.5);
          x < inner.right;
          x += cell, col++
        ) {
          final bool alt = (row + col).isEven;
          canvas.drawPath(
            OrnamentPaths.boteh(
              Offset(x, y),
              cell * 0.36,
              rotation: alt ? 0.25 : -0.25,
            ),
            Paint()..color = alt ? gold : ivory.withValues(alpha: 0.9),
          );
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CarpetSamplePainter oldDelegate) =>
      oldDelegate.variant != variant;
}

/// Small thumbnail for sample pickers.
class SampleThumbnail extends StatelessWidget {
  const SampleThumbnail({super.key, required this.media, this.size = 56});

  final ScanMedia media;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.square(
        dimension: size,
        child: media.kind == MediaKind.image
            ? CustomPaint(
                painter: CarpetSamplePainter(
                  variant: media.sampleId ?? media.id,
                ),
              )
            : const ColoredBox(
                color: AppColors.navyDeep,
                child: Icon(Icons.graphic_eq_rounded, color: AppColors.cyan),
              ),
      ),
    );
  }
}

/// `midjourney_buta.png · 2.4 MB`
String describeMedia(ScanMedia media) =>
    '${media.kind.label} · ${Formatters.fileSize(media.sizeInBytes)}';
