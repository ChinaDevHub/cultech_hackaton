import 'package:equatable/equatable.dart';

import 'scan_media.dart';
import 'scan_result.dart';

/// Pipeline stages of an AI DNA scan, in execution order.
enum ScanStage {
  ingest,
  vectorize,
  fingerprint,
  datasetLookup,
  provenance;

  String label(MediaKind kind) {
    return switch (this) {
      ScanStage.ingest => 'Media normallaşdırılır...',
      ScanStage.vectorize =>
        kind == MediaKind.image
            ? 'Vizuallar vektorlaşdırılır...'
            : 'Spektroqram vektorlaşdırılır...',
      ScanStage.fingerprint => 'AI DNT barmaq izi hesablanır...',
      ScanStage.datasetLookup => 'Qlobal Dataset yoxlanılır...',
      ScanStage.provenance => 'Mənşə və hüquqi status təyin edilir...',
    };
  }
}

sealed class ScanUpdate extends Equatable {
  const ScanUpdate();
}

final class ScanProgressed extends ScanUpdate {
  const ScanProgressed({required this.stage, required this.progress, this.log});

  final ScanStage stage;

  /// Overall progress (0 – 1).
  final double progress;

  /// Optional console line describing what just happened.
  final String? log;

  @override
  List<Object?> get props => <Object?>[stage, progress, log];
}

final class ScanCompleted extends ScanUpdate {
  const ScanCompleted(this.result);

  final ScanResult result;

  @override
  List<Object?> get props => <Object?>[result];
}
