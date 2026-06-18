import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../viewmodel/feed_bloc.dart';

class PeopleYouMayKnowPage extends StatefulWidget {
  const PeopleYouMayKnowPage({super.key});

  @override
  State<PeopleYouMayKnowPage> createState() => _PeopleYouMayKnowPageState();
}

class _PeopleYouMayKnowPageState extends State<PeopleYouMayKnowPage> {
  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(const FeedSuggestionsRefreshed());
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'مربيون قد تعرفهم',
          style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => context
                .read<FeedBloc>()
                .add(const FeedSuggestionsRefreshed()),
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
            p.suggestions != c.suggestions ||
            p.followedSellerIds != c.followedSellerIds ||
            p.status != c.status,
        builder: (context, state) {
          if (state.suggestions.isEmpty &&
              state.status == FeedStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.suggestions.isEmpty) {
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
                      child: const Icon(Icons.person_search_rounded,
                          color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد اقتراحات حالياً',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'تابع بائعين لتحصل على اقتراحات مشابهة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: state.suggestions.length,
            itemBuilder: (context, i) {
              final seller = state.suggestions[i];
              final isFollowing =
                  state.followedSellerIds.contains(seller.id);
              return _SuggestionCard(
                seller: seller,
                isFollowing: isFollowing,
              );
            },
          );
        },
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final dynamic seller;
  final bool isFollowing;

  const _SuggestionCard({
    required this.seller,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: Text(
                  seller.nickname.isNotEmpty ? seller.nickname[0] : '؟',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
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
                const SizedBox(height: 3),
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
                            side:
                                const BorderSide(color: AppColors.border),
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
    );
  }
}
