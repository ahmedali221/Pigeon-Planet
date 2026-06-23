import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../home/model/seller_model.dart';
import '../../../home/view/pages/breeder_profile_page.dart';
import '../../viewmodel/feed_bloc.dart';

class SellersListPage extends StatefulWidget {
  const SellersListPage({super.key});

  @override
  State<SellersListPage> createState() => _SellersListPageState();
}

class _SellersListPageState extends State<SellersListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final bloc = context.read<FeedBloc>();
    if (bloc.state.sellersStatus == SellersListStatus.initial) {
      bloc.add(const FeedSellersListRequested());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FeedBloc>().add(const FeedSellersListNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'المربّون',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () =>
                context.read<FeedBloc>().add(const FeedSellersListRequested()),
          ),
        ],
      ),
      body: BlocConsumer<FeedBloc, FeedState>(
        listenWhen: (p, c) =>
            p.actionError != c.actionError && c.actionError != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        buildWhen: (p, c) =>
            p.sellersList != c.sellersList ||
            p.sellersStatus != c.sellersStatus ||
            p.followedSellerIds != c.followedSellerIds,
        builder: (context, state) {
          if (state.sellersStatus == SellersListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.sellersStatus == SellersListStatus.error &&
              state.sellersList.isEmpty) {
            return _ErrorState(
              onRetry: () =>
                  context.read<FeedBloc>().add(const FeedSellersListRequested()),
            );
          }
          if (state.sellersList.isEmpty) {
            return const _EmptyState();
          }
          // Group sellers by userId, preserving order of first appearance.
          final groups = <int, List<SellerModel>>{};
          for (final s in state.sellersList) {
            groups.putIfAbsent(s.userId, () => []).add(s);
          }
          final slivers = <Widget>[
            const SliverPadding(padding: EdgeInsets.only(top: 16)),
          ];
          for (final entry in groups.entries) {
            final sellers = entry.value;
            if (sellers.length > 1) {
              slivers.add(SliverToBoxAdapter(
                child: _GroupHeader(username: sellers.first.username),
              ));
            }
            slivers.add(SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: sellers.length,
                itemBuilder: (ctx, i) => _SellerCard(
                  seller: sellers[i],
                  isFollowing:
                      state.followedSellerIds.contains(sellers[i].id),
                ),
              ),
            ));
            slivers.add(
              const SliverPadding(padding: EdgeInsets.only(bottom: 12)),
            );
          }
          if (state.sellersStatus == SellersListStatus.loadingMore) {
            slivers.add(const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ));
          }
          slivers.add(
            const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
          );

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<FeedBloc>().add(const FeedSellersListRequested()),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: slivers,
            ),
          );
        },
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String username;

  const _GroupHeader({required this.username});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.link_rounded,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'نفس المالك · $username',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  final SellerModel seller;
  final bool isFollowing;

  const _SellerCard({required this.seller, required this.isFollowing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BreederProfilePage(seller: seller),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.85),
                    AppColors.primary.withValues(alpha: 0.55),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -24),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: seller.avatarUrl != null
                      ? NetworkImage(seller.avatarUrl!)
                      : null,
                  child: seller.avatarUrl == null
                      ? Text(
                          seller.nickname.isNotEmpty
                              ? seller.nickname[0]
                              : '؟',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Column(
                children: [
                  Text(
                    seller.nickname,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 10, color: AppColors.textHint),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          seller.country,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textHint),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 11, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        seller.avgRating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textHint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: isFollowing
                        ? OutlinedButton(
                            onPressed: () => context
                                .read<FeedBloc>()
                                .add(FeedUnfollowRequested(seller.id)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_rounded, size: 13),
                                SizedBox(width: 3),
                                Text('متابَق',
                                    style: TextStyle(fontSize: 11)),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () => context
                                .read<FeedBloc>()
                                .add(FeedFollowRequested(seller.id)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add_rounded, size: 13),
                                SizedBox(width: 3),
                                Text('متابعة',
                                    style: TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline_rounded,
                size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'لا يوجد مربّون حالياً',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'تعذّر تحميل المربّين',
              style: TextStyle(
                  fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
