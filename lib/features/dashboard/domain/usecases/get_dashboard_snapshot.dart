import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/dashboard_snapshot.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSnapshot implements UseCase<DashboardSnapshot, NoParams> {
  const GetDashboardSnapshot(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Result<DashboardSnapshot>> call(NoParams params) =>
      _repository.getSnapshot();
}
