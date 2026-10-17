import 'package:equatable/equatable.dart';

import '../../../../core/domain/heritage_category.dart';
import 'ai_dna_fingerprint.dart';
import 'scan_media.dart';

enum LicenseStatus {
  unauthorized('İcazəsiz Pozuntu'),
  licensed('Təsdiqlənmiş Lisenziyalı');

  const LicenseStatus(this.label);

  final String label;
}

/// Registered provenance of a protected heritage item.
final class HeritageOrigin extends Equatable {
  const HeritageOrigin({
    required this.school,
    required this.motif,
    required this.region,
    required this.era,
    required this.registryId,
    required this.category,
    this.recognition,
  });

  /// e.g. `Şirvan Xalçaçılıq Məktəbi`
  final String school;

  /// e.g. `Boteh (Buta) Naxışı`
  final String motif;
  final String region;
  final String era;

  /// National heritage registry identifier.
  final String registryId;
  final HeritageCategory category;

  /// International recognition, e.g. UNESCO inscription.
  final String? recognition;

  String get title => '$school — $motif';

  @override
  List<Object?> get props => <Object?>[registryId];
}

final class ScanResult extends Equatable {
  const ScanResult({
    required this.id,
    required this.media,
    required this.status,
    required this.origin,
    required this.similarity,
    required this.fingerprint,
    required this.matchedSource,
    required this.matchedOutputs,
    required this.scannedAt,
    required this.licenseQuoteUsd,
    this.licenseHolder,
  });

  final String id;
  final ScanMedia media;
  final LicenseStatus status;
  final HeritageOrigin origin;

  /// Cosine similarity to the registered AI DNA (0 – 1).
  final double similarity;
  final AiDnaFingerprint fingerprint;

  /// Where the match was observed, e.g. `Midjourney v6.1`.
  final String matchedSource;

  /// How many generated outputs share this DNA.
  final int matchedOutputs;
  final DateTime scannedAt;

  /// Indicative B2B license price for legitimate use of the asset.
  final double licenseQuoteUsd;

  /// Licensee, when the use is covered by a CultGuard license.
  final String? licenseHolder;

  bool get isInfringement => status == LicenseStatus.unauthorized;

  @override
  List<Object?> get props => <Object?>[id];
}
