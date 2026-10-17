import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/clipboard_helper.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pulse_dot.dart';
import '../../domain/entities/copyright_claim.dart';
import '../../domain/entities/scan_result.dart';
import '../bloc/scanner_bloc.dart';
import 'result_visuals.dart';

/// Opens the scan verdict as a dialog (wide) or bottom sheet (narrow).
Future<void> showScanResult(BuildContext context) {
  final ScannerBloc bloc = context.read<ScannerBloc>();
  final Widget content = BlocProvider<ScannerBloc>.value(
    value: bloc,
    child: const ScanResultCard(inModal: true),
  );

  if (MediaQuery.sizeOf(context).width >= 720) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: content,
          ),
        ),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (BuildContext context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (BuildContext context, ScrollController controller) {
        return SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: content,
        );
      },
    ),
  );
}

Color statusColor(LicenseStatus status) => status == LicenseStatus.unauthorized
    ? AppColors.crimson
    : AppColors.emerald;

/// Full verdict: status, provenance, similarity, AI DNA and B2B actions.
class ScanResultCard extends StatelessWidget {
  const ScanResultCard({super.key, this.inModal = false});

  final bool inModal;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScannerBloc, ScannerState>(
      buildWhen: (ScannerState previous, ScannerState current) =>
          previous.result != current.result ||
          previous.claimStatus != current.claimStatus ||
          previous.claim != current.claim,
      builder: (BuildContext context, ScannerState state) {
        final ScanResult? result = state.result;
        if (result == null) return const SizedBox.shrink();
        return _ResultBody(
          result: result,
          claimStatus: state.claimStatus,
          claim: state.claim,
          inModal: inModal,
        );
      },
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.result,
    required this.claimStatus,
    required this.claim,
    required this.inModal,
  });

  final ScanResult result;
  final ClaimStatus claimStatus;
  final CopyrightClaim? claim;
  final bool inModal;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color color = statusColor(result.status);
    final bool infringement = result.isInfringement;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            _VerdictLabel(status: result.status),
            const Spacer(),
            if (inModal)
              IconButton(
                tooltip: 'Bağla',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(result.origin.school, style: text.headlineSmall),
        const SizedBox(height: 4),
        Text(
          result.origin.motif,
          style: text.titleMedium?.copyWith(color: AppColors.gold),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Widget gauge = SimilarityGauge(
              value: result.similarity,
              color: color,
            );
            final Widget facts = _FactsTable(result: result);
            if (constraints.maxWidth < 440) {
              return Column(
                children: <Widget>[gauge, const SizedBox(height: 16), facts],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                gauge,
                const SizedBox(width: 24),
                Expanded(child: facts),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        _DnaSection(result: result),
        const SizedBox(height: 16),
        _InfoStrip(
          icon: infringement
              ? Icons.travel_explore_rounded
              : Icons.workspace_premium_rounded,
          color: color,
          title: infringement ? 'Aşkarlanma mənbəyi' : 'Lisenziya sahibi',
          body: infringement
              ? '${result.matchedSource} · ${result.matchedOutputs} generasiya '
                    'eyni AI DNT-ni daşıyır'
              : result.licenseHolder ?? 'CultGuard lisenziyası',
        ),
        const SizedBox(height: 10),
        _InfoStrip(
          icon: Icons.sell_rounded,
          color: AppColors.gold,
          title: 'Təxmini B2B lisenziya dəyəri',
          body:
              '${Formatters.usd(result.licenseQuoteUsd)} · illik kommersiya istifadəsi',
        ),
        if (claim != null) ...<Widget>[
          const SizedBox(height: 10),
          _InfoStrip(
            icon: Icons.gavel_rounded,
            color: AppColors.emerald,
            title: 'İddia qeydə alındı · ${claim!.id}',
            body:
                'Cavabdeh: ${claim!.respondent} · cavab müddəti '
                '${claim!.responseDeadline.difference(claim!.filedAt).inHours} saat',
          ),
        ],
        const SizedBox(height: 22),
        _Actions(result: result, claimStatus: claimStatus, inModal: inModal),
      ],
    );
  }
}

