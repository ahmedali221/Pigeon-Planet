import 'package:get_it/get_it.dart';

import '../../features/auth/model/datasources/auth_remote_datasource.dart';
import '../../features/auth/model/datasources/real_auth_remote_datasource.dart';
import '../../features/auth/model/auth_repository.dart';
import '../../features/auth/model/auth_repository_impl.dart';
import '../../features/auth/viewmodel/auth_bloc.dart';
import '../../features/auctions/model/datasources/auctions_remote_datasource.dart';
import '../../features/auctions/model/datasources/real_auctions_remote_datasource.dart';
import '../../features/auctions/model/auctions_repository.dart';
import '../../features/auctions/model/auctions_repository_impl.dart';
import '../../features/auctions/viewmodel/auctions_bloc.dart';
import '../../features/market/model/datasources/market_remote_datasource.dart';
import '../../features/market/model/datasources/real_market_remote_datasource.dart';
import '../../features/market/model/market_repository.dart';
import '../../features/market/model/market_repository_impl.dart';
import '../../features/market/viewmodel/market_bloc.dart';
import '../../features/pigeon_id/model/datasources/pigeon_remote_datasource.dart';
import '../../features/pigeon_id/model/datasources/real_pigeon_remote_datasource.dart';
import '../../features/pigeon_id/model/pigeon_repository.dart';
import '../../features/pigeon_id/model/pigeon_repository_impl.dart';
import '../../features/pigeon_id/viewmodel/pigeon_id_bloc.dart';
import '../../features/home/model/datasources/real_seller_home_remote_datasource.dart';
import '../../features/home/model/datasources/seller_home_remote_datasource.dart';
import '../../features/home/viewmodel/home_bloc.dart';
import '../network/dio_client.dart';
import '../network/token_storage.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // ── Core ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));

  // ── Auth ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => RealAuthRemoteDataSource(sl(), sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerFactory(() => AuthBloc(repository: sl()));

  // ── Auctions ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuctionsRemoteDataSource>(
    () => RealAuctionsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<AuctionsRepository>(
    () => AuctionsRepositoryImpl(sl()),
  );
  sl.registerFactory(() => AuctionsBloc(repository: sl()));

  // ── Market ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<MarketRemoteDataSource>(
    () => RealMarketRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<MarketRepository>(
    () => MarketRepositoryImpl(sl()),
  );
  sl.registerFactory(() => MarketBloc(repository: sl()));

  // ── Pigeon ID ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PigeonRemoteDataSource>(
    () => RealPigeonRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<PigeonRepository>(
    () => PigeonRepositoryImpl(sl()),
  );
  sl.registerFactory(() => PigeonIdBloc(repository: sl()));

  sl.registerLazySingleton<SellerHomeRemoteDataSource>(
    () => RealSellerHomeRemoteDataSource(sl()),
  );

  // ── Home ──────────────────────────────────────────────────────────────────
  sl.registerFactory(() => HomeBloc(
        auctionsRepository: sl(),
        marketRepository: sl(),
        sellerHomeRemote: sl(),
      ));
}
