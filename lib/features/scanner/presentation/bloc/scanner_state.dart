part of 'scanner_bloc.dart';

enum ScannerStatus { idle, ready, scanning, completed, failure }

enum ClaimStatus { idle, submitting, filed, failed }

final class ScanLogEntry extends Equatable {
  const ScanLogEntry({required this.index, required this.message});

  final int index;
  final String message;

  @override
  List<Object?> get props => <Object?>[index, message];
}

/// One-off message for the UI (snackbar). [id] makes repeats distinct.
final class ScannerNotice extends Equatable {
  const ScannerNotice({
    required this.id,
    required this.message,
    this.isError = false,
  });

  final int id;
  final String message;
  final bool isError;

  @override
  List<Object?> get props => <Object?>[id, message, isError];
}

final class ScannerState extends Equatable {
  const ScannerState({
    required this.capabilities,
    required this.samples,
    this.status = ScannerStatus.idle,
    this.media,
    this.stage,
    this.progress = 0,
    this.logs = const <ScanLogEntry>[],
    this.result,
    this.claimStatus = ClaimStatus.idle,
    this.claim,
    this.notice,
  });

  static const int maxLogLines = 40;

  final ScannerCapabilities capabilities;
  final List<ScanMedia> samples;
  final ScannerStatus status;
  final ScanMedia? media;
  final ScanStage? stage;
  final double progress;
  final List<ScanLogEntry> logs;
  final ScanResult? result;
  final ClaimStatus claimStatus;
  final CopyrightClaim? claim;
  final ScannerNotice? notice;

  bool get isScanning => status == ScannerStatus.scanning;

  ScannerState copyWith({
    ScannerStatus? status,
    ScanMedia? Function()? media,
    ScanStage? Function()? stage,
    double? progress,
    List<ScanLogEntry>? logs,
    ScanResult? Function()? result,
    ClaimStatus? claimStatus,
    CopyrightClaim? Function()? claim,
    ScannerNotice? notice,
  }) {
    return ScannerState(
      capabilities: capabilities,
      samples: samples,
      status: status ?? this.status,
      media: media != null ? media() : this.media,
      stage: stage != null ? stage() : this.stage,
      progress: progress ?? this.progress,
      logs: logs ?? this.logs,
      result: result != null ? result() : this.result,
      claimStatus: claimStatus ?? this.claimStatus,
      claim: claim != null ? claim() : this.claim,
      notice: notice ?? this.notice,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    capabilities,
    samples,
    status,
    media,
    stage,
    progress,
    logs,
    result,
    claimStatus,
    claim,
    notice,
  ];
}
