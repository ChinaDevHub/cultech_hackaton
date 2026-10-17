import 'dart:async';
import 'dart:math' as math;

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/ai_dna_fingerprint.dart';
import '../../domain/entities/copyright_claim.dart';
import '../../domain/entities/scan_media.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scan_update.dart';
import '../services/ai_dna_extractor.dart';
import 'demo_samples.dart';
import 'heritage_catalog.dart';
import 'scanner_data_source.dart';

/// Offline AI DNA engine.
///
/// The fingerprint is computed for real (SHA-256 + embedding in an isolate);
/// the global-dataset lookup is simulated deterministically from that
/// fingerprint, so the same file always yields the same verdict.
final class ScannerDemoDataSource implements ScannerDataSource {
  ScannerDemoDataSource({
    this._extractor = const AiDnaExtractor(),
    this.stepDelay = const Duration(milliseconds: 430),
    DateTime Function()? clock,
    math.Random? random,
  }) : _clock = clock ?? DateTime.now,
       _random = random ?? math.Random();

  final AiDnaExtractor _extractor;
  final DateTime Function() _clock;
  final math.Random _random;

  /// Pacing between pipeline steps so each stage is readable on screen.
  final Duration stepDelay;

  Future<void> _pause() => Future<void>.delayed(stepDelay);

  @override
  Stream<ScanUpdate> analyze(ScanMedia media) async* {
    final bool isImage = media.kind == MediaKind.image;

    yield ScanProgressed(
      stage: ScanStage.ingest,
      progress: 0.03,
      log:
          'Fayl qəbul edildi: ${media.name} '
          '(${Formatters.fileSize(media.sizeInBytes)})',
    );
    final Future<AiDnaFingerprint> fingerprintFuture = _extractor.extract(
      media,
    );
    await _pause();
    yield ScanProgressed(
      stage: ScanStage.ingest,
      progress: 0.1,
      log: isImage
          ? 'Rəng profili sRGB-yə normallaşdırıldı'
          : 'Audio 44.1 kHz mono formatına çevrildi',
    );
    await _pause();
    yield ScanProgressed(
      stage: ScanStage.vectorize,
      progress: 0.22,
      log: isImage
          ? 'ViT-L/14 enkoderi: 256 patch emal edilir'
          : 'Mel-spektroqram: 128 band × 512 kadr',
    );
    await _pause();
    yield ScanProgressed(
      stage: ScanStage.vectorize,
      progress: 0.36,
      log: isImage
          ? 'Naxış konturları vektorlaşdırıldı (1 842 node)'
          : 'Muğam interval strukturu çıxarıldı (dəstgah şablonları)',
    );
    await _pause();

    final AiDnaFingerprint fingerprint = await fingerprintFuture;
    final _Match match = _match(media, fingerprint);

    yield ScanProgressed(
      stage: ScanStage.fingerprint,
      progress: 0.5,
      log: 'AI DNT: ${fingerprint.shortHash} · 512-ölçülü embedding',
    );
    await _pause();
    yield ScanProgressed(
      stage: ScanStage.fingerprint,
      progress: 0.58,
      log: isImage
          ? 'Ornament topologiyası imzası hesablandı'
          : 'Tembr və ritm imzası hesablandı',
    );
    await _pause();
    yield ScanProgressed(
      stage: ScanStage.datasetLookup,
      progress: 0.66,
      log: isImage
          ? 'LAION-5B indeksi yoxlanılır (5.85 mlrd nümunə)'
          : 'Generativ musiqi reyestri yoxlanılır (Suno, Udio)',
    );
    await _pause();
    yield ScanProgressed(
      stage: ScanStage.datasetLookup,
      progress: 0.76,
      log: isImage
          ? 'AI qalereyaları: 2.1 mln çıxış müqayisə edildi'
          : 'Generativ treklər: 640 min çıxış müqayisə edildi',
    );
    await _pause();
    yield ScanProgressed(
      stage: ScanStage.datasetLookup,
      progress: 0.84,
      log:
          'Ən yaxın uyğunluq: ${match.source} '
          '(${Formatters.percent(match.similarity)})',
    );
    await _pause();
    yield ScanProgressed(
      stage: ScanStage.provenance,
      progress: 0.92,
      log: 'Milli reyestr: ${match.origin.registryId} — ${match.origin.school}',
    );
    await _pause();
    yield ScanProgressed(
      stage: ScanStage.provenance,
      progress: 0.99,
      log: match.status == LicenseStatus.unauthorized
          ? 'Lisenziya tapılmadı → İCAZƏSİZ POZUNTU'
          : 'Etibarlı lisenziya: ${match.licensee}',
    );
    await _pause();

    yield ScanCompleted(
      ScanResult(
        id: 'SCN-${fingerprint.hash.substring(0, 8).toUpperCase()}',
        media: media,
        status: match.status,
        origin: match.origin,
        similarity: match.similarity,
        fingerprint: fingerprint,
        matchedSource: match.source,
        matchedOutputs: match.outputs,
        scannedAt: _clock(),
        licenseQuoteUsd: match.quote,
        licenseHolder: match.licensee,
      ),
    );
  }

  _Match _match(ScanMedia media, AiDnaFingerprint fingerprint) {
    final int seed = fingerprint.seed;
    final double quote =
        (media.kind == MediaKind.image ? 1200 : 1800) + (seed % 9) * 150.0;

    final DemoOutcome? scripted = DemoSamples.outcomeFor(media.sampleId);
    if (scripted != null) {
      return _Match(
        origin: scripted.origin,
        status: scripted.status,
        similarity: scripted.similarity,
        source: scripted.source,
        outputs: scripted.outputs,
        licensee: scripted.licensee,
        quote: media.kind == MediaKind.image ? 2400 : 3600,
      );
    }

    final List<HeritageOrigin> origins = HeritageCatalog.forKind(media.kind);
    final List<String> sources = HeritageCatalog.sourcesForKind(media.kind);
    final bool licensed = (seed >> 3) % 5 == 0;
    return _Match(
      origin: origins[seed % origins.length],
      status: licensed ? LicenseStatus.licensed : LicenseStatus.unauthorized,
      similarity: 0.86 + ((seed >> 7) % 1300) / 10000,
      source: sources[(seed >> 11) % sources.length],
      outputs: 1 + (seed >> 13) % 14,
      licensee: licensed
          ? '${HeritageCatalog.licensees[(seed >> 5) % HeritageCatalog.licensees.length]}'
                ' · CG-LIC-2026-${(100 + seed % 800).toString().padLeft(4, '0')}'
          : null,
      quote: quote,
    );
  }

  @override
  Future<CopyrightClaim> fileClaim(ScanResult result) async {
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    final DateTime now = _clock();
    return CopyrightClaim(
      id: 'CG-CLM-${now.year}-${10000 + _random.nextInt(89999)}',
      scanId: result.id,
      respondent: result.matchedSource,
      filedAt: now,
      responseDeadline: now.add(const Duration(hours: 72)),
    );
  }
}

final class _Match {
  const _Match({
    required this.origin,
    required this.status,
    required this.similarity,
    required this.source,
    required this.outputs,
    required this.quote,
    this.licensee,
  });

  final HeritageOrigin origin;
  final LicenseStatus status;
  final double similarity;
  final String source;
  final int outputs;
  final double quote;
  final String? licensee;
}
