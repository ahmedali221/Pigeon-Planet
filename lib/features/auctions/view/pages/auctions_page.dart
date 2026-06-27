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

enum _LayoutMode { grid, horizontal }

class AuctionsPage extends StatelessWidget {
  const AuctionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSeller = context.select<AuthBloc, bool>((b) {
      final s = b.state;
      if (s is AuthSuccess) return s.user.isSeller;
      if (s is AuthSwitchingProfile) return s.user.isSeller;
      return false;
    });

    return BlocProvider(
      create: (_) {
        final bloc = sl<AuctionsBloc>();
        if (isSeller) {
          bloc.add(const AuctionsFilterChanged('my_auctions'));
        } else {
          bloc.add(const AuctionsStarted());
        }
        return bloc;
      },
      child: _AuctionsView(isSeller: isSeller),
    );
  }
}

class _AuctionsView extends StatefulWidget {
  final bool isSeller;

  const _AuctionsView({required this.isSeller});

  @override
  State<_AuctionsView> createState() => _AuctionsViewState();
}

class _AuctionsViewState extends State<_AuctionsView> {
  String _searchQuery = '';
  _LayoutMode _layoutMode = _LayoutMode.grid;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  _LayoutMode get _nextLayoutMode =>
      _layoutMode == _LayoutMode.grid ? _LayoutMode.horizontal : _LayoutMode.grid;

  IconData get _layoutToggleIcon =>
      _layoutMode == _LayoutMode.grid ? Icons.view_stream_rounded : Icons.grid_view_rounded;

