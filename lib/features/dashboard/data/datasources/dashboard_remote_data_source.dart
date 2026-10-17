import 'dart:async';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/entities/incident.dart';
import '../models/dashboard_snapshot_model.dart';
import '../models/incident_model.dart';
import 'dashboard_data_source.dart';

/// REST implementation.
///
/// Live incidents are fetched by short polling (`GET /v1/incidents?since=`),
/// which works through any CORS-enabled HTTP gateway without WebSocket
/// infrastructure.
final class DashboardRemoteDataSource implements DashboardDataSource {
  const DashboardRemoteDataSource(
    this._client, {
    this.pollInterval = const Duration(seconds: 5),
  });

  final ApiClient _client;
  final Duration pollInterval;

  @override
  Future<DashboardSnapshot> fetchSnapshot() async {
    final JsonMap json = await _client.getJson('/v1/dashboard/snapshot');
    return DashboardSnapshotModel.fromJson(json);
  }

  @override
  Stream<Incident> watchIncidents() async* {
    DateTime since = DateTime.now().toUtc();
    while (true) {
      await Future<void>.delayed(pollInterval);
      final List<JsonMap> items = await _client.getJsonList(
        '/v1/incidents',
        query: <String, dynamic>{'since': since.toIso8601String()},
      );
      for (final JsonMap item in items.reversed) {
        final IncidentModel incident = IncidentModel.fromJson(item);
        if (incident.detectedAt.toUtc().isAfter(since)) {
          since = incident.detectedAt.toUtc();
        }
        yield incident;
      }
    }
  }
}
