import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../viewmodel/home_bloc.dart';
import '../data/home_mock_data.dart';
import '../widgets/home_account_row.dart';
import '../widgets/home_active_auctions_section.dart';
import '../widgets/home_auctions_section.dart';
import '../widgets/home_breeders_section.dart';
import '../widgets/home_coming_soon_section.dart';
import '../widgets/home_fixed_price_birds_section.dart';
import '../widgets/home_hero_banner.dart';
import '../widgets/home_seller_metrics_section.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_insights_preview_section.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/points_system_modal.dart';
import '../widgets/home_demo_cards_section.dart';
import '../../../auctions/model/auction_model.dart';
import '../../../auctions/view/pages/auction_create_page.dart';
import '../../../auctions/view/pages/auctions_page.dart';
import '../../../auctions/view/pages/bird_detail_page.dart';
import '../../../auctions/viewmodel/auctions_bloc.dart';
import '../../../cart/view/pages/cart_page.dart';
import '../../../cart/view/pages/orders_page.dart';
import '../../../cart/view/pages/seller_orders_page.dart';
import '../../../payments/view/pages/payments_page.dart';
import '../../../cart/viewmodel/cart_bloc.dart';
import '../../../market/view/pages/market_page.dart';
import '../../../profile/view/pages/profile_page.dart';
import '../../../profile/viewmodel/profile_bloc.dart';
import '../../../profile/model/profile_repository.dart';
import '../../../pigeon_id/view/pages/bird_qr_scanner_page.dart';
import '../../../pigeon_id/view/pages/pigeon_id_form_page.dart';
import '../../../pigeon_id/viewmodel/pigeon_id_bloc.dart';

import '../../../../../core/locale/locale_service.dart';
import '../../../auth/model/user_model.dart';
import '../../../auth/view/pages/account_type_page.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../../notifications/view/pages/notifications_page.dart';
import '../../../races/view/pages/races_page.dart';
import '../../../seller_products/view/pages/seller_products_page.dart';
import '../../../subscription/view/pages/packages_page.dart';
import '../../../rooms/view/pages/rooms_page.dart';
import '../../../feed/viewmodel/feed_bloc.dart';

