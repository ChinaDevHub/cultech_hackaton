part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Loads the snapshot and (re)subscribes to the live incident feed.
/// Dispatching it again — e.g. from a retry button — restarts the stream.
final class DashboardSubscriptionRequested extends DashboardEvent {
  const DashboardSubscriptionRequested();
}
