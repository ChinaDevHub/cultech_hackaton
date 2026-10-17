import 'package:equatable/equatable.dart';

import '../utils/result.dart';

/// A single application action that returns a [Result].
abstract interface class UseCase<T, P> {
  Future<Result<T>> call(P params);
}

/// A use case that exposes a continuous stream of values.
abstract interface class StreamUseCase<T, P> {
  Stream<T> call(P params);
}

final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => const <Object?>[];
}
