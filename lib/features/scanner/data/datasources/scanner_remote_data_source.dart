import '../../../../core/network/api_client.dart';
import '../../domain/entities/ai_dna_fingerprint.dart';
import '../../domain/entities/copyright_claim.dart';
import '../../domain/entities/scan_media.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scan_update.dart';
import '../models/scan_models.dart';
import '../services/ai_dna_extractor.dart';
import 'scanner_data_source.dart';

/// CultGuard API implementation.
///
/// Privacy by design: the media file never leaves the device. Only the
/// locally extracted AI DNA (hash + embedding vector) is sent for matching.
final class ScannerRemoteDataSource implements ScannerDataSource {
  const ScannerRemoteDataSource(
    this._client, {
    this._extractor = const AiDnaExtractor(),
  });

  final ApiClient _client;
  final AiDnaExtractor _extractor;

  @override
  Stream<ScanUpdate> analyze(ScanMedia media) async* {
    yield ScanProgressed(
      stage: ScanStage.ingest,
      progress: 0.05,
      log: 'Fayl qəbul edildi: ${media.name}',
    );
    yield const ScanProgressed(
      stage: ScanStage.vectorize,
      progress: 0.2,
      log: 'Lokal enkoder işə salındı (media cihazdan çıxmır)',
    );
    final AiDnaFingerprint fingerprint = await _extractor.extract(media);
    yield ScanProgressed(
      stage: ScanStage.fingerprint,
      progress: 0.45,
      log: 'AI DNT: ${fingerprint.shortHash}',
    );
    yield const ScanProgressed(
      stage: ScanStage.datasetLookup,
      progress: 0.6,
      log: 'CultGuard vektor bazasında axtarış...',
    );
    final JsonMap json = await _client.postJson(
      '/v1/dna/match',
      body: <String, dynamic>{
        'hash': fingerprint.hash,
        'vector': fingerprint.vector,
        'media_kind': media.kind.name,
        'file_name': media.name,
      },
    );
    final ScanResult result = ScanResultModel.fromJson(
      json,
      media: media,
      fingerprint: fingerprint,
    );
    yield ScanProgressed(
      stage: ScanStage.provenance,
      progress: 0.95,
      log: 'Milli reyestr: ${result.origin.registryId}',
    );
    yield ScanCompleted(result);
  }

  @override
  Future<CopyrightClaim> fileClaim(ScanResult result) async {
    final JsonMap json = await _client.postJson(
      '/v1/claims',
      body: <String, dynamic>{
        'scan_id': result.id,
        'respondent': result.matchedSource,
        'registry_id': result.origin.registryId,
        'similarity': result.similarity,
        'dna_hash': result.fingerprint.hash,
      },
    );
    return CopyrightClaimModel.fromJson(json);
  }
}
