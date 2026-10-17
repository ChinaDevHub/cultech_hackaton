import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/api_key.dart';
import '../../domain/usecases/marketplace_usecases.dart';

enum ApiKeyStatus { idle, generating, ready, failure }

final class ApiKeyState extends Equatable {
  const ApiKeyState({
    this.status = ApiKeyStatus.idle,
    this.environment = ApiEnvironment.live,
    this.key,
    this.revealed = false,
    this.errorMessage,
  });

  final ApiKeyStatus status;
  final ApiEnvironment environment;
  final ApiKey? key;
  final bool revealed;
  final String? errorMessage;

  ApiKeyState copyWith({
    ApiKeyStatus? status,
    ApiEnvironment? environment,
    ApiKey? Function()? key,
    bool? revealed,
    String? Function()? errorMessage,
  }) {
    return ApiKeyState(
      status: status ?? this.status,
      environment: environment ?? this.environment,
      key: key != null ? key() : this.key,
      revealed: revealed ?? this.revealed,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    environment,
    key,
    revealed,
    errorMessage,
  ];
}

/// Drives the instant Bearer-key generator of the API portal.
class ApiKeyCubit extends Cubit<ApiKeyState> {
  ApiKeyCubit({required this._generateApiKey}) : super(const ApiKeyState());

  final GenerateApiKey _generateApiKey;

  Future<void> generate() async {
    if (state.status == ApiKeyStatus.generating) return;
    emit(
      state.copyWith(status: ApiKeyStatus.generating, errorMessage: () => null),
    );
    final Result<ApiKey> result = await _generateApiKey(state.environment);
    if (isClosed) return;
    switch (result) {
      case Ok<ApiKey>(:final ApiKey value):
        // A freshly minted key is shown in full once, like real consoles.
        emit(
          state.copyWith(
            status: ApiKeyStatus.ready,
            key: () => value,
            revealed: true,
          ),
        );
      case Err<ApiKey>(:final Failure failure):
        emit(
          state.copyWith(
            status: ApiKeyStatus.failure,
            errorMessage: () => failure.message,
          ),
        );
    }
  }

  void selectEnvironment(ApiEnvironment environment) {
    if (environment == state.environment) return;
    emit(ApiKeyState(environment: environment));
  }

  void toggleReveal() => emit(state.copyWith(revealed: !state.revealed));
}
