import 'package:bloc_test/bloc_test.dart';
import 'package:cultech_hackaton/features/marketplace/data/datasources/marketplace_demo_data_source.dart';
import 'package:cultech_hackaton/features/marketplace/data/repositories/marketplace_repository_impl.dart';
import 'package:cultech_hackaton/features/marketplace/domain/entities/api_key.dart';
import 'package:cultech_hackaton/features/marketplace/domain/usecases/marketplace_usecases.dart';
import 'package:cultech_hackaton/features/marketplace/presentation/bloc/api_key_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ApiKeyCubit build() => ApiKeyCubit(
    generateApiKey: GenerateApiKey(
      MarketplaceRepositoryImpl(MarketplaceDemoDataSource()),
    ),
  );

  blocTest<ApiKeyCubit, ApiKeyState>(
    'generates a revealed cg_live_ Bearer key',
    build: build,
    act: (ApiKeyCubit cubit) => cubit.generate(),
    wait: const Duration(seconds: 1),
    verify: (ApiKeyCubit cubit) {
      final ApiKey key = cubit.state.key!;
      expect(cubit.state.status, ApiKeyStatus.ready);
      expect(cubit.state.revealed, isTrue);
      expect(key.value, matches(RegExp(r'^cg_live_[0-9a-f]{32}$')));
      expect(key.masked, startsWith('cg_live_${key.value.substring(8, 14)}'));
      expect(key.masked, contains('•'));
      expect(key.masked, endsWith(key.value.substring(key.value.length - 4)));
    },
  );

  blocTest<ApiKeyCubit, ApiKeyState>(
    'switching environment clears the previous key',
    build: build,
    act: (ApiKeyCubit cubit) async {
      await cubit.generate();
      cubit.selectEnvironment(ApiEnvironment.test);
      await cubit.generate();
    },
    wait: const Duration(seconds: 2),
    verify: (ApiKeyCubit cubit) {
      expect(cubit.state.environment, ApiEnvironment.test);
      expect(cubit.state.key!.value, startsWith('cg_test_'));
    },
  );
}
