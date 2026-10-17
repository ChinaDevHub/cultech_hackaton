import 'dart:typed_data';

import 'package:cultech_hackaton/features/scanner/data/services/ai_dna_extractor.dart';
import 'package:cultech_hackaton/features/scanner/domain/entities/ai_dna_fingerprint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('extractFingerprint', () {
    test('is deterministic and produces a bounded vector', () {
      final Uint8List data = Uint8List.fromList(
        List<int>.generate(5000, (int i) => i % 251),
      );
      final AiDnaFingerprint a = extractFingerprint(data);
      final AiDnaFingerprint b = extractFingerprint(Uint8List.fromList(data));

      expect(a.hash, b.hash);
      expect(a.hash, hasLength(64));
      expect(a.vector, hasLength(AiDnaExtractor.vectorDimensions));
      expect(a.vector.every((double v) => v >= 0 && v <= 1), isTrue);
      expect(a.shortHash, startsWith('dna:'));
    });

    test('different content yields a different DNA', () {
      final AiDnaFingerprint a = extractFingerprint(
        Uint8List.fromList(<int>[1, 2, 3]),
      );
      final AiDnaFingerprint b = extractFingerprint(
        Uint8List.fromList(<int>[3, 2, 1]),
      );
      expect(a.hash, isNot(b.hash));
    });

    test('samples very large inputs instead of hashing everything', () {
      final Uint8List large = Uint8List(AiDnaExtractor.maxSampledBytes * 4);
      for (int i = 0; i < large.length; i += 997) {
        large[i] = i % 256;
      }
      final Stopwatch watch = Stopwatch()..start();
      final AiDnaFingerprint fingerprint = extractFingerprint(large);
      watch.stop();
      expect(fingerprint.vector, hasLength(AiDnaExtractor.vectorDimensions));
      expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
    });
  });
}
