import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/entities/incident.dart';

/// Contract shared by the HTTP and the offline demo implementations.
abstract interface class DashboardDataSource {
  Future<DashboardSnapshot> fetchSnapshot();

  Stream<Incident> watchIncidents();
}
