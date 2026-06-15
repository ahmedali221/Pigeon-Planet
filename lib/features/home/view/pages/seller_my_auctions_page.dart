import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../auctions/model/auction_model.dart';
import '../../../auctions/view/pages/auction_create_page.dart';
import '../../../auctions/view/pages/auction_detail_page.dart';
import '../../../auctions/viewmodel/auctions_bloc.dart';

class SellerMyAuctionsPage extends StatelessWidget {
  const SellerMyAuctionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AuctionsBloc>()..add(const AuctionsFilterChanged('my_auctions')),
      child: const _SellerMyAuctionsView(),
    );
  }
}

class _SellerMyAuctionsView extends StatefulWidget {
  const _SellerMyAuctionsView();

  @override
  State<_SellerMyAuctionsView> createState() => _SellerMyAuctionsViewState();
}

class _SellerMyAuctionsViewState extends State<_SellerMyAuctionsView> {
  void _openCreateAuction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<AuctionsBloc>(),
          child: const AuctionCreatePage(),
        ),
      ),
    );
    if (mounted) {
      context
          .read<AuctionsBloc>()
          .add(const AuctionsFilterChanged('my_auctions'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateAuction,
        backgroundColor: AppColors.orange,
        icon: const Icon(Icons.gavel_rounded, color: Colors.white),
        label: const Text(
          'مزاد جديد',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<AuctionsBloc, AuctionsState>(
        builder: (context, state) {
          final count = state.auctions.length;

          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                title: Text(
                  count > 0 ? 'مزاداتي ($count)' : 'مزاداتي',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: AppColors.primary,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    onPressed: () => context
                        .read<AuctionsBloc>()
                        .add(const AuctionsFilterChanged('my_auctions')),
                  ),
                ],
              ),
            ],
            body: state.status == AuctionsStatus.loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : state.auctions.isEmpty
                    ? _EmptyState(onAdd: _openCreateAuction)
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async => context
                            .read<AuctionsBloc>()
                            .add(const AuctionsFilterChanged('my_auctions')),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: state.auctions.length,
                          itemBuilder: (context, i) =>
                              _AuctionListTile(auction: state.auctions[i]),
                        ),
                      ),
          );
        },
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
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
              child: const Icon(
                Icons.gavel_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد مزادات بعد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أنشئ مزادك الأول لعرض طيورك',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
  const _AuctionListTile({required this.auction});

  @override
  Widget build(BuildContext context) {
    final a = auction;
    final ring = a.items.isNotEmpty ? a.items.first.bird.ringNumber : a.title;
    final bids = a.items.isNotEmpty
        ? a.items.first.bids.length
        : a.itemCount;

    final statusColor = a.isActive
        ? AppColors.primary
        : a.isEnded
            ? AppColors.textSecondary
            : AppColors.orange;
    final statusLabel = a.isActive
        ? 'نشط'
        : a.isEnded
            ? 'منتهي'
            : 'قادم';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AuctionDetailPage(auctionId: a.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(15)),
              child: SizedBox(
                width: 90,
                height: 96,
                child: Image.network(
                  'https://picsum.photos/seed/${a.id}/200/200',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.primaryLight,
                    child: const Icon(Icons.gavel_rounded,
                        color: AppColors.primary, size: 32),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.title.isNotEmpty ? a.title : ring,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
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
                    const SizedBox(height: 5),
                    Text(
                      ring,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'ج.م ${a.currentPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.gavel_rounded,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          '$bids مزايدة',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.only(end: 14),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
