import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/dashed_border.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../domain/entities/scan_media.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scanner_capabilities.dart';
import '../bloc/scanner_bloc.dart';
import 'laser_scan_overlay.dart';
import 'media_preview.dart';
import 'scan_result_card.dart';

/// Left-hand "scanner bed": source picker, media preview, laser HUD and the
/// primary scan controls.
class ScanStagePanel extends StatelessWidget {
  const ScanStagePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScannerBloc, ScannerState>(
      buildWhen: (ScannerState previous, ScannerState current) =>
          previous.media != current.media ||
          previous.status != current.status ||
          previous.progress != current.progress ||
          previous.result != current.result,
      builder: (BuildContext context, ScannerState state) {
        final ScanMedia? media = state.media;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          child: media == null
              ? _SourcePicker(
                  key: const ValueKey<String>('picker'),
                  capabilities: state.capabilities,
                  samples: state.samples,
                )
              : _MediaStage(
                  key: const ValueKey<String>('stage'),
                  state: state,
                  media: media,
                ),
        );
      },
    );
  }
}

class _SourcePicker extends StatelessWidget {
  const _SourcePicker({
    super.key,
    required this.capabilities,
    required this.samples,
  });

  final ScannerCapabilities capabilities;
  final List<ScanMedia> samples;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ScannerBloc bloc = context.read<ScannerBloc>();
    final String formats =
        '${capabilities.imageExtensions.take(4).map((String e) => e.toUpperCase()).join(', ')} · '
        '${capabilities.audioExtensions.take(4).map((String e) => e.toUpperCase()).join(', ')} · '
        'maks. ${capabilities.maxFileSizeBytes ~/ (1024 * 1024)} MB';

