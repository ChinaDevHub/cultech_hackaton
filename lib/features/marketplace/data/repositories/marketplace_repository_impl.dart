import '../../../../core/error/failure_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/api_key.dart';
import '../../domain/entities/cultural_dataset.dart';
import '../../domain/entities/license_order.dart';
import '../../domain/entities/marketplace_catalog.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../datasources/marketplace_data_source.dart';

final class MarketplaceRepositoryImpl implements MarketplaceRepository {
  const MarketplaceRepositoryImpl(this._dataSource);

  final MarketplaceDataSource _dataSource;

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result<T>.ok(await action());
    } on Object catch (error) {
      return Result<T>.err(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Result<MarketplaceCatalog>> getCatalog() =>
      _guard(_dataSource.fetchCatalog);

  @override
  Future<Result<ApiKey>> generateApiKey(ApiEnvironment environment) =>
      _guard(() => _dataSource.createApiKey(environment));

  @override
  Future<Result<LicenseOrder>> requestLicense(CulturalDataset dataset) =>
      _guard(() => _dataSource.createLicenseOrder(dataset));
}
