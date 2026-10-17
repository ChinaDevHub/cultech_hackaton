import 'package:equatable/equatable.dart';

enum ApiEnvironment {
  live('cg_live_', 'Live'),
  test('cg_test_', 'Test');

  const ApiEnvironment(this.prefix, this.label);

  final String prefix;
  final String label;
}

final class ApiKey extends Equatable {
  const ApiKey({
    required this.value,
    required this.environment,
    required this.createdAt,
    required this.scopes,
  });

  final String value;
  final ApiEnvironment environment;
  final DateTime createdAt;
  final List<String> scopes;

  /// `cg_live_98a72b••••••••••••••••••••c41f`
  String get masked {
    final String prefix = environment.prefix;
    final String secret = value.substring(prefix.length);
    if (secret.length <= 10) return value;
    return '$prefix${secret.substring(0, 6)}'
        '${'•' * (secret.length - 10)}'
        '${secret.substring(secret.length - 4)}';
  }

  @override
  List<Object?> get props => <Object?>[value];
}
