import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/api_key.dart';
import '../entities/cultural_dataset.dart';
import '../entities/license_order.dart';
import '../entities/marketplace_catalog.dart';
import '../repositories/marketplace_repository.dart';

class GetMarketplaceCatalog implements UseCase<MarketplaceCatalog, NoParams> {
  const GetMarketplaceCatalog(this._repository);

  final MarketplaceRepository _repository;

  @override
  Future<Result<MarketplaceCatalog>> call(NoParams params) =>
      _repository.getCatalog();
}

class GenerateApiKey implements UseCase<ApiKey, ApiEnvironment> {
  const GenerateApiKey(this._repository);

  final MarketplaceRepository _repository;

  @override
  Future<Result<ApiKey>> call(ApiEnvironment params) =>
      _repository.generateApiKey(params);
}

class RequestDatasetLicense implements UseCase<LicenseOrder, CulturalDataset> {
  const RequestDatasetLicense(this._repository);

  final MarketplaceRepository _repository;

  @override
  Future<Result<LicenseOrder>> call(CulturalDataset params) =>
      _repository.requestLicense(params);
}
