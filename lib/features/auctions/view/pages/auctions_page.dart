import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../viewmodel/auctions_bloc.dart';
import '../widgets/auction_card.dart';
import '../../../../l10n/app_localizations.dart';
import 'auction_create_page.dart';
import 'my_bids_page.dart';

class AuctionsPage extends StatelessWidget {
  const AuctionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuctionsBloc>()..add(const AuctionsStarted()),
      child: const _AuctionsView(),
    );
  }
}

class _AuctionsView extends StatefulWidget {
  const _AuctionsView();

  @override
  State<_AuctionsView> createState() => _AuctionsViewState();
}

class _AuctionsViewState extends State<_AuctionsView> {
  int _filterIndex = 0;
  final _searchCtrl = TextEditingController();

  static const _filterKeys = [
    {'filter': 'all', 'emoji': ''},
    {'filter': 'ending_soon', 'emoji': '🕐'},
    {'filter': 'my_auctions', 'emoji': '✈️'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onFilterTap(int i) {
    if (_filterIndex == i) return;
    setState(() => _filterIndex = i);
    final filter = _filterKeys[i]['filter'] as String;
    context.read<AuctionsBloc>().add(AuctionsFilterChanged(filter));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final filterLabels = [l.all, l.endingSoon, l.myAuctions];
    final isSeller = context.select<AuthBloc, bool>((b) {
      final s = b.state;
      if (s is AuthSuccess) return s.user.isSeller;
      if (s is AuthSwitchingProfile) return s.user.isSeller;
      return false;
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      floatingActionButton: isSeller
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<AuctionsBloc>(),
                    child: const AuctionCreatePage(),
                  ),
                ),
              ),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(l.newAuction,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: Column(
        children: [
          // ── Green header ──────────────────────────────────────────────────
          BlocBuilder<AuctionsBloc, AuctionsState>(
            buildWhen: (p, c) => p.auctions.length != c.auctions.length,
            builder: (context, state) => _AuctionsHeader(
              auctionCount: state.auctions.length,
              onRefresh: () =>
                  context.read<AuctionsBloc>().add(const AuctionsRefreshRequested()),
              onMyBids: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBidsPage()),
              ),
            ),
          ),

          // ── Search bar ────────────────────────────────────────────────────
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchCtrl,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: l.searchAuctionHint,
                  hintStyle:
                      TextStyle(color: AppColors.textHint, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.textHint, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // ── Filter chips ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filterKeys.length, (i) {
                  final f = _filterKeys[i];
                  final isSelected = _filterIndex == i;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: GestureDetector(
                      onTap: () => _onFilterTap(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.orange
                              : AppColors.pageBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.orange
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filterLabels[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                            if ((f['emoji'] as String).isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Text(f['emoji'] as String,
                                  style: const TextStyle(fontSize: 13)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 1),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: BlocConsumer<AuctionsBloc, AuctionsState>(
              listenWhen: (p, c) => p.errorMessage != c.errorMessage && c.errorMessage != null,
              listener: (context, state) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? l.errorOccurred),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              builder: (context, state) {
                if (state.status == AuctionsStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  );
                }
                if (state.status == AuctionsStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.errorMessage ?? l.errorOccurred,
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context
                              .read<AuctionsBloc>()
                              .add(const AuctionsRefreshRequested()),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary),
                          child: Text(l.retry,
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
                if (state.auctions.isEmpty) {
                  return Center(
                    child: Text(l.noAuctions,
                        style: const TextStyle(color: AppColors.textSecondary)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => context
                      .read<AuctionsBloc>()
                      .add(const AuctionsRefreshRequested()),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.58,
                    ),
                    itemCount: state.auctions.length +
                        (state.auctionsHasMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == state.auctions.length) {
                        return _AuctionLoadMoreTile(
                          loading: state.auctionsLoadingMore,
                          onPressed: () => context
                              .read<AuctionsBloc>()
                              .add(const AuctionsLoadMoreRequested()),
                        );
                      }
                      return AuctionCard(auction: state.auctions[i]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Green header ──────────────────────────────────────────────────────────────
class _AuctionLoadMoreTile extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _AuctionLoadMoreTile({
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Load more'),
      ),
    );
  }
}

class _AuctionsHeader extends StatelessWidget {
  final int auctionCount;
  final VoidCallback onRefresh;
  final VoidCallback onMyBids;
  const _AuctionsHeader(
      {required this.auctionCount, required this.onRefresh, required this.onMyBids});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
          top: topPadding + 12, bottom: 14, left: 16, right: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  l.activeAuctions,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onMyBids,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.gavel_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