class _VerdictLabel extends StatelessWidget {
  const _VerdictLabel({required this.status});

  final LicenseStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = statusColor(status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 18),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PulseDot(color: color, size: 9),
            const SizedBox(width: 4),
            Text(
              status.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactsTable extends StatelessWidget {
  const _FactsTable({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> rows = <(String, String)>[
      ('Mənşə', result.origin.title),
      ('Region', result.origin.region),
      ('Dövr', result.origin.era),
      ('Reyestr ID', result.origin.registryId),
      if (result.origin.recognition != null)
        ('Status', result.origin.recognition!),
      ('Skan ID', result.id),
    ];
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        for (final (String label, String value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 84,
                  child: Text(
                    label,
                    style: text.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: label.endsWith('ID')
                        ? AppTypography.mono(fontSize: 12.5)
                        : text.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DnaSection extends StatelessWidget {
  const _DnaSection({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.navyDeep,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.fingerprint_rounded,
                  size: 18,
                  color: AppColors.cyan,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI DNT barmaq izi',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Text(
                  result.fingerprint.shortHash,
                  style: AppTypography.mono(
                    fontSize: 12,
                    color: AppColors.cyan,
                  ),
                ),
                IconButton(
                  tooltip: 'Hash-i kopyala',
                  visualDensity: VisualDensity.compact,
                  iconSize: 16,
                  onPressed: () => copyWithFeedback(
                    context,
                    result.fingerprint.hash,
                    successMessage: 'AI DNT hash kopyalandı',
                  ),
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DnaBarcode(vector: result.fingerprint.vector),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: text.labelLarge?.copyWith(color: color)),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: text.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.result,
    required this.claimStatus,
    required this.inModal,
  });

  final ScanResult result;
  final ClaimStatus claimStatus;
  final bool inModal;

  void _buyLicense(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    if (inModal) Navigator.of(context).pop();
    router.go(AppRoutes.marketplace);
  }

  @override
  Widget build(BuildContext context) {
    final bool canClaim =
        result.isInfringement &&
        (claimStatus == ClaimStatus.idle || claimStatus == ClaimStatus.failed);

    final Widget claimButton = switch (claimStatus) {
      ClaimStatus.submitting => FilledButton.icon(
        onPressed: null,
        style: FilledButton.styleFrom(
          disabledBackgroundColor: AppColors.crimson.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white,
        ),
        icon: const SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
        label: const Text('İddia göndərilir...'),
      ),
      ClaimStatus.filed => FilledButton.icon(
        onPressed: null,
        style: FilledButton.styleFrom(
          disabledBackgroundColor: AppColors.emerald.withValues(alpha: 0.2),
          disabledForegroundColor: AppColors.emerald,
        ),
        icon: const Icon(Icons.check_circle_rounded, size: 18),
        label: const Text('İddia qaldırıldı'),
      ),
      ClaimStatus.idle || ClaimStatus.failed => Tooltip(
        message: result.isInfringement
            ? 'Platformaya rəsmi DMCA / müəllif hüququ bildirişi göndərilir'
            : 'Bu istifadə etibarlı lisenziya ilə əhatə olunub',
        child: FilledButton.icon(
          onPressed: canClaim
              ? () => context.read<ScannerBloc>().add(
                  const ScannerClaimRequested(),
                )
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.crimson,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.gavel_rounded, size: 18),
          label: const Text('Müəllif Hüququ İddiası Qaldır'),
        ),
      ),
    };

    final Widget licenseButton = OutlinedButton.icon(
      onPressed: () => _buyLicense(context),
      icon: const Icon(Icons.storefront_rounded, size: 18),
      label: const Text('B2B Lisenziyası Al'),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 460) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              claimButton,
              const SizedBox(height: 10),
              licenseButton,
            ],
          );
        }
        return Row(
          children: <Widget>[
            Expanded(child: claimButton),
            const SizedBox(width: 12),
            Expanded(child: licenseButton),
          ],
        );
      },
    );
  }
}
