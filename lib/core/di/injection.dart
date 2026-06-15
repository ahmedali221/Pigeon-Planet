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
import '../../features/cart/model/cart_repository.dart';
import '../../features/cart/model/cart_repository_impl.dart';
import '../../features/cart/model/datasources/cart_remote_datasource.dart';
import '../../features/cart/model/datasources/real_cart_remote_datasource.dart';
import '../../features/cart/viewmodel/cart_bloc.dart';
import '../../features/profile/model/datasources/profile_remote_datasource.dart';
import '../../features/profile/model/datasources/real_profile_remote_datasource.dart';
import '../../features/profile/model/profile_repository.dart';
import '../../features/profile/model/profile_repository_impl.dart';
import '../../features/profile/viewmodel/profile_bloc.dart';
import '../../features/activity/model/datasources/activity_remote_datasource.dart';
import '../../features/home/model/datasources/points_remote_datasource.dart';
import '../../features/home/model/datasources/real_seller_home_remote_datasource.dart';
import '../../features/home/model/datasources/seller_home_remote_datasource.dart';
import '../../features/home/viewmodel/home_bloc.dart';
import '../../features/notifications/model/datasources/notifications_remote_datasource.dart';
import '../../features/subscription/model/datasources/subscription_packages_remote_datasource.dart';
import '../../features/subscription/viewmodel/packages_bloc.dart';
import '../../features/seller_products/model/datasources/seller_products_datasource.dart';
import '../../features/seller_products/model/datasources/real_seller_products_datasource.dart';
import '../../features/seller_products/model/seller_products_repository.dart';
import '../../features/seller_products/model/seller_products_repository_impl.dart';
import '../../features/seller_products/viewmodel/seller_products_bloc.dart';
import '../../features/races/model/datasources/races_remote_datasource.dart';
import '../../features/races/model/datasources/real_races_remote_datasource.dart';
import '../../features/races/model/races_repository.dart';
import '../../features/races/model/races_repository_impl.dart';
import '../../features/races/viewmodel/races_bloc.dart';
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

  // ── Seller Products ───────────────────────────────────────────────────────
  sl.registerLazySingleton<SellerProductsDataSource>(
    () => RealSellerProductsDataSource(sl()),
  );
  sl.registerLazySingleton<SellerProductsRepository>(
    () => SellerProductsRepositoryImpl(sl()),
  );
  sl.registerFactory(() => SellerProductsBloc(repository: sl()));

  // ── Cart ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => RealCartRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl()),
  );
  sl.registerFactory(() => CartBloc(repository: sl()));

  // ── Profile ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => RealProfileRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerFactory(() => ProfileBloc(repository: sl()));

  sl.registerLazySingleton<PointsRemoteDataSource>(
    () => RealPointsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => RealNotificationsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<SubscriptionPackagesRemoteDataSource>(
    () => RealSubscriptionPackagesRemoteDataSource(sl()),
  );
  sl.registerFactory(() => PackagesBloc(datasource: sl()));
  sl.registerLazySingleton<ActivityRemoteDataSource>(
    () => RealActivityRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<SellerHomeRemoteDataSource>(
    () => RealSellerHomeRemoteDataSource(sl()),
  );

  // ── Races ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<RacesRemoteDataSource>(
    () => RealRacesRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<RacesRepository>(
    () => RacesRepositoryImpl(sl()),
  );
  sl.registerFactory(() => RacesBloc(repository: sl()));

  // ── Home ──────────────────────────────────────────────────────────────────
  sl.registerFactory(() => HomeBloc(
        auctionsRepository: sl(),
        marketRepository: sl(),
        sellerHomeRemote: sl(),
        pointsRemote: sl(),
      ));
}
