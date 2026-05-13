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
import '../widgets/home_provider_features_section.dart';
import '../widgets/home_seller_metrics_section.dart';
import '../widgets/home_seller_notifications_section.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_top_bar.dart';
import '../../../auctions/model/auction_model.dart';
import '../../../auctions/view/pages/auctions_page.dart';
import '../../../market/model/product_model.dart';
import '../../../market/view/pages/market_page.dart';
import '../../../pigeon_id/view/pages/pigeon_id_form_page.dart';
import '../../../pigeon_id/viewmodel/pigeon_id_bloc.dart';
import '../../../subscription/view/pages/packages_page.dart';
import '../../../auth/model/user_model.dart';
import '../../../auth/viewmodel/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(const HomeStarted()),
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

  // ── Adapters: model → map for existing widgets ────────────────────────────

  static List<Map<String, dynamic>> _toActiveAuctionMaps(
      List<AuctionModel> auctions) {
    return auctions.map((a) {
      final ring =
          a.items.isNotEmpty ? a.items.first.bird.ringNumber : a.title;
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
      };
    }).toList();
  }

  static List<Map<String, dynamic>> _toEndingSoonMaps(
      List<AuctionModel> auctions) {
    return auctions.map((a) {
      final ring =
          a.items.isNotEmpty ? a.items.first.bird.ringNumber : a.title;
      final seconds = a.timeRemaining ?? 0;
      final h = seconds ~/ 3600;
      final m = (seconds % 3600) ~/ 60;
      final s = seconds % 60;
      return {
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
      };
    }).toList();
  }

  static List<Map<String, dynamic>> _toBirdMaps(List<ProductModel> birds) {
    return birds.map((p) => {
          'name': p.name,
          'price': _fmtPrice(p.price),
          'oldPrice': null,
          'views': '0',
          'rating': p.rating.toString(),
          'origin': p.categoryId,
          'discount': null,
          'color': 0xFF8D6E63,
        }).toList();
  }

  static UserModel? _authUserForUi(AuthState authState) {
    if (authState is AuthSuccess) return authState.user;
    if (authState is AuthSwitchingProfile) return authState.user;
    if (authState is AuthProfileSwitchFailure) return authState.user;
    return null;
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) {
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
        if (state is AuthProfileSwitchFailure) {
          final failure = state;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context
              .read<AuthBloc>()
              .add(const AuthProfileSwitchFailureAcknowledged());
          return;
        }
        context.read<HomeBloc>().add(const HomeRefreshRequested());
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          final isLoading = homeState.status == HomeStatus.loading ||
              homeState.status == HomeStatus.initial;

          final activeAuctions =
              _toActiveAuctionMaps(homeState.activeAuctions);
          final endingSoon = _toEndingSoonMaps(homeState.endingSoonAuctions);
          final birds = _toBirdMaps(homeState.featuredBirds);

          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
            final authUser = _authUserForUi(authState);
            final isSeller = authUser?.isSeller ?? false;
            final isProfileSwitching = authState is AuthSwitchingProfile;

            return Scaffold(
              backgroundColor: AppColors.pageBackground,
              body: SafeArea(
                child: Column(
                  children: [
                    const HomeTopBar(),
                    HomeAccountRow(
                      isServiceProvider: isSeller,
                      isProfileSwitching: isProfileSwitching,
                      balanceText: isSeller
                          ? homeState.sellerSummary?.balanceDisplay
                          : null,
                      onToggle: (wantSeller) {
                        if (isProfileSwitching || authUser == null) return;
                        if (wantSeller && authUser.isSeller) return;
                        if (!wantSeller && authUser.isCustomer) return;
                        context.read<AuthBloc>().add(
                              AuthSwitchProfileRequested(
                                wantSeller ? 'Seller' : 'Customer',
                              ),
                            );
                      },
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context
                              .read<HomeBloc>()
                              .add(const HomeRefreshRequested());
                        },
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    HomeHeroBanner(
                                        banners: HomeMockData.banners),
                                    if (isSeller) ...[
                                      HomeSellerMetricsSection(
                                          summary:
                                              homeState.sellerSummary),
                                      const SizedBox(height: 4),
                                      HomeSellerNotificationsSection(
                                          summary:
                                              homeState.sellerSummary),
                                      const SizedBox(height: 4),
                                      HomeProviderFeaturesSection(
                                          summary:
                                              homeState.sellerSummary),
                                    ],
                                    const SizedBox(height: 20),
                                    HomeBreedersSection(
                                        breeders: HomeMockData.breeders),
                                    const SizedBox(height: 20),
                                    if (birds.isNotEmpty)
                                      HomeFixedPriceBirdsSection(birds: birds),
                                    if (birds.isNotEmpty)
                                      const SizedBox(height: 20),
                                    if (activeAuctions.isNotEmpty)
                                      HomeActiveAuctionsSection(
                                          auctions: activeAuctions),
                                    if (activeAuctions.isNotEmpty)
                                      const SizedBox(height: 20),
                                    HomeComingSoonSection(
                                        birds: HomeMockData.comingSoon),
                                    const SizedBox(height: 20),
                                    if (endingSoon.isNotEmpty)
                                      HomeAuctionsSection(auctions: endingSoon),
                                    if (endingSoon.isNotEmpty)
                                      const SizedBox(height: 20),
                                    if (homeState.status == HomeStatus.error)
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          homeState.errorMessage ??
                                              'حدث خطأ في تحميل البيانات',
                                          style: const TextStyle(
                                              color: Colors.red, fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    const SizedBox(height: 80),
                                  ],
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
                        MaterialPageRoute(
                            builder: (_) => const AuctionsPage()));
                    return;
                  }
                  if (i == 2) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MarketPage()));
                    return;
                  }
                  if (i == 6) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PackagesPage()));
                    return;
                  }
                  if (i >= 3 && i <= 5) {
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
                onPressed: () {
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
                backgroundColor: AppColors.primary,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            );
          },
        );
        },
      ),
    );
  }
}