UserModel? _homeAuthUserForUi(AuthState authState) {
  if (authState is AuthSuccess) return authState.user;
  if (authState is AuthSwitchingProfile) return authState.user;
  if (authState is AuthProfileSwitchFailure) return authState.user;
  return null;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = _homeAuthUserForUi(context.read<AuthBloc>().state);
    final isSeller = authUser?.isSeller ?? false;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<HomeBloc>()
                ..add(HomeStarted(isSeller: isSeller)),
        ),
        BlocProvider(create: (_) => sl<CartBloc>()..add(const CartStarted())),
        // FeedBloc is customer-only; sellers get an idle instance (never started)
        BlocProvider(
          create: (_) {
            final bloc = sl<FeedBloc>();
            if (!isSeller) bloc.add(const FeedStarted());
            return bloc;
          },
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _navIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _profileDisplayName;
  String? _loadedProfileType;

  // ── Adapters: model → map for existing widgets ────────────────────────────

  static List<Map<String, dynamic>> _toActiveAuctionMaps(
    List<AuctionModel> auctions,
  ) {
    return auctions.map((a) {
      final ring = a.items.isNotEmpty ? a.items.first.bird.ringNumber : a.title;
      final seconds = a.timeRemaining ?? 0;
      final days = seconds ~/ 86400;
      final hours = (seconds % 86400) ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      String timeLabel;
      if (days > 0) {
        timeLabel = '$days يوم و$hours ساعة';
      } else if (hours > 0) {
        timeLabel = '$hours ساعة و$minutes دقيقة';
      } else {
        timeLabel = '$minutes دقيقة';
      }
      return {
        'id': a.id,
        'ring': ring,
        'type': a.auctionTypeDisplay.isNotEmpty ? a.auctionTypeDisplay : 'مزاد',
        'typeColor': 0xFF3E7B52,
        'breed': a.items.isNotEmpty ? a.items.first.bird.colour : '—',
        'desc': a.description,
        'price': _fmtPrice(a.currentPrice),
        'timeLabel': timeLabel,
        'isFavorite': false,
        'color': 0xFF3E7B52,
        'seed': a.id,
        'thumbnailUrl': (a.thumbnailUrl?.isNotEmpty == true)
            ? a.thumbnailUrl
            : (a.items.isNotEmpty ? a.items.first.bird.thumbnailUrl : null),
      };
    }).toList();
  }

  static List<Map<String, dynamic>> _toEndingSoonMaps(
    List<AuctionModel> auctions,
  ) {
    return auctions.map((a) {
      final ring = a.items.isNotEmpty ? a.items.first.bird.ringNumber : a.title;
      final seconds = a.timeRemaining ?? 0;
      final h = seconds ~/ 3600;
      final m = (seconds % 3600) ~/ 60;
      final s = seconds % 60;
      return {
        'id': a.id,
        'name': '${a.sellerNickname} $ring',
        'seller': a.sellerNickname,
        'price': _fmtPrice(a.currentPrice),
        'views': '0',
        'rating': '0.0',
        'days': '${seconds ~/ 86400}',
        'hours': h.toString().padLeft(2, '0'),
        'minutes': m.toString().padLeft(2, '0'),
        'seconds': s.toString().padLeft(2, '0'),
        'origin': ring,
        'note': a.description,
        'color': 0xFF3E7B52,
        'thumbnailUrl': (a.thumbnailUrl?.isNotEmpty == true)
            ? a.thumbnailUrl
            : (a.items.isNotEmpty ? a.items.first.bird.thumbnailUrl : null),
      };
    }).toList();
  }

  static UserModel? _authUserForUi(AuthState authState) {
    return _homeAuthUserForUi(authState);
  }

  static String _displayNameForUi(UserModel? authUser) {
    return authUser?.phoneNumber.trim() ?? '';
  }

  Future<void> _ensureProfileDisplayName(String profileType) async {
    if (_loadedProfileType == profileType) return;
    _loadedProfileType = profileType;

    final result = await sl<ProfileRepository>().getProfile(profileType);
    if (!mounted || _loadedProfileType != profileType) return;

    result.fold(
      (_) => setState(() => _profileDisplayName = null),
      (profile) => setState(() => _profileDisplayName = profile.displayName),
    );
  }

  static String _fmtPrice(double v) {
    if (v == 0) return '0';
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(',');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }

  Widget _buildDrawer(
    BuildContext context,
    UserModel? authUser,
    bool isSeller,
    int unreadCount,
  ) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), AppColors.primary],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSeller ? 'بائع' : 'مشتري',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if ((authUser?.phoneNumber ?? '').isNotEmpty)
                        Text(
                          authUser!.phoneNumber,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Notifications
                ListTile(
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: AppColors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: const Text('الإشعارات'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                      ),
                    );
                    if (context.mounted) {
                      context.read<HomeBloc>().add(
                            HomeRefreshRequested(isSeller: isSeller),
                          );
                    }
                  },
                ),
                // My Package (sellers only)
                if (isSeller)
                  ListTile(
                    leading: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    title: const Text('باقتي'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PackagesPage(),
                        ),
                      );
                    },
                  ),
                // Seller: customer order items
                if (isSeller)
                  ListTile(
                    leading: const Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                    title: const Text('طلبات العملاء'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<CartBloc>(),
                            child: const SellerOrdersPage(),
                          ),
                        ),
                      );
                    },
                  ),
                // Seller: payment requests
                if (isSeller)
                  ListTile(
                    leading: const Icon(
                      Icons.payment_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                    title: const Text('طلبات الدفع'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentsPage(),
                        ),
                      );
                    },
                  ),
                // Cart (customers only)
                if (!isSeller)
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, cartState) => ListTile(
                      leading: Badge(
                        isLabelVisible: cartState.itemsCount > 0,
                        label: Text('${cartState.itemsCount}'),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                      title: const Text('سلة الشراء'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<CartBloc>(),
                              child: const CartPage(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                // Orders history (customers only)
                if (!isSeller)
                  ListTile(
                    leading: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                    title: const Text('طلباتي'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<CartBloc>(),
                            child: const OrdersPage(),
                          ),
                        ),
                      );
                    },
                  ),
                // Customer: payment requests
                if (!isSeller)
                  ListTile(
                    leading: const Icon(
                      Icons.payment_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                    title: const Text('طلبات الدفع'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentsPage(),
                        ),
                      );
                    },
                  ),
                // Language
                ValueListenableBuilder<Locale>(
                  valueListenable: LocaleService.notifier,
                  builder: (_, locale, _) {
                    final isAr = locale.languageCode == 'ar';
                    return ListTile(
                      leading: const Icon(
                        Icons.language_rounded,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                      title: const Text('اللغة'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          isAr ? 'EN' : 'ع',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: LocaleService.toggle,
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Logout
          ListTile(
            leading: Icon(
              Icons.logout_rounded,
              color: Colors.red.shade400,
              size: 24,
            ),
            title: Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red.shade400),
            ),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                      child: Text(
                        'تسجيل خروج',
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showSellerAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Header: placeholder (right) | title (center) | X button (left)
              Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Center(
                      child: Text(
                        'ماذا تريد أن تضيف؟',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _AddOptionTile(
                icon: Icons.gavel_rounded,
                color: AppColors.primary,
                title: 'إضافة طيور للمزاد',
                subtitle: 'ابدأ مزاد على حمامك الزاجل',
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<AuctionsBloc>(),
                        child: const AuctionCreatePage(),
                      ),
                    ),
                  );
                  if (context.mounted) {
                    final authUser = _homeAuthUserForUi(
                      context.read<AuthBloc>().state,
                    );
                    context.read<HomeBloc>().add(
                      HomeRefreshRequested(
                        isSeller: authUser?.isSeller ?? false,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              _AddOptionTile(
                icon: Icons.sell_rounded,
                color: AppColors.orange,
                title: 'إضافة طيور بسعر ثابت',
                subtitle: 'بيع مباشر بسعر محدد مسبقاً',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<PigeonIdBloc>(),
                        child: const PigeonIdFormPage(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _AddOptionTile(
                icon: Icons.shopping_bag_rounded,
                color: const Color(0xFF7B1FA2),
                title: 'إضافة منتجات',
                subtitle: 'أدوية، مكملات، مستلزمات وأكثر',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SellerProductsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _AddOptionTile(
                icon: Icons.workspace_premium_rounded,
                color: AppColors.orange,
                title: 'إدارة اشتراكاتي',
                subtitle: 'اشترك في باقة لتتمكن من إنشاء المزادات',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PackagesPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) {
        if (curr is AuthInitial) return true;
        if (curr is AuthProfileSwitchFailure) return true;
        if (curr is AuthSuccess && prev is AuthSwitchingProfile) return true;
        if (prev is AuthSuccess &&
            curr is AuthSuccess &&
            prev.user.profileType != curr.user.profileType) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AccountTypePage()),
            (_) => false,
          );
          return;
        }
        if (state is AuthProfileSwitchFailure) {
          final failure = state;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<AuthBloc>().add(
            const AuthProfileSwitchFailureAcknowledged(),
          );
          return;
        }
        final authUser = _homeAuthUserForUi(state);
        context.read<HomeBloc>().add(
          HomeRefreshRequested(isSeller: authUser?.isSeller ?? false),
        );
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          final isLoading =
              homeState.status == HomeStatus.loading ||
              homeState.status == HomeStatus.initial;

          final activeAuctions = _toActiveAuctionMaps(homeState.activeAuctions);
          final endingSoon = _toEndingSoonMaps(homeState.endingSoonAuctions);

          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final authUser = _authUserForUi(authState);
              final isSeller = authUser?.isSeller ?? false;
              final profileType = isSeller ? 'Seller' : 'Customer';
              if (authUser != null) {
                _ensureProfileDisplayName(profileType);
              }
              final displayName = _profileDisplayName?.trim().isNotEmpty == true
                  ? _profileDisplayName!
                  : _displayNameForUi(authUser);
              final isProfileSwitching = authState is AuthSwitchingProfile;
              final currentPointsBalance =
                  homeState.pointsBalance ??
                  homeState.sellerSummary?.pointsBalance ??
                  0;

              return Scaffold(
                key: _scaffoldKey,
                backgroundColor: AppColors.pageBackground,
                endDrawer: _buildDrawer(
                  context,
                  authUser,
                  isSeller,
                  homeState.unreadNotificationCount,
                ),
                body: SafeArea(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Column(
                          children: [
                            HomeTopBar(
                              avatarUrl: authUser?.avatarUrl,
                              onQrScanPressed: () =>
                                  BirdQrScannerPage.push(context),
                              onMenuPressed: () =>
                                  _scaffoldKey.currentState?.openEndDrawer(),
                              onAvatarTap: () {
                                final profileType =
                                    (authUser?.isSeller ?? false)
                                    ? 'Seller'
                                    : 'Customer';
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) =>
                                          sl<ProfileBloc>()
                                            ..add(ProfileStarted(profileType)),
                                      child: const ProfilePage(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            HomeAccountRow(
                              isServiceProvider: isSeller,
                              isProfileSwitching: isProfileSwitching,
                              pointsLabel: '$currentPointsBalance',
                              onToggle: (wantSeller) {
                                if (isProfileSwitching || authUser == null) {
                                  return;
                                }
                                if (wantSeller && authUser.isSeller) return;
                                if (!wantSeller && authUser.isCustomer) return;
                                if (wantSeller) {
                                  context.read<AuthBloc>().add(
                                    const AuthBecomeSellerRequested(),
                                  );
                                } else {
                                  context.read<AuthBloc>().add(
                                    const AuthSwitchProfileRequested(
                                      'Customer',
                                    ),
                                  );
                                }
                              },
                            ),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  context.read<HomeBloc>().add(
                                    HomeRefreshRequested(isSeller: isSeller),
                                  );
                                },
                                child: isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : SingleChildScrollView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // if (!isSeller)
                                            //   HomeHeroBanner(
                                            //       banners: HomeMockData.banners),
                                            if (!isSeller) ...[
                                              HomeWelcomeBanner(
                                                displayName: displayName,
                                              ),
                                              const SizedBox(height: 20),
                                              HomeHeroBanner(
                                                banners: HomeMockData.banners,
                                              ),
                                              const SizedBox(height: 20),
                                              const HomeDemoCardsSection(),
                                              const SizedBox(height: 20),
                                              HomeBreedersSection(
                                                sellers: homeState.sellers,
                                              ),
                                            ],
                                            if (isSeller) ...[
                                              HomeSellerMetricsSection(
                                                summary:
                                                    homeState.sellerSummary,
                                                displayName: displayName,
                                                myAuctionsCount:
                                                    homeState
                                                        .sellerSummary
                                                        ?.activeLiveAuctions ??
                                                    0,
                                                myBirdsCount:
                                                    homeState.myBirds.length,
                                              ),
                                              const SizedBox(height: 20),
                                              const HomeInsightsPreviewSection(),
                                              const SizedBox(height: 20),
                                              HomeBreedersSection(
                                                sellers: homeState.sellers,
                                              ),
                                            ],
                                            const SizedBox(height: 20),
                                            if (homeState
                                                .featuredBirds
                                                .isNotEmpty)
                                              HomeFixedPriceBirdsSection(
                                                birds: homeState.featuredBirds,
                                                onBirdTap: (bird) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          BlocProvider.value(
                                                            value: context
                                                                .read<
                                                                  CartBloc
                                                                >(),
                                                            child: BirdDetailPage(
                                                              bird: bird,
                                                              sellerNickname: bird
                                                                  .sellerNickname,
                                                            ),
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            if (homeState
                                                .featuredBirds
                                                .isNotEmpty)
                                              const SizedBox(height: 20),
                                            if (activeAuctions.isNotEmpty)
                                              HomeActiveAuctionsSection(
                                                auctions: activeAuctions,
                                              ),
                                            if (activeAuctions.isNotEmpty)
                                              const SizedBox(height: 20),
                                            HomeComingSoonSection(
                                              auctions:
                                                  homeState.comingSoonAuctions,
                                            ),
                                            const SizedBox(height: 20),
                                            if (endingSoon.isNotEmpty)
                                              HomeAuctionsSection(
                                                auctions: endingSoon,
                                              ),
                                            if (endingSoon.isNotEmpty)
                                              const SizedBox(height: 20),
                                            if (homeState.status ==
                                                HomeStatus.error)
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                child: Text(
                                                  homeState.errorMessage ??
                                                      'حدث خطأ في تحميل البيانات',
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 14,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            const SizedBox(height: 90),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add button pinned at bottom center (sellers only)
                      if (isSeller)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: FloatingActionButton(
                              heroTag: 'fab_add',
                              onPressed: () => _showSellerAddSheet(context),
                              backgroundColor: AppColors.primary,
                              shape: const CircleBorder(),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                bottomNavigationBar: HomeBottomNavBar(
                  currentIndex: _navIndex,
                  onTap: (i) {
                    if (i == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AuctionsPage()),
                      );
                      return;
                    }
                    if (i == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<CartBloc>(),
                            child: const MarketPage(),
                          ),
                        ),
                      );
                      return;
                    }
                    if (i == 3) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoomsPage(),
                        ),
                      );
                      return;
                    }
                    // النتائج (4)
                    if (i == 4) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RacesPage(),
                        ),
                      );
                      return;
                    }
                    // الساعة (5), البرنامج (6) — coming soon
                    if (i >= 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('قريباً'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    setState(() => _navIndex = i);
                  },
                ),
                floatingActionButton: FloatingActionButton(
                  heroTag: 'fab_points',
                  onPressed: () => PointsSystemModal.show(
                    context,
                    pointsBalance: currentPointsBalance,
                    isSeller: isSeller,
                  ),
                  backgroundColor: AppColors.primary,
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.monetization_on_rounded,
                    color: AppColors.orangeLight,
                    size: 28,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AddOptionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddOptionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Row(
          children: [
            // Icon box — solid color, rightmost in RTL
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Chevron — leftmost in RTL
            Icon(
              Icons.chevron_left_rounded,
              color: color.withValues(alpha: 0.6),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeWelcomeBanner extends StatelessWidget {
  final String displayName;

  const HomeWelcomeBanner({super.key, required this.displayName});

  @override
  Widget build(BuildContext context) {
    final name = displayName.trim();
    final greeting = name.isEmpty ? 'مرحبا بعودتك!' : 'مرحبا $name 👋';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'اكتشف أحدث المزادات والمربين',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30),
              ),
              child: const Icon(
                Icons.flutter_dash_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
