import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/ornament_paths.dart';
import '../../domain/entities/cultural_dataset.dart';
import '../../domain/entities/license_order.dart';

Color modalityColor(DatasetModality modality) {
  return switch (modality) {
    DatasetModality.visual => AppColors.gold,
    DatasetModality.audio => AppColors.cyan,
    DatasetModality.model3d => AppColors.violet,
    DatasetModality.multimodal => AppColors.emerald,
  };
}

IconData modalityIcon(DatasetModality modality) {
  return switch (modality) {
    DatasetModality.visual => Icons.grid_on_rounded,
    DatasetModality.audio => Icons.graphic_eq_rounded,
    DatasetModality.model3d => Icons.view_in_ar_rounded,
    DatasetModality.multimodal => Icons.layers_rounded,
  };
}

class DatasetCard extends StatelessWidget {
  const DatasetCard({
    super.key,
    required this.dataset,
    required this.isPending,
    required this.order,
    required this.onLicense,
  });

  final CulturalDataset dataset;
  final bool isPending;
  final LicenseOrder? order;
  final VoidCallback onLicense;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color accent = modalityColor(dataset.modality);

    return GlassPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: SizedBox(
              height: 96,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: _BannerPainter(
                        color: accent,
                        seed: dataset.id.hashCode,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.navyDeep.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(9),
                            child: Icon(
                              modalityIcon(dataset.modality),
                              color: accent,
                              size: 22,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const _Pill(
                          icon: Icons.verified_rounded,
                          label: 'TƏSDİQLƏNİB',
                          color: AppColors.emerald,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      dataset.modality.label.toUpperCase(),
                      style: text.labelSmall?.copyWith(
                        color: accent,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      dataset.rating.toStringAsFixed(1),
                      style: text.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dataset.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: Text(
                    dataset.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    _Stat(
                      value: Formatters.thousands(dataset.itemCount),
                      label: dataset.itemUnit,
                    ),
                    const SizedBox(width: 18),
                    _Stat(value: dataset.sizeLabel, label: 'həcm'),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _Stat(
                        value: dataset.formats.first,
                        label: dataset.formats.skip(1).join(' · '),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    for (final String useCase in dataset.useCases)
                      _Pill(label: useCase, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Formatters.usd(dataset.priceUsd),
                            style: AppTypography.mono(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '/il · ${dataset.licenseType}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _LicenseButton(
                      isPending: isPending,
                      order: order,
                      onPressed: onLicense,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LicenseButton extends StatelessWidget {
  const _LicenseButton({
    required this.isPending,
    required this.order,
    required this.onPressed,
  });

  final bool isPending;
  final LicenseOrder? order;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (order != null) {
      child = OutlinedButton.icon(
        key: const ValueKey<String>('done'),
        onPressed: null,
        style: OutlinedButton.styleFrom(
          disabledForegroundColor: AppColors.emerald,
          side: const BorderSide(color: AppColors.emerald),
        ),
        icon: const Icon(Icons.check_rounded, size: 18),
        label: const Text('Sorğu göndərildi'),
      );
    } else if (isPending) {
      child = const FilledButton(
        key: ValueKey<String>('pending'),
        onPressed: null,
        child: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else {
      child = FilledButton.icon(
        key: const ValueKey<String>('idle'),
        onPressed: onPressed,
        icon: const Icon(Icons.shopping_bag_rounded, size: 18),
        label: const Text('Lisenziya al'),
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: child,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.mono(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.navyDeep.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ornamental banner: star lattice fading into a digital grid.
class _BannerPainter extends CustomPainter {
  const _BannerPainter({required this.color, required this.seed});

  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[color.withValues(alpha: 0.28), AppColors.navyDeep],
        ).createShader(rect),
    );
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.35);
    const double cell = 44;
    final double shift = (seed % 7) * 6.0;
    for (double y = -cell / 2; y < size.height + cell; y += cell) {
      for (double x = -cell + shift; x < size.width + cell; x += cell) {
        final double fade = 1 - (x / size.width).clamp(0.0, 1.0) * 0.8;
        stroke.color = color.withValues(alpha: 0.35 * fade);
        canvas.drawPath(
          OrnamentPaths.eightPointStar(Offset(x, y), cell * 0.32),
          stroke,
        );
      }
    }
    final math.Random random = math.Random(seed);
    final Paint pixel = Paint();
    for (int i = 0; i < 18; i++) {
      pixel.color = color.withValues(alpha: 0.1 + random.nextDouble() * 0.25);
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * (0.55 + random.nextDouble() * 0.45),
          size.height * random.nextDouble(),
          6,
          6,
        ),
        pixel,
      );
    }
  }

  @override
  bool shouldRepaint(_BannerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.seed != seed;
}
