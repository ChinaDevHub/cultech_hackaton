import '../../../../core/usecase/usecase.dart';
import '../entities/incident.dart';
import '../repositories/dashboard_repository.dart';

class WatchLiveIncidents implements StreamUseCase<Incident, NoParams> {
  const WatchLiveIncidents(this._repository);

  final DashboardRepository _repository;

  @override
  Stream<Incident> call(NoParams params) => _repository.watchIncidents();
}
