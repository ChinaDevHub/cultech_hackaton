import 'package:equatable/equatable.dart';

import '../../../../core/domain/heritage_category.dart';

enum IncidentStatus {
  unauthorized('İcazəsiz'),
  underReview('Araşdırılır'),
  takedownSent('Bloklama sorğusu'),
  licensed('Lisenziyalı');

  const IncidentStatus(this.label);

  final String label;

  static IncidentStatus fromName(String name) {
    return IncidentStatus.values.firstWhere(
      (IncidentStatus s) => s.name == name,
      orElse: () => IncidentStatus.underReview,
    );
  }
}

/// A detected use of protected heritage inside a generative-AI output.
base class Incident extends Equatable {
  const Incident({
    required this.id,
    required this.platform,
    required this.modelVersion,
    required this.assetName,
    required this.origin,
    required this.category,
    required this.similarity,
    required this.status,
    required this.detectedAt,
    this.licenseFeeUsd,
  });

  final String id;

  /// Platform family, e.g. `Midjourney`.
  final String platform;

  /// Model version, e.g. `v6.1`.
  final String modelVersion;

  /// Protected asset, e.g. `Qarabağ 'Xətai' naxışı`.
  final String assetName;

  /// Provenance, e.g. `Qarabağ xalçaçılıq məktəbi`.
  final String origin;
  final HeritageCategory category;

  /// Cosine similarity against the registered AI DNA (0 – 1).
  final double similarity;
  final IncidentStatus status;
  final DateTime detectedAt;

  /// Revenue captured when the use is covered by a B2B license.
  final double? licenseFeeUsd;

  String get platformLabel => '$platform $modelVersion';

  @override
  List<Object?> get props => <Object?>[
    id,
    platform,
    modelVersion,
    assetName,
    origin,
    category,
    similarity,
    status,
    detectedAt,
    licenseFeeUsd,
  ];
}
