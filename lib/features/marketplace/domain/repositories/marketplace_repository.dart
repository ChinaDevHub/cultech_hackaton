import '../../../../core/utils/result.dart';
import '../entities/api_key.dart';
import '../entities/cultural_dataset.dart';
import '../entities/license_order.dart';
import '../entities/marketplace_catalog.dart';

abstract interface class MarketplaceRepository {
  Future<Result<MarketplaceCatalog>> getCatalog();

  Future<Result<ApiKey>> generateApiKey(ApiEnvironment environment);

  Future<Result<LicenseOrder>> requestLicense(CulturalDataset dataset);
}
