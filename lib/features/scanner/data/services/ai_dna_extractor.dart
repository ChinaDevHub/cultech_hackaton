import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/ai_dna_fingerprint.dart';
import '../../domain/entities/scan_media.dart';

/// Extracts the AI DNA fingerprint of a media file.
///
/// The heavy lifting (hashing + embedding) runs in a background isolate via
/// [compute] so multi-megabyte files never block the UI thread. On the web,
/// where isolates are unavailable, the work is bounded by sampling at most
/// [maxSampledBytes] so it stays within a single frame budget or two.
class AiDnaExtractor {
  const AiDnaExtractor();

  static const int vectorDimensions = 48;
  static const int maxSampledBytes = 1 << 20; // 1 MiB

  /// Below this size spawning an isolate costs more than the work itself.
  static const int isolateThresholdBytes = 64 * 1024;

  Future<AiDnaFingerprint> extract(ScanMedia media) async {
    final Uint8List data =
        media.bytes ??
        Uint8List.fromList(utf8.encode('${media.sampleId}:${media.name}'));
    if (data.length < isolateThresholdBytes) return extractFingerprint(data);
    return compute(extractFingerprint, data, debugLabel: 'ai-dna-extract');
  }
}

/// Top-level so it can be sent to an isolate.
@visibleForTesting
AiDnaFingerprint extractFingerprint(Uint8List data) {
  final Uint8List sampled = _sample(data, AiDnaExtractor.maxSampledBytes);
  final Digest digest = sha256.convert(sampled);

  // Embedding preview: per-bucket mean energy blended with the digest so
  // that both global structure and fine detail influence the vector.
  const int dims = AiDnaExtractor.vectorDimensions;
  final List<double> vector = List<double>.filled(dims, 0);
  if (sampled.isNotEmpty) {
    final int bucket = (sampled.length / dims).ceil();
    for (int d = 0; d < dims; d++) {
      final int start = d * bucket;
      if (start >= sampled.length) break;
      final int end = (start + bucket).clamp(0, sampled.length);
      int sum = 0;
      for (int i = start; i < end; i++) {
        sum += sampled[i];
      }
      final double mean = sum / (end - start) / 255;
      final double detail = digest.bytes[d % digest.bytes.length] / 255;
      vector[d] = (0.55 * mean + 0.45 * detail).clamp(0.0, 1.0);
    }
  }

  return AiDnaFingerprint(
    hash: digest.toString(),
    vector: List<double>.unmodifiable(vector),
  );
}

/// Uniformly samples up to [maxBytes] from [data] in fixed-size chunks.
Uint8List _sample(Uint8List data, int maxBytes) {
  if (data.length <= maxBytes) return data;
  const int chunk = 4096;
  final int chunks = maxBytes ~/ chunk;
  final int stride = (data.length - chunk) ~/ (chunks - 1);
  final BytesBuilder builder = BytesBuilder(copy: false);
  for (int i = 0; i < chunks; i++) {
    final int offset = i * stride;
    builder.add(Uint8List.sublistView(data, offset, offset + chunk));
  }
  return builder.takeBytes();
}
