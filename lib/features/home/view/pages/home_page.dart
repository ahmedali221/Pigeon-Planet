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
import '../widgets/home_insights_preview_section.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/points_system_modal.dart';
import '../widgets/home_demo_cards_section.dart';
import '../../../auctions/model/auction_model.dart';
import '../../../auctions/view/pages/auction_create_page.dart';
import '../../../auctions/view/pages/bird_detail_page.dart';
import '../../../auctions/viewmodel/auctions_bloc.dart';
import '../../../cart/viewmodel/cart_bloc.dart';
import '../../../profile/view/pages/profile_page.dart';
import '../../../profile/viewmodel/profile_bloc.dart';
import '../../../profile/model/profile_repository.dart';
import '../../../pigeon_id/view/pages/bird_qr_scanner_page.dart';
import '../../../pigeon_id/view/pages/pigeon_id_form_page.dart';
import '../../../pigeon_id/viewmodel/pigeon_id_bloc.dart';

import '../../../auth/model/user_model.dart';
import '../../../auth/view/pages/account_type_page.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../../chat/viewmodel/chat_badge_cubit.dart';
import '../../../feed/viewmodel/feed_bloc.dart';
import '../../../lucky_wheel/view/pages/lucky_wheel_page.dart';
import '../../../seller_products/view/pages/seller_products_page.dart';
import '../../../subscription/view/pages/packages_page.dart';
import '../widgets/home_drawer.dart';