    return GlassPanel(
      padding: const EdgeInsets.all(14),
      child: DashedBorder(
        color: AppColors.gold.withValues(alpha: 0.45),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          child: Column(
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.cloud_upload_rounded,
                  color: AppColors.gold,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Mədəni nümunəni yükləyin',
                textAlign: TextAlign.center,
                style: text.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Xalça naxışı, ornament fotosu və ya muğam/musiqi faylı — '
                'AI DNT qlobal modellərin çıxışları ilə müqayisə olunacaq.',
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formats,
                textAlign: TextAlign.center,
                style: AppTypography.mono(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: () => bloc.add(
                      const ScannerMediaRequested(MediaOrigin.gallery),
                    ),
                    icon: const Icon(Icons.image_rounded, size: 18),
                    label: Text(
                      capabilities.cameraAvailable ? 'Qalereya' : 'Şəkil seç',
                    ),
                  ),
                  if (capabilities.cameraAvailable)
                    OutlinedButton.icon(
                      onPressed: () => bloc.add(
                        const ScannerMediaRequested(MediaOrigin.camera),
                      ),
                      icon: const Icon(Icons.photo_camera_rounded, size: 18),
                      label: const Text('Kamera'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => bloc.add(
                      const ScannerMediaRequested(MediaOrigin.audioFile),
                    ),
                    icon: const Icon(Icons.audio_file_rounded, size: 18),
                    label: const Text('Audio seç'),
                  ),
                ],
              ),
              if (!capabilities.cameraAvailable) ...<Widget>[
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        kIsWeb
                            ? 'Veb versiyada kamera əvəzinə fayl seçimi istifadə olunur.'
                            : 'Bu platformada kamera əvəzinə fayl seçimi istifadə olunur.',
                        style: text.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 26),
              Row(
                children: <Widget>[
                  const Expanded(child: Divider()),
                  Flexible(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'və ya demo nümunə ilə sınayın',
                        textAlign: TextAlign.center,
                        style: text.labelMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 14),
              for (final ScanMedia sample in samples)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SampleTile(
                    sample: sample,
                    onTap: () => bloc.add(ScannerSampleSelected(sample)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SampleTile extends StatelessWidget {
  const _SampleTile({required this.sample, required this.onTap});

  final ScanMedia sample;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Material(
      color: AppColors.navyDeep.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              SampleThumbnail(media: sample, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      sample.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.mono(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      describeMedia(sample),
                      style: text.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaStage extends StatelessWidget {
  const _MediaStage({super.key, required this.state, required this.media});

  final ScannerState state;
  final ScanMedia media;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ScannerBloc bloc = context.read<ScannerBloc>();
    final ScanResult? result = state.result;
    final bool scanning = state.isScanning;

    return GlassPanel(
      padding: const EdgeInsets.all(14),
      accent: result == null ? null : statusColor(result.status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  MediaPreview(media: media),
                  LaserScanOverlay(
                    active: scanning,
                    progress: state.progress,
                    seed: media.id.hashCode,
                  ),
                  if (result != null) _VerdictStamp(result: result),
                  Positioned(
                    left: 12,
                    top: 12,
                    right: 12,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: _MediaChip(media: media),
                    ),
                  ),
                  if (scanning)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: _ScanningBanner(progress: state.progress),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: <Widget>[
              if (scanning)
                OutlinedButton.icon(
                  onPressed: () => bloc.add(const ScannerResetRequested()),
                  icon: const Icon(Icons.stop_rounded, size: 18),
                  label: const Text('Dayandır'),
                )
              else if (result != null) ...<Widget>[
                OutlinedButton.icon(
                  onPressed: () => bloc.add(const ScannerResetRequested()),
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: const Text('Yeni skan'),
                ),
                FilledButton.icon(
                  onPressed: () => showScanResult(context),
                  icon: const Icon(Icons.assignment_rounded, size: 18),
                  label: const Text('Nəticəni aç'),
                ),
              ] else ...<Widget>[
                OutlinedButton.icon(
                  onPressed: () => bloc.add(const ScannerResetRequested()),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('Faylı dəyiş'),
                ),
                FilledButton.icon(
                  onPressed: () => bloc.add(const ScannerScanRequested()),
                  icon: const Icon(Icons.radar_rounded, size: 18),
                  label: Text(
                    state.status == ScannerStatus.failure
                        ? 'Yenidən skan et'
                        : 'AI DNT Skanını Başlat',
                    style: text.labelLarge?.copyWith(color: AppColors.navyDeep),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaChip extends StatelessWidget {
  const _MediaChip({required this.media});

  final ScanMedia media;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.navyDeep.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              media.kind == MediaKind.image
                  ? Icons.image_outlined
                  : Icons.audiotrack_rounded,
              size: 14,
              color: AppColors.gold,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                media.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.mono(fontSize: 11.5),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              describeMedia(media),
              style: AppTypography.mono(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanningBanner extends StatelessWidget {
  const _ScanningBanner({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.navyDeep.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.cyan,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'AI DNT çıxarılır',
                style: AppTypography.mono(fontSize: 12, color: AppColors.cyan),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: AppTypography.mono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rubber-stamp verdict that lands on the media when a scan completes.
class _VerdictStamp extends StatelessWidget {
  const _VerdictStamp({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final Color color = statusColor(result.status);
    final bool infringement = result.isInfringement;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.elasticOut,
      builder: (BuildContext context, double t, Widget? child) {
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(scale: 1.6 - 0.6 * t, child: child),
        );
      },
      child: ColoredBox(
        color: AppColors.navyDeep.withValues(alpha: 0.35),
        child: Center(
          child: Transform.rotate(
            angle: -0.12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.navyDeep.withValues(alpha: 0.75),
                border: Border.all(color: color, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      infringement ? 'POZUNTU' : 'LİSENZİYALI',
                      style: AppTypography.mono(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: 3,
                      ),
                    ),
                    Text(
                      '${(result.similarity * 100).toStringAsFixed(1)}% · ${result.origin.registryId}',
                      style: AppTypography.mono(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
