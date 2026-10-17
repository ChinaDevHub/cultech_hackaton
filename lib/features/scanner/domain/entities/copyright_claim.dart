import 'package:equatable/equatable.dart';

/// A copyright / takedown claim filed against an infringing AI platform.
final class CopyrightClaim extends Equatable {
  const CopyrightClaim({
    required this.id,
    required this.scanId,
    required this.respondent,
    required this.filedAt,
    required this.responseDeadline,
  });

  final String id;
  final String scanId;

  /// The platform the claim is filed against.
  final String respondent;
  final DateTime filedAt;
  final DateTime responseDeadline;

  @override
  List<Object?> get props => <Object?>[id];
}
