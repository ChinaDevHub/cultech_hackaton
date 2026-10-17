import 'package:equatable/equatable.dart';

/// The "AI DNA" of a cultural artefact: a content hash plus a compact
/// embedding vector used for similarity search.
final class AiDnaFingerprint extends Equatable {
  const AiDnaFingerprint({required this.hash, required this.vector});

  /// Hex-encoded SHA-256 over the sampled content.
  final String hash;

  /// Normalised embedding preview (values in 0 – 1).
  final List<double> vector;

  /// Human-friendly short form, e.g. `dna:7f3a9c…e21b`.
  String get shortHash =>
      'dna:${hash.substring(0, 6)}…${hash.substring(hash.length - 4)}';

  /// Deterministic 32-bit seed derived from the hash.
  int get seed => int.parse(hash.substring(0, 8), radix: 16);

  @override
  List<Object?> get props => <Object?>[hash];
}
