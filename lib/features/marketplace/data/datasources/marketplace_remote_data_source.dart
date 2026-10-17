import '../../../../core/network/api_client.dart';
import '../../domain/entities/api_key.dart';
import '../../domain/entities/cultural_dataset.dart';
import '../../domain/entities/license_order.dart';
import '../../domain/entities/marketplace_catalog.dart';
import '../models/marketplace_models.dart';
import 'marketplace_data_source.dart';

final class MarketplaceRemoteDataSource implements MarketplaceDataSource {
  const MarketplaceRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<MarketplaceCatalog> fetchCatalog() async {
    return MarketplaceCatalogModel.fromJson(
      await _client.getJson('/v1/marketplace/catalog'),
    );
  }

  /// Keys are always minted server-side in production.
  @override
  Future<ApiKey> createApiKey(ApiEnvironment environment) async {
    return ApiKeyModel.fromJson(
      await _client.postJson(
        '/v1/keys',
        body: <String, dynamic>{'environment': environment.name},
      ),
    );
  }

  @override
  Future<LicenseOrder> createLicenseOrder(CulturalDataset dataset) async {
    return LicenseOrderModel.fromJson(
      await _client.postJson(
        '/v1/licenses',
        body: <String, dynamic>{'dataset_id': dataset.id},
      ),
    );
  }
}
