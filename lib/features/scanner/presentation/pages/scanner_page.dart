import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/navigation/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/scanner_bloc.dart';
import '../widgets/scan_progress_panel.dart';
import '../widgets/scan_result_card.dart';
import '../widgets/scan_stage_panel.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScannerBloc>(
      create: (_) => sl<ScannerBloc>(),
      child: const ScannerView(),
    );
  }
}

class ScannerView extends StatelessWidget {
  const ScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<ScannerBloc, ScannerState>>[
        BlocListener<ScannerBloc, ScannerState>(
          listenWhen: (ScannerState previous, ScannerState current) =>
              current.notice != null && previous.notice != current.notice,
          listener: (BuildContext context, ScannerState state) {
            final ScannerNotice notice = state.notice!;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: <Widget>[
                      Icon(
                        notice.isError
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_rounded,
                        color: notice.isError
                            ? AppColors.crimson
                            : AppColors.emerald,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(notice.message)),
                    ],
                  ),
                ),
              );
          },
        ),
        BlocListener<ScannerBloc, ScannerState>(
          listenWhen: (ScannerState previous, ScannerState current) =>
              previous.status != ScannerStatus.completed &&
              current.status == ScannerStatus.completed,
          listener: (BuildContext context, ScannerState state) {
            // Let the verdict stamp land before presenting the full report.
            Future<void>.delayed(const Duration(milliseconds: 700), () {
              if (context.mounted &&
                  context.read<ScannerBloc>().state.status ==
                      ScannerStatus.completed) {
                showScanResult(context);
              }
            });
          },
        ),
      ],
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool wide = constraints.maxWidth >= Breakpoints.wideContent;
          return CustomScrollView(
            slivers: <Widget>[
              SliverSafeArea(
                sliver: SliverPadding(
                  padding: Breakpoints.pagePadding(constraints.maxWidth),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: Breakpoints.maxContentWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const _ScannerHeader(),
                            const SizedBox(height: 24),
                            if (wide)
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(flex: 11, child: ScanStagePanel()),
                                  SizedBox(width: 24),
                                  Expanded(flex: 9, child: ScanProgressPanel()),
                                ],
                              )
                            else ...const <Widget>[
                              ScanStagePanel(),
                              SizedBox(height: 20),
                              ScanProgressPanel(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScannerHeader extends StatelessWidget {
  const _ScannerHeader();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'AI DNT SKANER',
          style: text.labelMedium?.copyWith(
            color: AppColors.gold,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text('Mənşə və Pozuntu Yoxlaması', style: text.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Mədəni nümunənin rəqəmsal DNT-sini çıxarın və onu qlobal AI '
          'modellərinin çıxışları ilə müqayisə edin.',
          style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
