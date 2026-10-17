import '../../../../core/utils/result.dart';
import '../entities/dashboard_snapshot.dart';
import '../entities/incident.dart';

abstract interface class DashboardRepository {
  Future<Result<DashboardSnapshot>> getSnapshot();

  /// Live incidents as they are detected. Errors are emitted as [Failure]s.
  Stream<Incident> watchIncidents();
}
