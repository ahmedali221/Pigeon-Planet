import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../auctions/model/auction_model.dart';
import '../../../auctions/view/pages/auction_create_page.dart';
import '../../../auctions/view/pages/auction_detail_page.dart';
import '../../../auctions/view/pages/auction_edit_page.dart';
import '../../../auctions/viewmodel/auctions_bloc.dart';

import '../../../../l10n/app_localizations.dart';
class SellerMyAuctionsPage extends StatelessWidget {
  SellerMyAuctionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AuctionsBloc>()..add(AuctionsFilterChanged('my_auctions')),
      child: _SellerMyAuctionsView(),
    );
  }
}

class _SellerMyAuctionsView extends StatefulWidget {
  _SellerMyAuctionsView();

  @override
  State<_SellerMyAuctionsView> createState() => _SellerMyAuctionsViewState();
}

class _SellerMyAuctionsViewState extends State<_SellerMyAuctionsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _openCreateAuction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<AuctionsBloc>(),
          child: AuctionCreatePage(),
        ),
      ),
    );
    if (mounted) {
      context
          .read<AuctionsBloc>()
          .add(AuctionsFilterChanged('my_auctions'));
    }
  }

  void _refresh() =>
      context.read<AuctionsBloc>().add(AuctionsFilterChanged('my_auctions'));

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuctionsBloc, AuctionsState>(
      listenWhen: (p, c) =>
          (p.isCancelling && !c.isCancelling) ||
          (c.cancelError != null && c.cancelError != p.cancelError),
      listener: (context, state) {
        if (!state.isCancelling && state.cancelError == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).auctionCancelledSuccess),
              backgroundColor: AppColors.primary,
            ),
          );
          _refresh();
        } else if (state.cancelError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.cancelError!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<AuctionsBloc, AuctionsState>(
        builder: (context, state) {
          final all = state.auctions;
          final active = all.where((a) => a.isActive).toList();
          final ended = all.where((a) => a.isEnded).toList();
          final totalCount = all.length;

          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _openCreateAuction,
              backgroundColor: AppColors.orange,
              icon: Icon(Icons.gavel_rounded, color: Colors.white),
              label: Text(
                AppLocalizations.of(context).newAuction,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  title: Text(
                    totalCount > 0 ? 'مزاداتي ($totalCount)' : AppLocalizations.of(context).myAuctions,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: AppColors.primary,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_forward_ios_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.refresh_rounded, size: 20),
                      onPressed: _refresh,
                    ),
                  ],
                  bottom: TabBar(
                    controller: _tabs,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2.5,
                    tabs: [
                      Tab(text: 'نشطة (${active.length})'),
                      Tab(text: 'منتهية (${ended.length})'),
                    ],
                  ),
                ),
              ],
              body: state.status == AuctionsStatus.loading
                  ? Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : TabBarView(
                      controller: _tabs,
                      children: [
                        _AuctionList(
                          auctions: active,
                          isEnded: false,
                          onRefresh: _refresh,
                          onAdd: _openCreateAuction,
                        ),
                        _AuctionList(
                          auctions: ended,
                          isEnded: true,
                          onRefresh: _refresh,
                          onAdd: _openCreateAuction,
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

// ── Tab list ──────────────────────────────────────────────────────────────────

class _AuctionList extends StatelessWidget {
  final List<AuctionModel> auctions;
  final bool isEnded;
  final VoidCallback onRefresh;
  final VoidCallback onAdd;

  _AuctionList({
    required this.auctions,
    required this.isEnded,
    required this.onRefresh,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (auctions.isEmpty) {
      return _EmptyState(isEnded: isEnded, onAdd: onAdd);
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: auctions.length,
        itemBuilder: (context, i) =>
            _AuctionListTile(auction: auctions[i]),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isEnded;
  final VoidCallback onAdd;

  _EmptyState({required this.isEnded, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEnded ? Icons.history_rounded : Icons.gavel_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              isEnded ? 'لا توجد مزادات منتهية' : 'لا توجد مزادات نشطة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              isEnded
                  ? 'ستظهر هنا المزادات بعد انتهائها'
                  : 'أنشئ مزادك الأول لعرض طيورك',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Auction tile ──────────────────────────────────────────────────────────────

class _AuctionListTile extends StatelessWidget {
  final AuctionModel auction;

  _AuctionListTile({required this.auction});

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).cancelAuctionTitle),
        content: Text(
            AppLocalizations.of(context).cancelAuctionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).back),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<AuctionsBloc>()
                  .add(AuctionCancelRequested(auction.id));
            },
            child: Text(
              AppLocalizations.of(context).cancelAuctionTitle,
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = auction;
    final ring =
        a.items.isNotEmpty ? a.items.first.bird.ringNumber : a.title;
    final bids =
        a.items.isNotEmpty ? a.items.first.bids.length : a.itemCount;

    final statusColor = a.isActive
        ? AppColors.primary
        : a.isEnded
            ? AppColors.textSecondary
            : AppColors.orange;
    final statusLabel = a.isActive
        ? AppLocalizations.of(context).statusActive
        : a.isEnded
            ? AppLocalizations.of(context).statusEnded
            : AppLocalizations.of(context).statusUpcoming;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // thumbnail
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AuctionDetailPage(auctionId: a.id),
              ),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.horizontal(right: Radius.circular(15)),
              child: SizedBox(
                width: 90,
                height: 96,
                child: (a.thumbnailUrl != null && a.thumbnailUrl!.isNotEmpty)
                    ? Image.network(
                        a.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.primaryLight,
                          child: Icon(Icons.gavel_rounded,
                              color: AppColors.primary, size: 32),
                        ),
                      )
                    : Container(
                        color: AppColors.primaryLight,
                        child: Icon(Icons.gavel_rounded,
                            color: AppColors.primary, size: 32),
                      ),
              ),
            ),
          ),
          SizedBox(width: 14),
          // info
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AuctionDetailPage(auctionId: a.id),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.title.isNotEmpty ? a.title : ring,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      ring,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'ج.م ${a.currentPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.gavel_rounded,
                            size: 12, color: AppColors.textSecondary),
                        SizedBox(width: 3),
                        Text(
                          '$bids مزايدة',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // actions menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary, size: 20),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<AuctionsBloc>(),
                      child: AuctionEditPage(auction: a),
                    ),
                  ),
                );
              } else if (value == 'cancel') {
                _confirmCancel(context);
              } else if (value == 'detail') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AuctionDetailPage(auctionId: a.id),
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              if (a.isActive) ...[
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(AppLocalizations.of(context).edit),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel_outlined,
                          size: 18, color: Colors.red.shade400),
                      SizedBox(width: 8),
                      Text(AppLocalizations.of(context).cancel,
                          style: TextStyle(color: Colors.red.shade400)),
                    ],
                  ),
                ),
              ],
              PopupMenuItem(
                value: 'detail',
                child: Row(
                  children: [
                    Icon(Icons.visibility_outlined,
                        size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context).viewDetails),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(width: 4),
        ],
      ),
    );
  }
}
