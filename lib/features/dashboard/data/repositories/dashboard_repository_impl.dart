import '../../../../core/error/failure_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/entities/incident.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_data_source.dart';

final class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._dataSource);

  final DashboardDataSource _dataSource;

  @override
  Future<Result<DashboardSnapshot>> getSnapshot() async {
    try {
      return Result<DashboardSnapshot>.ok(await _dataSource.fetchSnapshot());
    } on Object catch (error) {
      return Result<DashboardSnapshot>.err(mapExceptionToFailure(error));
    }
  }

  @override
  Stream<Incident> watchIncidents() {
    return _dataSource.watchIncidents().handleError(
      (Object error) => throw mapExceptionToFailure(error),
    );
  }
}
