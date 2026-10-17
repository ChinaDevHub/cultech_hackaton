import '../../../../core/domain/heritage_category.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/incident.dart';

/// Wire format of an [Incident].
final class IncidentModel extends Incident {
  const IncidentModel({
    required super.id,
    required super.platform,
    required super.modelVersion,
    required super.assetName,
    required super.origin,
    required super.category,
    required super.similarity,
    required super.status,
    required super.detectedAt,
    super.licenseFeeUsd,
  });

  factory IncidentModel.fromJson(JsonMap json) {
    return IncidentModel(
      id: json['id'] as String,
      platform: json['platform'] as String,
      modelVersion: json['model_version'] as String? ?? '',
      assetName: json['asset_name'] as String,
      origin: json['origin'] as String? ?? '',
      category: HeritageCategory.fromName(json['category'] as String? ?? ''),
      similarity: (json['similarity'] as num).toDouble(),
      status: IncidentStatus.fromName(json['status'] as String? ?? ''),
      detectedAt: DateTime.parse(json['detected_at'] as String).toLocal(),
      licenseFeeUsd: (json['license_fee_usd'] as num?)?.toDouble(),
    );
  }

  JsonMap toJson() => <String, dynamic>{
    'id': id,
    'platform': platform,
    'model_version': modelVersion,
    'asset_name': assetName,
    'origin': origin,
    'category': category.name,
    'similarity': similarity,
    'status': status.name,
    'detected_at': detectedAt.toUtc().toIso8601String(),
    'license_fee_usd': licenseFeeUsd,
  };
}
