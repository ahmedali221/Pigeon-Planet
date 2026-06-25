import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/widgets/shell_scaffold.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../model/auction_model.dart';
import '../../viewmodel/auctions_bloc.dart';
import '../widgets/auction_card.dart';
import '../../../../l10n/app_localizations.dart';
import 'auction_create_page.dart';
import 'my_bids_page.dart';

class AuctionsPage extends StatelessWidget {
  AuctionsPage({super.key});

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
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  static const _filterValues = ['all', 'ending_soon', 'my_auctions'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onFilterTap(int i) {
    if (_filterIndex == i) return;
    setState(() => _filterIndex = i);
    context.read<AuctionsBloc>().add(AuctionsFilterChanged(_filterValues[i]));
  }

  List<AuctionModel> _applySearch(List<AuctionModel> auctions) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return auctions;
    return auctions.where((a) {
      final ring = a.items.isNotEmpty
          ? a.items.first.bird.ringNumber.toLowerCase()
          : '';
      return a.title.toLowerCase().contains(q) ||
          a.sellerNickname.toLowerCase().contains(q) ||
          ring.contains(q) ||
          a.auctionTypeDisplay.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final filterKeys = [
      {'filter': 'all', 'label': l.all2},
      {'filter': 'ending_soon', 'label': l.ynthyQryba},
      {'filter': 'my_auctions', 'label': l.auction3},
    ];
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
                    child: AuctionCreatePage(),
                  ),
                ),
              ),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(l.newAuction,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: Column(
        children: [
          // ── Green header ──────────────────────────────────────────────────
          BlocBuilder<AuctionsBloc, AuctionsState>(
            buildWhen: (p, c) => p.auctions.length != c.auctions.length,
            builder: (context, state) => _AuctionsHeader(
              auctionCount: state.auctions.length,
              onRefresh: () => context
                  .read<AuctionsBloc>()
                  .add(const AuctionsRefreshRequested()),
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
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchCtrl,
                textAlign: TextAlign.start,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: l.searchAuctionHint,
                  hintStyle:
                      const TextStyle(color: AppColors.textHint, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textHint, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.textHint, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // ── Filter chips ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(filterKeys.length, (i) {
                  final isSelected = _filterIndex == i;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: GestureDetector(
                      onTap: () => _onFilterTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.pageBackground,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          filterKeys[i]['label'] as String,
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
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: BlocConsumer<AuctionsBloc, AuctionsState>(
              listenWhen: (p, c) =>
                  p.errorMessage != c.errorMessage &&
                  c.errorMessage != null,
              listener: (context, state) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? l.errorOccurred),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              builder: (context, state) {
                if (state.status == AuctionsStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state.status == AuctionsStatus.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_rounded,
                              size: 56, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage ?? l.errorOccurred,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => context
                                .read<AuctionsBloc>()
                                .add(const AuctionsRefreshRequested()),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(l.retry),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final displayed = _applySearch(state.auctions);

                if (displayed.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off_rounded
                              : Icons.gavel_rounded,
                          size: 56,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? AppLocalizations.of(context).no4(_searchQuery)
                              : l.noAuctions,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => context
                      .read<AuctionsBloc>()
                      .add(const AuctionsRefreshRequested()),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // count row
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            '${displayed.length} مزاد نشط',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      // grid
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              if (i == displayed.length) {
                                return _AuctionLoadMoreTile(
                                  loading: state.auctionsLoadingMore,
                                  onPressed: () => context
                                      .read<AuctionsBloc>()
                                      .add(const AuctionsLoadMoreRequested()),
                                );
                              }
                              return AuctionCard(auction: displayed[i]);
                            },
                            childCount: displayed.length +
                                (state.auctionsHasMore && _searchQuery.isEmpty
                                    ? 1
                                    : 0),
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.58,
                          ),
                        ),
                      ),
                    ],
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
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: loading ? null : onPressed,
          icon: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.expand_more_rounded, size: 20),
          label: Text(loading ? AppLocalizations.of(context).loading2 : AppLocalizations.of(context).loading),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _AuctionsHeader extends StatelessWidget {
  final int auctionCount;
  final VoidCallback onRefresh;
  final VoidCallback onMyBids;

  const _AuctionsHeader({
    required this.auctionCount,
    required this.onRefresh,
    required this.onMyBids,
  });

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
          ShellBackButton(color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l.activeAuctions,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (auctionCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$auctionCount مزاد',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _HeaderBtn(
            icon: Icons.gavel_rounded,
            tooltip: AppLocalizations.of(context).myBids2,
            onTap: onMyBids,
          ),
          const SizedBox(width: 8),
          _HeaderBtn(
            icon: Icons.refresh_rounded,
            tooltip: AppLocalizations.of(context).refresh,
            onTap: onRefresh,
          ),
        ],
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
