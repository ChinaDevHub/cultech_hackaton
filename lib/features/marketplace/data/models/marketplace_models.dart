import '../../../../core/network/api_client.dart';
import '../../domain/entities/api_key.dart';
import '../../domain/entities/cultural_dataset.dart';
import '../../domain/entities/license_order.dart';
import '../../domain/entities/marketplace_catalog.dart';
import '../../domain/entities/pricing_plan.dart';

List<String> _strings(Object? value) => (value as List<dynamic>? ?? <dynamic>[])
    .cast<String>()
    .toList(growable: false);

abstract final class MarketplaceCatalogModel {
  static MarketplaceCatalog fromJson(JsonMap json) {
    return MarketplaceCatalog(
      datasets: (json['datasets'] as List<dynamic>)
          .map((dynamic e) => _dataset(e as JsonMap))
          .toList(growable: false),
      plans: (json['plans'] as List<dynamic>)
          .map((dynamic e) => _plan(e as JsonMap))
          .toList(growable: false),
    );
  }

  static CulturalDataset _dataset(JsonMap json) {
    return CulturalDataset(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      modality: DatasetModality.fromName(json['modality'] as String),
      itemCount: json['item_count'] as int,
      itemUnit: json['item_unit'] as String,
      sizeLabel: json['size_label'] as String,
      formats: _strings(json['formats']),
      useCases: _strings(json['use_cases']),
      priceUsd: (json['price_usd'] as num).toDouble(),
      licenseType: json['license_type'] as String,
      rating: (json['rating'] as num? ?? 0).toDouble(),
    );
  }

  static PricingPlan _plan(JsonMap json) {
    return PricingPlan(
      tier: PlanTier.values.byName(json['tier'] as String),
      name: json['name'] as String,
      price: json['price'] as String,
      period: json['period'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      apiQuota: json['api_quota'] as String? ?? '',
      features: _strings(json['features']),
      highlighted: json['highlighted'] as bool? ?? false,
    );
  }
}

abstract final class ApiKeyModel {
  static ApiKey fromJson(JsonMap json) {
    final String value = json['key'] as String;
    return ApiKey(
      value: value,
      environment: value.startsWith(ApiEnvironment.test.prefix)
          ? ApiEnvironment.test
          : ApiEnvironment.live,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      scopes: _strings(json['scopes']),
    );
  }
}

abstract final class LicenseOrderModel {
  static LicenseOrder fromJson(JsonMap json) {
    return LicenseOrder(
      id: json['order_id'] as String,
      datasetId: json['dataset_id'] as String,
      datasetTitle: json['dataset_title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}
