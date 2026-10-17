import 'package:get_it/get_it.dart';

import '../../features/dashboard/data/datasources/dashboard_data_source.dart';
import '../../features/dashboard/data/datasources/dashboard_demo_data_source.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_snapshot.dart';
import '../../features/dashboard/domain/usecases/watch_live_incidents.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/marketplace/data/datasources/marketplace_data_source.dart';
import '../../features/marketplace/data/datasources/marketplace_demo_data_source.dart';
import '../../features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import '../../features/marketplace/data/repositories/marketplace_repository_impl.dart';
import '../../features/marketplace/domain/repositories/marketplace_repository.dart';
import '../../features/marketplace/domain/usecases/marketplace_usecases.dart';
import '../../features/marketplace/presentation/bloc/api_key_cubit.dart';
import '../../features/marketplace/presentation/bloc/marketplace_bloc.dart';
import '../../features/scanner/data/datasources/media_picker_data_source.dart';
import '../../features/scanner/data/datasources/scanner_data_source.dart';
import '../../features/scanner/data/datasources/scanner_demo_data_source.dart';
import '../../features/scanner/data/datasources/scanner_remote_data_source.dart';
import '../../features/scanner/data/repositories/scanner_repository_impl.dart';
import '../../features/scanner/domain/repositories/scanner_repository.dart';
import '../../features/scanner/domain/usecases/scanner_usecases.dart';
import '../../features/scanner/presentation/bloc/scanner_bloc.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';

/// Global service locator — the app's composition root.
final GetIt sl = GetIt.instance;

/// Wires every layer together. Data sources are swapped between the live
/// CultGuard API and the offline demo backend based on [AppConfig].
Future<void> configureDependencies({AppConfig? config}) async {
  await sl.reset();
  final AppConfig appConfig = config ?? AppConfig.fromEnvironment();
  final bool demo = appConfig.useDemoBackend;

  sl
    ..registerSingleton<AppConfig>(appConfig)
    ..registerLazySingleton<ApiClient>(() => ApiClient(config: sl()));

  _registerDashboard(demo);
  _registerScanner(demo);
  _registerMarketplace(demo);
}

void _registerDashboard(bool demo) {
  sl
    ..registerLazySingleton<DashboardDataSource>(
      () => demo ? DashboardDemoDataSource() : DashboardRemoteDataSource(sl()),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(sl()),
    )
    ..registerLazySingleton<GetDashboardSnapshot>(
      () => GetDashboardSnapshot(sl()),
    )
    ..registerLazySingleton<WatchLiveIncidents>(() => WatchLiveIncidents(sl()))
    ..registerFactory<DashboardBloc>(
      () => DashboardBloc(getSnapshot: sl(), watchIncidents: sl()),
    );
}

void _registerScanner(bool demo) {
  sl
    ..registerLazySingleton<MediaPickerDataSource>(
      PlatformMediaPickerDataSource.new,
    )
    ..registerLazySingleton<ScannerDemoDataSource>(ScannerDemoDataSource.new)
    ..registerLazySingleton<ScannerDataSource>(
      () => demo ? sl<ScannerDemoDataSource>() : ScannerRemoteDataSource(sl()),
    )
    ..registerLazySingleton<ScannerRepository>(
      () => ScannerRepositoryImpl(
        mediaPicker: sl(),
        scanner: sl(),
        demoScanner: sl<ScannerDemoDataSource>(),
      ),
    )
    ..registerLazySingleton<GetScannerCapabilities>(
      () => GetScannerCapabilities(sl()),
    )
    ..registerLazySingleton<GetDemoSamples>(() => GetDemoSamples(sl()))
    ..registerLazySingleton<PickScanMedia>(() => PickScanMedia(sl()))
    ..registerLazySingleton<RunAiDnaScan>(() => RunAiDnaScan(sl()))
    ..registerLazySingleton<FileCopyrightClaim>(() => FileCopyrightClaim(sl()))
    ..registerFactory<ScannerBloc>(
      () => ScannerBloc(
        getCapabilities: sl(),
        getDemoSamples: sl(),
        pickMedia: sl(),
        runScan: sl(),
        fileClaim: sl(),
      ),
    );
}

void _registerMarketplace(bool demo) {
  sl
    ..registerLazySingleton<MarketplaceDataSource>(
      () => demo
          ? MarketplaceDemoDataSource()
          : MarketplaceRemoteDataSource(sl()),
    )
    ..registerLazySingleton<MarketplaceRepository>(
      () => MarketplaceRepositoryImpl(sl()),
    )
    ..registerLazySingleton<GetMarketplaceCatalog>(
      () => GetMarketplaceCatalog(sl()),
    )
    ..registerLazySingleton<GenerateApiKey>(() => GenerateApiKey(sl()))
    ..registerLazySingleton<RequestDatasetLicense>(
      () => RequestDatasetLicense(sl()),
    )
    ..registerFactory<MarketplaceBloc>(
      () => MarketplaceBloc(getCatalog: sl(), requestLicense: sl()),
    )
    ..registerFactory<ApiKeyCubit>(() => ApiKeyCubit(generateApiKey: sl()));
}