  String _layoutToggleTooltip(AppLocalizations l) =>
      _layoutMode == _LayoutMode.grid ? l.layoutHorizontal : l.layoutGrid;

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
    final screenW = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      floatingActionButton: widget.isSeller
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
              searchController: _searchCtrl,
              searchQuery: _searchQuery,
              layoutToggleIcon: _layoutToggleIcon,
              layoutToggleTooltip: _layoutToggleTooltip(l),
              isSeller: widget.isSeller,
              onSearchChanged: (v) => setState(() => _searchQuery = v),
              onClearSearch: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              },
              onRefresh: () => context
                  .read<AuctionsBloc>()
                  .add(const AuctionsRefreshRequested()),
              onMyBids: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBidsPage()),
              ),
              onToggleLayout: () =>
                  setState(() => _layoutMode = _nextLayoutMode),
            ),
          ),

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

                // Exclude ended auctions, then apply search
                final displayed = _applySearch(
                  state.auctions.where((a) => !a.isEnded).toList(),
                );

                // ── Split into 3 sections ────────────────────────────────────
                final endingSoon = (displayed
                        .where((a) =>
                            a.isActive &&
                            a.timeRemaining != null &&
                            a.timeRemaining! <= 10800)
                        .toList()
                      ..sort((a, b) =>
                          a.timeRemaining!.compareTo(b.timeRemaining!)));

                final ongoing = displayed
                    .where((a) =>
                        a.isActive &&
                        (a.timeRemaining == null || a.timeRemaining! > 10800))
                    .toList();

                final upcoming = (displayed
                        .where((a) => !a.isActive && !a.isEnded)
                        .toList()
                      ..sort((a, b) =>
                          a.startTime.compareTo(b.startTime)));

                final hasAny = endingSoon.isNotEmpty ||
                    ongoing.isNotEmpty ||
                    upcoming.isNotEmpty;

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
                            l.activeAuctionsCount(displayed.length),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),

                      // ── Sections (always rendered; placeholder when empty) ──
                      if (_searchQuery.isNotEmpty && !hasAny)
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search_off_rounded,
                                    size: 56, color: AppColors.textHint),
                                const SizedBox(height: 16),
                                Text(
                                  l.no4(_searchQuery),
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        SliverToBoxAdapter(
                          child: _AuctionSection(
                            title: l.endingSoon,
                            emptyLabel: l.noAuctionsInCategory,
                            icon: Icons.timer_rounded,
                            accentColor: AppColors.red,
                            auctions: endingSoon,
                            layoutMode: _layoutMode,
                            screenW: screenW,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _AuctionSection(
                            title: l.ongoingAuctions,
                            emptyLabel: l.noAuctionsInCategory,
                            icon: Icons.gavel_rounded,
                            accentColor: AppColors.primary,
                            auctions: ongoing,
                            layoutMode: _layoutMode,
                            screenW: screenW,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _AuctionSection(
                            title: l.upcomingAuctions,
                            emptyLabel: l.noAuctionsInCategory,
                            icon: Icons.schedule_rounded,
                            accentColor: AppColors.orange,
                            auctions: upcoming,
                            layoutMode: _layoutMode,
                            screenW: screenW,
                          ),
                        ),
                      ],

                      // ── Load more (pagination, all filter only) ─────────────
                      if (state.auctionsHasMore && _searchQuery.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: _AuctionLoadMoreTile(
                              loading: state.auctionsLoadingMore,
                              onPressed: () => context
                                  .read<AuctionsBloc>()
                                  .add(const AuctionsLoadMoreRequested()),
                            ),
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 90)),
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

// ── Load more tile ───────────────────────────────────────────────────────────
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
          label: Text(loading
              ? AppLocalizations.of(context).loading2
              : AppLocalizations.of(context).loading),
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

// ── Header ───────────────────────────────────────────────────────────────────
class _AuctionsHeader extends StatelessWidget {
  final int auctionCount;
  final TextEditingController searchController;
  final String searchQuery;
  final IconData layoutToggleIcon;
  final String layoutToggleTooltip;
  final bool isSeller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onRefresh;
  final VoidCallback onMyBids;
  final VoidCallback onToggleLayout;

  const _AuctionsHeader({
    required this.auctionCount,
    required this.searchController,
    required this.searchQuery,
    required this.layoutToggleIcon,
    required this.layoutToggleTooltip,
    required this.isSeller,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onRefresh,
    required this.onMyBids,
    required this.onToggleLayout,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              ShellBackButton(color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isSeller ? l.myAuctions : l.activeAuctions,
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
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l.auctionCountBadge(auctionCount),
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
              // layout toggle: cycles grid → list → horizontal
              _HeaderBtn(
                icon: layoutToggleIcon,
                tooltip: layoutToggleTooltip,
                onTap: onToggleLayout,
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
          const SizedBox(height: 14),
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: searchController,
              textAlign: TextAlign.start,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: l.searchAuctionHint,
                hintStyle: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textHint,
                          size: 18,
                        ),
                        onPressed: onClearSearch,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
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

// ── Auction section (ending soon / ongoing / upcoming) ────────────────────────
class _AuctionSection extends StatelessWidget {
  final String title;
  final String emptyLabel;
  final IconData icon;
  final Color accentColor;
  final List<AuctionModel> auctions;
  final _LayoutMode layoutMode;
  final double screenW;

  const _AuctionSection({
    required this.title,
    required this.emptyLabel,
    required this.icon,
    required this.accentColor,
    required this.auctions,
    required this.layoutMode,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${auctions.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Content ────────────────────────────────────────────────────────
        _buildContent(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildContent() {
    if (auctions.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        height: 80,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accentColor.withValues(alpha: 0.35), size: 22),
            const SizedBox(width: 10),
            Text(
              emptyLabel,
              style: TextStyle(
                fontSize: 13,
                color: accentColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final cardW = screenW * 0.42;
    final cardH = cardW / 0.58;

    if (layoutMode == _LayoutMode.horizontal) {
      return SizedBox(
        height: cardH,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          itemCount: auctions.length,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.only(left: 12),
            child: SizedBox(
              width: cardW,
              child: AuctionCard(auction: auctions[i]),
            ),
          ),
        ),
      );
    }

    // Grid mode
    final cols = screenW >= 920 ? 4 : screenW >= 640 ? 3 : 2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.58,
        ),
        itemCount: auctions.length,
        itemBuilder: (context, i) => AuctionCard(auction: auctions[i]),
      ),
    );
  }
}