import '../../../../l10n/app_localizations.dart';
UserModel? _homeAuthUserForUi(AuthState authState) {
  if (authState is AuthSuccess) return authState.user;
  if (authState is AuthSwitchingProfile) return authState.user;
  if (authState is AuthProfileSwitchFailure) return authState.user;
  return null;
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

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
        BlocProvider(
          create: (_) => sl<FeedBloc>()..add(FeedStarted()),
        ),
      ],
      child: _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _profileDisplayName;
  String? _loadedProfileKey;

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

  Future<void> _ensureProfileDisplayName(
    String profileType,
    String profileKey,
  ) async {
    if (_loadedProfileKey == profileKey) return;
    _loadedProfileKey = profileKey;

    final result = await sl<ProfileRepository>().getProfile(profileType);
    if (!mounted || _loadedProfileKey != profileKey) return;

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



  void _showSellerAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
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
              SizedBox(height: 16),
              // Header: placeholder (right) | title (center) | X button (left)
              Row(
                children: [
                  SizedBox(width: 40),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).whatDoYouWantToAdd,
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
              SizedBox(height: 20),
              _AddOptionTile(
                icon: Icons.gavel_rounded,
                color: AppColors.primary,
                title: AppLocalizations.of(context).addAuctionBirds,
                subtitle: AppLocalizations.of(context).startAuctionForBirds,
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<AuctionsBloc>(),
                        child: AuctionCreatePage(),
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
              SizedBox(height: 12),
              _AddOptionTile(
                icon: Icons.sell_rounded,
                color: AppColors.orange,
                title: AppLocalizations.of(context).addFixedPriceBirds,
                subtitle: AppLocalizations.of(context).directSaleFixedPrice,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<PigeonIdBloc>(),
                        child: PigeonIdFormPage(),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12),
              _AddOptionTile(
                icon: Icons.shopping_bag_rounded,
                color: Color(0xFF7B1FA2),
                title: AppLocalizations.of(context).addProducts,
                subtitle: AppLocalizations.of(context).productsSubtitle,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SellerProductsPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: 12),
              _AddOptionTile(
                icon: Icons.workspace_premium_rounded,
                color: AppColors.orange,
                title: AppLocalizations.of(context).manageSubscriptions,
                subtitle: AppLocalizations.of(context).subscribeToCreateAuctions,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PackagesPage(),
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
            MaterialPageRoute(builder: (_) => AccountTypePage()),
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
            AuthProfileSwitchFailureAcknowledged(),
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
                _ensureProfileDisplayName(
                  profileType,
                  '$profileType:${authUser.accessToken}',
                );
              }
              final displayName = _profileDisplayName?.trim().isNotEmpty == true
                  ? _profileDisplayName!
                  : _displayNameForUi(authUser);
              final isProfileSwitching = authState is AuthSwitchingProfile;
              final currentPointsBalance =
                  homeState.pointsBalance ??
                  homeState.sellerSummary?.pointsBalance ??
                  0;

              return BlocBuilder<ChatBadgeCubit, int>(
                builder: (context, chatUnread) => Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: AppColors.pageBackground,
                  endDrawer: HomeDrawer(
                    authUser: authUser,
                    isSeller: isSeller,
                    unreadCount: homeState.unreadNotificationCount,
                  ),
                body: SafeArea(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Column(
                          children: [
                            HomeTopBar(
                              avatarUrl: authUser?.avatarUrl,
                              unreadCount: homeState.unreadNotificationCount +
                                  chatUnread,
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
                                      child: ProfilePage(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            HomeAccountRow(
                              isServiceProvider: isSeller,
                              isProfileSwitching: isProfileSwitching,
                              pointsLabel: '$currentPointsBalance',
                              pointsBalance: currentPointsBalance,
                              onToggle: (wantSeller) {
                                if (isProfileSwitching || authUser == null) {
                                  return;
                                }
                                if (wantSeller && authUser.isSeller) return;
                                if (!wantSeller && authUser.isCustomer) return;
                                if (wantSeller) {
                                  context.read<AuthBloc>().add(
                                    AuthBecomeSellerRequested(),
                                  );
                                } else {
                                  context.read<AuthBloc>().add(
                                    AuthSwitchProfileRequested(
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
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : SingleChildScrollView(
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
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
                                              SizedBox(height: 20),
                                              HomeHeroBanner(
                                                banners: HomeMockData.banners,
                                              ),
                                              SizedBox(height: 20),
                                              HomeDemoCardsSection(),
                                              SizedBox(height: 20),
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
                                              SizedBox(height: 20),
                                              HomeInsightsPreviewSection(),
                                              SizedBox(height: 20),
                                              HomeBreedersSection(
                                                sellers: homeState.sellers,
                                              ),
                                            ],
                                            SizedBox(height: 20),
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
                                              SizedBox(height: 20),
                                            if (activeAuctions.isNotEmpty)
                                              HomeActiveAuctionsSection(
                                                auctions: activeAuctions,
                                              ),
                                            if (activeAuctions.isNotEmpty)
                                              SizedBox(height: 20),
                                            HomeComingSoonSection(
                                              auctions:
                                                  homeState.comingSoonAuctions,
                                            ),
                                            SizedBox(height: 20),
                                            if (endingSoon.isNotEmpty)
                                              HomeAuctionsSection(
                                                auctions: endingSoon,
                                              ),
                                            if (endingSoon.isNotEmpty)
                                              SizedBox(height: 20),
                                            if (homeState.status ==
                                                HomeStatus.error)
                                              Padding(
                                                padding: EdgeInsets.all(
                                                  16,
                                                ),
                                                child: Text(
                                                  homeState.errorMessage ??
                                                      AppLocalizations.of(context).dataLoadError,
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 14,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            SizedBox(height: 90),
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
                              shape: CircleBorder(),
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      // Lucky wheel floating icon — left side
                      Positioned(
                        bottom: 88,
                        left: 16,
                        child: _WheelFloatingIcon(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LuckyWheelPage(isSeller: isSeller),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  heroTag: 'fab_points',
                  onPressed: () => PointsSystemModal.show(
                    context,
                    pointsBalance: currentPointsBalance,
                    isSeller: isSeller,
                  ),
                  backgroundColor: AppColors.primary,
                  shape: CircleBorder(),
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: AppColors.orangeLight,
                    size: 28,
                  ),
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

  _AddOptionTile({
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
        padding: EdgeInsets.all(16),
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
            SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4),
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

  HomeWelcomeBanner({super.key, required this.displayName});

  @override
  Widget build(BuildContext context) {
    final name = displayName.trim();
    final greeting = name.isEmpty ? 'مرحبا بعودتك!' : 'مرحبا $name 👋';

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).discoverAuctionsAndBreeders,
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
              child: Icon(
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

// ── Lucky Wheel floating icon ─────────────────────────────────────────────────

class _WheelFloatingIcon extends StatefulWidget {
  final VoidCallback onTap;

  _WheelFloatingIcon({required this.onTap});

  @override
  State<_WheelFloatingIcon> createState() => _WheelFloatingIconState();
}

class _WheelFloatingIconState extends State<_WheelFloatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6366F1).withValues(alpha: 0.45),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text('🎡', style: TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }
}
