import 'package:equatable/equatable.dart';

final class LicenseOrder extends Equatable {
  const LicenseOrder({
    required this.id,
    required this.datasetId,
    required this.datasetTitle,
    required this.createdAt,
  });

  final String id;
  final String datasetId;
  final String datasetTitle;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[id];
}
