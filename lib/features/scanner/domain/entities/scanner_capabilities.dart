import 'package:equatable/equatable.dart';

/// What the current platform can offer the scanner UI.
final class ScannerCapabilities extends Equatable {
  const ScannerCapabilities({
    required this.cameraAvailable,
    required this.maxFileSizeBytes,
    required this.imageExtensions,
    required this.audioExtensions,
  });

  final bool cameraAvailable;
  final int maxFileSizeBytes;
  final List<String> imageExtensions;
  final List<String> audioExtensions;

  @override
  List<Object?> get props => <Object?>[
    cameraAvailable,
    maxFileSizeBytes,
    imageExtensions,
    audioExtensions,
  ];
}
