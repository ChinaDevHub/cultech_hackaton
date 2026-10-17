import '../../domain/entities/api_key.dart';
import '../../domain/entities/cultural_dataset.dart';
import '../../domain/entities/license_order.dart';
import '../../domain/entities/marketplace_catalog.dart';

abstract interface class MarketplaceDataSource {
  Future<MarketplaceCatalog> fetchCatalog();

  Future<ApiKey> createApiKey(ApiEnvironment environment);

  Future<LicenseOrder> createLicenseOrder(CulturalDataset dataset);
}
