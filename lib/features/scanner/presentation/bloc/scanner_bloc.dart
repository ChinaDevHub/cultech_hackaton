import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/copyright_claim.dart';
import '../../domain/entities/scan_media.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scan_update.dart';
import '../../domain/entities/scanner_capabilities.dart';
import '../../domain/usecases/scanner_usecases.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc({
    required GetScannerCapabilities getCapabilities,
    required GetDemoSamples getDemoSamples,
    required this._pickMedia,
    required this._runScan,
    required this._fileClaim,
  }) : super(
         ScannerState(
           capabilities: getCapabilities(),
           samples: getDemoSamples(),
         ),
       ) {
    on<ScannerMediaRequested>(_onMediaRequested, transformer: droppable());
    on<ScannerSampleSelected>(_onSampleSelected);
    on<ScannerPipelineEvent>(_onPipelineEvent, transformer: restartable());
    on<ScannerClaimRequested>(_onClaimRequested, transformer: droppable());
  }

  final PickScanMedia _pickMedia;
  final RunAiDnaScan _runScan;
  final FileCopyrightClaim _fileClaim;
  int _noticeSeq = 0;

  ScannerNotice _notice(String message, {bool isError = false}) =>
      ScannerNotice(id: ++_noticeSeq, message: message, isError: isError);

  ScannerState _withMedia(ScanMedia media) {
    return ScannerState(
      capabilities: state.capabilities,
      samples: state.samples,
      status: ScannerStatus.ready,
      media: media,
      notice: state.notice,
    );
  }

  Future<void> _onMediaRequested(
    ScannerMediaRequested event,
    Emitter<ScannerState> emit,
  ) async {
    if (state.isScanning) return;
    final Result<ScanMedia?> result = await _pickMedia(event.origin);
    switch (result) {
      case Err<ScanMedia?>(:final Failure failure):
        emit(state.copyWith(notice: _notice(failure.message, isError: true)));
      case Ok<ScanMedia?>(value: null):
        return; // User cancelled the picker.
      case Ok<ScanMedia?>(:final ScanMedia value):
        if (state.isScanning) return;
        emit(_withMedia(value));
    }
  }

  void _onSampleSelected(
    ScannerSampleSelected event,
    Emitter<ScannerState> emit,
  ) {
    if (state.isScanning) return;
    emit(_withMedia(event.sample));
  }

  Future<void> _onPipelineEvent(
    ScannerPipelineEvent event,
    Emitter<ScannerState> emit,
  ) async {
    switch (event) {
      case ScannerResetRequested():
        emit(
          ScannerState(
            capabilities: state.capabilities,
            samples: state.samples,
            notice: state.notice,
          ),
        );
      case ScannerScanRequested():
        final ScanMedia? media = state.media;
        if (media == null) return;
        emit(
          state.copyWith(
            status: ScannerStatus.scanning,
            stage: () => ScanStage.ingest,
            progress: 0,
            logs: const <ScanLogEntry>[],
            result: () => null,
            claimStatus: ClaimStatus.idle,
            claim: () => null,
          ),
        );
        await emit.forEach<ScanUpdate>(
          _runScan(media),
          onData: _applyUpdate,
          onError: (Object error, StackTrace _) => state.copyWith(
            status: ScannerStatus.failure,
            notice: _notice(
              error is Failure
                  ? error.message
                  : const UnexpectedFailure().message,
              isError: true,
            ),
          ),
        );
    }
  }

  ScannerState _applyUpdate(ScanUpdate update) {
    switch (update) {
      case ScanProgressed(:final ScanStage stage, :final double progress):
        final String? log = update.log;
        List<ScanLogEntry> logs = state.logs;
        if (log != null) {
          logs = <ScanLogEntry>[
            ...logs,
            ScanLogEntry(
              index: logs.isEmpty ? 0 : logs.last.index + 1,
              message: log,
            ),
          ];
          if (logs.length > ScannerState.maxLogLines) {
            logs = logs.sublist(logs.length - ScannerState.maxLogLines);
          }
        }
        return state.copyWith(
          stage: () => stage,
          progress: progress,
          logs: List<ScanLogEntry>.unmodifiable(logs),
        );
      case ScanCompleted(:final ScanResult result):
        return state.copyWith(
          status: ScannerStatus.completed,
          progress: 1,
          result: () => result,
        );
    }
  }

  Future<void> _onClaimRequested(
    ScannerClaimRequested event,
    Emitter<ScannerState> emit,
  ) async {
    final ScanResult? result = state.result;
    if (result == null ||
        state.claimStatus == ClaimStatus.submitting ||
        state.claimStatus == ClaimStatus.filed) {
      return;
    }
    emit(state.copyWith(claimStatus: ClaimStatus.submitting));
    final Result<CopyrightClaim> outcome = await _fileClaim(result);
    switch (outcome) {
      case Ok<CopyrightClaim>(:final CopyrightClaim value):
        emit(
          state.copyWith(
            claimStatus: ClaimStatus.filed,
            claim: () => value,
            notice: _notice('Müəllif hüququ iddiası qaldırıldı · ${value.id}'),
          ),
        );
      case Err<CopyrightClaim>(:final Failure failure):
        emit(
          state.copyWith(
            claimStatus: ClaimStatus.failed,
            notice: _notice(failure.message, isError: true),
          ),
        );
    }
  }
}
