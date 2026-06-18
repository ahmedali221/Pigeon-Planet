import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/feed_auction_item_model.dart';
import '../../viewmodel/feed_bloc.dart';
import 'following_page.dart';
import 'people_you_may_know_page.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'مزادات المتابعين',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.people_outline_rounded,
                  color: Colors.white),
              tooltip: 'من أتابع',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<FeedBloc>(),
                    child: const FollowingPage(),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person_search_rounded,
                  color: Colors.white),
              tooltip: 'اقتراحات',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<FeedBloc>(),
                    child: const PeopleYouMayKnowPage(),
                  ),
                ),
              ),
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
              p.status != c.status ||
              p.auctionFeed != c.auctionFeed ||
              p.auctionLoadingMore != c.auctionLoadingMore,
          builder: (context, state) {
            if (state.status == FeedStatus.loading ||
                state.status == FeedStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == FeedStatus.error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage ?? 'حدث خطأ',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<FeedBloc>().add(const FeedStarted()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state.auctionFeed.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.gavel_rounded,
                            color: AppColors.primary, size: 36),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد مزادات بعد',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'تابع بائعين لترى مزاداتهم هنا أولاً',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<FeedBloc>(),
                              child: const PeopleYouMayKnowPage(),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.person_add_rounded, size: 16),
                        label: const Text('اكتشف بائعين'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200 &&
                    state.auctionHasMore &&
                    !state.auctionLoadingMore) {
                  context
                      .read<FeedBloc>()
                      .add(const FeedAuctionNextPageRequested());
                }
                return false;
              },
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: state.auctionFeed.length +
                    (state.auctionLoadingMore ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == state.auctionFeed.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _AuctionFeedCard(item: state.auctionFeed[i]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuctionFeedCard extends StatelessWidget {
  final FeedAuctionItemModel item;

  const _AuctionFeedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isFollowing = item.source == 'following';
    final seconds = item.timeRemaining ?? 0;
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final timeLabel = h > 0 ? '$h س $m د' : '$m دقيقة';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail header
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: item.thumbnailUrl != null
                  ? Image.network(
                      item.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isFollowing
                            ? AppColors.primaryLight
                            : AppColors.orangeLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isFollowing ? 'متابَق' : 'اكتشاف',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isFollowing
                              ? AppColors.primary
                              : AppColors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person_rounded,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      item.sellerNickname,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time_rounded,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      timeLabel,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.currentPrice.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.primaryLight,
        child: const Center(
          child: Icon(Icons.image_rounded,
              color: AppColors.primary, size: 40),
        ),
      );
}
