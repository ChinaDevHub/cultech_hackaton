import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/scan_media.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scan_update.dart';
import '../bloc/scanner_bloc.dart';
import 'scan_result_card.dart';

/// Pipeline telemetry: overall progress, per-stage checklist and a live
/// console, followed by a compact verdict summary once complete.
class ScanProgressPanel extends StatelessWidget {
  const ScanProgressPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScannerBloc, ScannerState>(
      buildWhen: (ScannerState previous, ScannerState current) =>
          previous.status != current.status ||
          previous.stage != current.stage ||
          previous.progress != current.progress ||
          previous.logs != current.logs ||
          previous.media != current.media ||
          previous.result != current.result,
      builder: (BuildContext context, ScannerState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (state.result != null) ...<Widget>[
              FadeSlideIn(
                key: ValueKey<String>(state.result!.id),
                child: _VerdictSummary(result: state.result!),
              ),
              const SizedBox(height: 20),
            ],
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SectionHeader(
                    icon: Icons.memory_rounded,
                    title: 'Skan prosesi',
                    subtitle: _subtitle(state),
                    trailing: Text(
                      '${(state.progress * 100).round()}%',
                      style: AppTypography.mono(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: state.status == ScannerStatus.completed
                            ? AppColors.emerald
                            : AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: state.progress),
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutCubic,
                      builder: (BuildContext context, double value, Widget? _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 6,
                          backgroundColor: AppColors.navyDeep,
                          color: state.status == ScannerStatus.completed
                              ? AppColors.emerald
                              : AppColors.gold,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (final ScanStage stage in ScanStage.values)
                    _StageRow(
                      stage: stage,
                      kind: state.media?.kind ?? MediaKind.image,
                      phase: _phaseOf(stage, state),
                    ),
                  const SizedBox(height: 14),
                  _Console(logs: state.logs, active: state.isScanning),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static String _subtitle(ScannerState state) {
    return switch (state.status) {
      ScannerStatus.idle => 'Gözləmə rejimi — fayl və ya nümunə seçin',
      ScannerStatus.ready => 'Hazırdır — skanı başladın',
      ScannerStatus.scanning =>
        state.stage?.label(state.media?.kind ?? MediaKind.image) ?? '',
      ScannerStatus.completed => 'Tamamlandı — nəticə hazırdır',
      ScannerStatus.failure => 'Skan dayandırıldı',
    };
  }

  static _StagePhase _phaseOf(ScanStage stage, ScannerState state) {
    if (state.status == ScannerStatus.completed) return _StagePhase.done;
    final ScanStage? current = state.stage;
    if (current == null ||
        state.status == ScannerStatus.idle ||
        state.status == ScannerStatus.ready) {
      return _StagePhase.pending;
    }
    if (stage.index < current.index) return _StagePhase.done;
    if (stage == current) {
      return state.status == ScannerStatus.failure
          ? _StagePhase.failed
          : _StagePhase.active;
    }
    return _StagePhase.pending;
  }
}

enum _StagePhase { pending, active, done, failed }

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.kind,
    required this.phase,
  });

  final ScanStage stage;
  final MediaKind kind;
  final _StagePhase phase;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Widget indicator = switch (phase) {
      _StagePhase.pending => const Icon(
        Icons.radio_button_unchecked_rounded,
        size: 18,
        color: AppColors.textMuted,
      ),
      _StagePhase.active => const SizedBox.square(
        dimension: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
      ),
      _StagePhase.done => const Icon(
        Icons.check_circle_rounded,
        size: 18,
        color: AppColors.emerald,
      ),
      _StagePhase.failed => const Icon(
        Icons.error_rounded,
        size: 18,
        color: AppColors.crimson,
      ),
    };
    final Color labelColor = switch (phase) {
      _StagePhase.pending => AppColors.textMuted,
      _StagePhase.active => AppColors.goldLight,
      _StagePhase.done => AppColors.textPrimary,
      _StagePhase.failed => AppColors.crimson,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 22,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                  key: ValueKey<_StagePhase>(phase),
                  child: indicator,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: (text.bodyMedium ?? const TextStyle()).copyWith(
                color: labelColor,
                fontWeight: phase == _StagePhase.active
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
              child: Text(stage.label(kind)),
            ),
          ),
          if (phase == _StagePhase.done)
            Text(
              'OK',
              style: AppTypography.mono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.emerald,
              ),
            ),
        ],
      ),
    );
  }
}

class _Console extends StatelessWidget {
  const _Console({required this.logs, required this.active});

  final List<ScanLogEntry> logs;
  final bool active;

  static const int _visibleLines = 7;

  @override
  Widget build(BuildContext context) {
    final List<ScanLogEntry> visible = logs.length > _visibleLines
        ? logs.sublist(logs.length - _visibleLines)
        : logs;
    return Container(
      height: 188,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.navyDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              for (final Color c in const <Color>[
                AppColors.crimson,
                AppColors.amber,
                AppColors.emerald,
              ])
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
              const SizedBox(width: 6),
              Text(
                'cultguard-dna-engine',
                style: AppTypography.mono(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: logs.isEmpty
                ? Text(
                    active ? '› işə salınır…' : '› skan gözlənilir_',
                    style: AppTypography.mono(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  )
                : ClipRect(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        for (final ScanLogEntry entry in visible)
                          FadeSlideIn(
                            key: ValueKey<int>(entry.index),
                            duration: const Duration(milliseconds: 300),
                            offset: const Offset(0, 0.4),
                            child: Text(
                              '› ${entry.message}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.mono(
                                fontSize: 12,
                                color: entry == logs.last && active
                                    ? AppColors.cyan
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _VerdictSummary extends StatelessWidget {
  const _VerdictSummary({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color color = statusColor(result.status);
    return GlassPanel(
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                result.isInfringement
                    ? Icons.gpp_bad_rounded
                    : Icons.verified_rounded,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.status.label,
                  style: text.titleMedium?.copyWith(color: color),
                ),
              ),
              Text(
                Formatters.percent(result.similarity),
                style: AppTypography.mono(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(result.origin.title, style: text.bodyLarge),
          const SizedBox(height: 4),
          Text(
            result.isInfringement
                ? 'Aşkarlandı: ${result.matchedSource}'
                : 'Lisenziya: ${result.licenseHolder ?? '—'}',
            style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => showScanResult(context),
              icon: const Icon(Icons.open_in_full_rounded, size: 16),
              label: const Text('Ətraflı nəticə'),
            ),
          ),
        ],
      ),
    );
  }
}
