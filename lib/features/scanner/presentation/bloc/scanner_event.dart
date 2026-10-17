part of 'scanner_bloc.dart';

sealed class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ScannerMediaRequested extends ScannerEvent {
  const ScannerMediaRequested(this.origin);

  final MediaOrigin origin;

  @override
  List<Object?> get props => <Object?>[origin];
}

final class ScannerSampleSelected extends ScannerEvent {
  const ScannerSampleSelected(this.sample);

  final ScanMedia sample;

  @override
  List<Object?> get props => <Object?>[sample];
}

/// Events that control the scan pipeline. They share one `restartable`
/// handler, so a reset immediately cancels an in-flight scan.
sealed class ScannerPipelineEvent extends ScannerEvent {
  const ScannerPipelineEvent();
}

final class ScannerScanRequested extends ScannerPipelineEvent {
  const ScannerScanRequested();
}

final class ScannerResetRequested extends ScannerPipelineEvent {
  const ScannerResetRequested();
}

final class ScannerClaimRequested extends ScannerEvent {
  const ScannerClaimRequested();
}
