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
import '../../features/ratings/model/datasources/ratings_remote_datasource.dart';
import '../../features/ratings/model/datasources/real_ratings_remote_datasource.dart';
import '../../features/ratings/model/ratings_repository.dart';
import '../../features/ratings/model/ratings_repository_impl.dart';
import '../../features/ratings/viewmodel/ratings_bloc.dart';
import '../../features/payments/model/datasources/payments_remote_datasource.dart';
import '../../features/payments/model/datasources/real_payments_remote_datasource.dart';
import '../../features/payments/model/payments_repository.dart';
import '../../features/payments/model/payments_repository_impl.dart';
import '../../features/payments/viewmodel/payments_bloc.dart';
import '../../features/complaints/model/datasources/complaints_remote_datasource.dart';
import '../../features/complaints/model/datasources/real_complaints_remote_datasource.dart';
import '../../features/complaints/model/complaints_repository.dart';
import '../../features/complaints/model/complaints_repository_impl.dart';
import '../../features/complaints/viewmodel/complaints_bloc.dart';
import '../../features/insights/model/datasources/insights_remote_datasource.dart';
import '../../features/insights/model/insights_repository.dart';
import '../../features/insights/model/insights_repository_impl.dart';
import '../../features/insights/viewmodel/insights_bloc.dart';
import '../../features/notifications/model/notifications_repository.dart';
import '../../features/notifications/model/notifications_repository_impl.dart';
import '../../features/notifications/viewmodel/notifications_bloc.dart';
import '../../features/pedigrees/model/datasources/pedigrees_remote_datasource.dart';
import '../../features/pedigrees/model/datasources/real_pedigrees_remote_datasource.dart';
import '../../features/pedigrees/model/pedigrees_repository.dart';
import '../../features/pedigrees/model/pedigrees_repository_impl.dart';
import '../../features/pedigrees/viewmodel/pedigrees_bloc.dart';
import '../../features/chat/model/datasources/chat_remote_datasource.dart';
import '../../features/chat/model/datasources/real_chat_remote_datasource.dart';
import '../../features/chat/model/chat_repository.dart';
import '../../features/chat/model/chat_repository_impl.dart';
import '../../features/chat/viewmodel/chat_badge_cubit.dart';
import '../../features/chat/viewmodel/chat_bloc.dart';
import '../../features/feed/model/datasources/feed_remote_datasource.dart';
import '../../features/feed/model/datasources/real_feed_remote_datasource.dart';
import '../../features/feed/model/feed_repository.dart';
import '../../features/feed/model/feed_repository_impl.dart';
import '../../features/feed/viewmodel/feed_bloc.dart';
import '../../features/promotions/model/datasources/promotions_remote_datasource.dart';
import '../../features/promotions/model/datasources/real_promotions_remote_datasource.dart';
import '../../features/promotions/model/promotions_repository.dart';
import '../../features/promotions/model/promotions_repository_impl.dart';
import '../../features/promotions/viewmodel/promotions_bloc.dart';
import '../../features/promotions/viewmodel/buy_with_cashback_bloc.dart';
import '../../features/loyalty/model/datasources/loyalty_remote_datasource.dart';
import '../../features/loyalty/model/datasources/real_loyalty_remote_datasource.dart';
import '../../features/loyalty/viewmodel/badges_bloc.dart';
import '../../features/lucky_wheel/model/datasources/lucky_wheel_datasource.dart';
import '../../features/lucky_wheel/model/datasources/real_lucky_wheel_datasource.dart';
import '../../features/lucky_wheel/viewmodel/lucky_wheel_bloc.dart';
import '../../features/referrals/model/datasources/referrals_remote_datasource.dart';
import '../../features/referrals/model/datasources/real_referrals_remote_datasource.dart';
import '../../features/referrals/model/referrals_repository.dart';
import '../../features/referrals/model/referrals_repository_impl.dart';
import '../../features/referrals/viewmodel/referrals_bloc.dart';
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
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => AuthBloc(repository: sl()));

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
  sl.registerLazySingleton<MarketRepository>(() => MarketRepositoryImpl(sl()));
  sl.registerFactory(() => MarketBloc(repository: sl()));

  // ── Pigeon ID ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PigeonRemoteDataSource>(
    () => RealPigeonRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<PigeonRepository>(() => PigeonRepositoryImpl(sl()));
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
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(sl()));
  sl.registerLazySingleton(() => CartBloc(
        repository: sl<CartRepository>(),
        paymentsRepository: sl<PaymentsRepository>(),
      ));

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
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl()),
  );
  sl.registerFactory(() => NotificationsBloc(repository: sl()));
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
  sl.registerLazySingleton<RacesRepository>(() => RacesRepositoryImpl(sl()));
  sl.registerFactory(() => RacesBloc(repository: sl()));

  // ── Ratings & Comments ────────────────────────────────────────────────────
  sl.registerLazySingleton<RatingsRemoteDataSource>(
    () => RealRatingsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<RatingsRepository>(
    () => RatingsRepositoryImpl(sl()),
  );
  sl.registerFactory(() => RatingsBloc(repository: sl()));

  // ── Payments ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PaymentsRemoteDataSource>(
    () => RealPaymentsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<PaymentsRepository>(
    () => PaymentsRepositoryImpl(sl()),
  );
  sl.registerFactory(() => PaymentsBloc(repository: sl()));

  sl.registerLazySingleton<ComplaintsRemoteDataSource>(
    () => RealComplaintsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ComplaintsRepository>(
    () => ComplaintsRepositoryImpl(sl()),
  );
  sl.registerFactory(() => ComplaintsBloc(repository: sl()));

  // ── Insights ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<InsightsRemoteDataSource>(
    () => RealInsightsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<InsightsRepository>(
    () => InsightsRepositoryImpl(sl()),
  );
  sl.registerFactory(() => InsightsBloc(repository: sl()));

  // ── Pedigrees ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PedigreesRemoteDataSource>(
    () => RealPedigreesRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<PedigreesRepository>(
    () => PedigreesRepositoryImpl(sl()),
  );
  sl.registerFactory(() => PedigreesBloc(repository: sl()));

  // ── Chat ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => RealChatRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerFactory(() => ChatBloc(repository: sl()));
  sl.registerLazySingleton(() => ChatBadgeCubit(repository: sl()));

  // ── Feed ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FeedRemoteDataSource>(
    () => RealFeedRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<FeedRepository>(() => FeedRepositoryImpl(sl()));
  sl.registerFactory(() => FeedBloc(repository: sl()));

  // ── Promotions ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PromotionsRemoteDataSource>(
    () => RealPromotionsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<PromotionsRepository>(
    () => PromotionsRepositoryImpl(sl()),
  );
  sl.registerFactory(() => PromotionsBloc(repository: sl()));
  sl.registerFactory(
    () => BuyWithCashbackBloc(datasource: sl<PointsRemoteDataSource>()),
  );

  // ── Loyalty / Badges ─────────────────────────────────────────────────────
  sl.registerLazySingleton<LoyaltyRemoteDataSource>(
    () => RealLoyaltyRemoteDataSource(sl()),
  );
  sl.registerFactory(() => BadgesBloc(datasource: sl<PointsRemoteDataSource>()));

  // ── Home ──────────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => HomeBloc(
      auctionsRepository: sl(),
      sellerHomeRemote: sl(),
      pointsRemote: sl(),
    ),
  );

  // ── Lucky Wheel ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<LuckyWheelDataSource>(
    () => RealLuckyWheelDataSource(sl()),
  );
  sl.registerFactory(() => LuckyWheelBloc(datasource: sl()));

  // ── Referrals ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ReferralsRemoteDataSource>(
    () => RealReferralsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ReferralsRepository>(
    () => ReferralsRepositoryImpl(sl()),
  );
  sl.registerFactory(() => ReferralsBloc(repository: sl()));
}
