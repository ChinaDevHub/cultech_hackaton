import '../../../../core/domain/heritage_category.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/ai_dna_fingerprint.dart';
import '../../domain/entities/copyright_claim.dart';
import '../../domain/entities/scan_media.dart';
import '../../domain/entities/scan_result.dart';

/// Parses `POST /v1/dna/match` responses.
abstract final class ScanResultModel {
  static ScanResult fromJson(
    JsonMap json, {
    required ScanMedia media,
    required AiDnaFingerprint fingerprint,
  }) {
    final JsonMap origin = json['origin'] as JsonMap;
    return ScanResult(
      id: json['scan_id'] as String,
      media: media,
      status: json['status'] == 'licensed'
          ? LicenseStatus.licensed
          : LicenseStatus.unauthorized,
      origin: HeritageOrigin(
        school: origin['school'] as String,
        motif: origin['motif'] as String,
        region: origin['region'] as String? ?? '',
        era: origin['era'] as String? ?? '',
        registryId: origin['registry_id'] as String,
        category: HeritageCategory.fromName(
          origin['category'] as String? ?? '',
        ),
        recognition: origin['recognition'] as String?,
      ),
      similarity: (json['similarity'] as num).toDouble(),
      fingerprint: fingerprint,
      matchedSource: json['matched_source'] as String,
      matchedOutputs: json['matched_outputs'] as int? ?? 1,
      scannedAt: DateTime.parse(json['scanned_at'] as String).toLocal(),
      licenseQuoteUsd: (json['license_quote_usd'] as num? ?? 0).toDouble(),
      licenseHolder: json['license_holder'] as String?,
    );
  }
}

/// Parses `POST /v1/claims` responses.
abstract final class CopyrightClaimModel {
  static CopyrightClaim fromJson(JsonMap json) {
    return CopyrightClaim(
      id: json['claim_id'] as String,
      scanId: json['scan_id'] as String,
      respondent: json['respondent'] as String,
      filedAt: DateTime.parse(json['filed_at'] as String).toLocal(),
      responseDeadline: DateTime.parse(
        json['response_deadline'] as String,
      ).toLocal(),
    );
  }
}
