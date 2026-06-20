import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../../features/auth/viewmodel/auth_bloc.dart';
import '../../../../features/chat/view/pages/chat_room_page.dart';
import '../../../../features/chat/viewmodel/chat_bloc.dart';
import '../../../../features/feed/viewmodel/feed_bloc.dart';
import '../../../../features/ratings/view/widgets/ratings_section.dart';
import '../../model/seller_model.dart';

class BreederProfilePage extends StatelessWidget {
  final SellerModel seller;

  const BreederProfilePage({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final canRate = authState is AuthSuccess && authState.user.isCustomer;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: CustomScrollView(
        slivers: [
          // ── Hero app bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              BlocBuilder<FeedBloc, FeedState>(
                buildWhen: (p, c) =>
                    p.blockedProfileIds.contains(seller.id) !=
                    c.blockedProfileIds.contains(seller.id),
                builder: (context, state) {
                  final isBlocked =
                      state.blockedProfileIds.contains(seller.id);
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded,
                        color: Colors.white),
                    onSelected: (value) {
                      if (value == 'block') {
                        context
                            .read<FeedBloc>()
                            .add(FeedBlockRequested(seller.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم حظر هذا البائع'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else if (value == 'unblock') {
                        context
                            .read<FeedBloc>()
                            .add(FeedUnblockRequested(seller.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إلغاء الحظر'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: isBlocked ? 'unblock' : 'block',
                        child: Row(
                          children: [
                            Icon(
                              isBlocked
                                  ? Icons.lock_open_rounded
                                  : Icons.block_rounded,
                              size: 18,
                              color: isBlocked
                                  ? AppColors.primary
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isBlocked ? 'إلغاء الحظر' : 'حظر البائع',
                              style: TextStyle(
                                color: isBlocked
                                    ? AppColors.primary
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B5E20), AppColors.primary],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -30,
                    left: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    right: -20,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 44),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: (seller.avatarUrl != null && seller.avatarUrl!.isNotEmpty)
                                ? NetworkImage(seller.avatarUrl!) as ImageProvider
                                : null,
                            child: (seller.avatarUrl == null || seller.avatarUrl!.isEmpty)
                                ? Text(
                                    seller.nickname.isNotEmpty
                                        ? seller.nickname[0].toUpperCase()
                                        : 'م',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          seller.nickname,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (seller.username.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '@${seller.username}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              seller.country.isNotEmpty
                                  ? seller.country
                                  : 'غير محدد',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Stats bar ───────────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatCell(
                        value: seller.ratingsCount.toString(),
                        label: 'تقييم',
                        icon: Icons.star_rounded,
                        iconColor: Colors.amber,
                      ),
                      _divider(),
                      _StatCell(
                        value: seller.activeAuctionsCount.toString(),
                        label: 'مزاد نشط',
                        icon: Icons.gavel_rounded,
                        iconColor: AppColors.primary,
                      ),
                      _divider(),
                      _StatCell(
                        value: seller.avgRating.toStringAsFixed(1),
                        label: 'متوسط التقييم',
                        icon: Icons.grade_rounded,
                        iconColor: Colors.orange,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Follow button ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _FollowButton(sellerId: seller.id),
                ),

                const SizedBox(height: 10),

                // ── Chat button (customers only) ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ChatButton(
                    sellerId: seller.id,
                    sellerNickname: seller.nickname,
                  ),
                ),

                const SizedBox(height: 16),

                // ── About section ────────────────────────────────────────────
                _SectionCard(
                  title: 'نبذة عن المربي',
                  icon: Icons.info_outline_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seller.country.isNotEmpty
                            ? 'مربي محترف من ${seller.country}'
                            : 'لا توجد معلومات إضافية',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Tag(label: 'حمام زاجل'),
                          _Tag(label: 'مربي محترف'),
                          _Tag(label: 'مزادات'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Recent auctions ───────────────────────────────────────────
                _SectionCard(
                  title: 'مزادات المربي',
                  icon: Icons.gavel_rounded,
                  trailing: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'الكل',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.chevron_left_rounded, size: 16),
                      ],
                    ),
                  ),
                  child: Column(
                    children: List.generate(
                      2,
                      (i) => _AuctionPlaceholderTile(
                        index: i,
                        seed: seller.id + i,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Ratings ──────────────────────────────────────────────────
                _SectionCard(
                  title: 'التقييمات',
                  icon: Icons.star_outline_rounded,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            seller.avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 46,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'من 5',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < seller.avgRating.floor()
                                    ? Icons.star_rounded
                                    : (i < seller.avgRating
                                          ? Icons.star_half_rounded
                                          : Icons.star_border_rounded),
                                color: Colors.amber,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'بناءً على ${seller.ratingsCount} تقييم',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                _SectionCard(
                  title: 'Ø§Ù„Ø¢Ø±Ø§Ø¡ ÙˆØ§Ù„ØªØ¹Ù„ÙŠÙ‚Ø§Øª',
                  icon: Icons.rate_review_outlined,
                  child: RatingsSection(
                    targetType: RatingTargetType.seller,
                    targetId: seller.id,
                    canRate: canRate,
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 40, color: AppColors.border);
}

// ── Follow button ─────────────────────────────────────────────────────────────
class _FollowButton extends StatelessWidget {
  final int sellerId;
  const _FollowButton({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      buildWhen: (p, c) =>
          p.followedSellerIds.contains(sellerId) !=
          c.followedSellerIds.contains(sellerId),
      builder: (context, state) {
        final isFollowing = state.followedSellerIds.contains(sellerId);
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: isFollowing
              ? OutlinedButton.icon(
                  onPressed: () => context
                      .read<FeedBloc>()
                      .add(FeedUnfollowRequested(sellerId)),
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: const Text(
                    'تتابع الآن',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: () => context
                      .read<FeedBloc>()
                      .add(FeedFollowRequested(sellerId)),
                  icon: const Icon(Icons.person_add_rounded, size: 20),
                  label: const Text(
                    'متابعة',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

// ── Chat button ───────────────────────────────────────────────────────────────
class _ChatButton extends StatelessWidget {
  final int sellerId;
  final String sellerNickname;

  const _ChatButton({required this.sellerId, required this.sellerNickname});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isSeller = authState is AuthSuccess && authState.user.isSeller;
    if (isSeller) return const SizedBox.shrink();

    final isFollowing = context.select<FeedBloc, bool>(
      (bloc) => bloc.state.followedSellerIds.contains(sellerId),
    );

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: isFollowing
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => sl<ChatBloc>()
                            ..add(const ChatStarted(profileType: 'Customer')),
                          child: ChatRoomPage(
                            receiverProfileId: sellerId,
                            partnerNickname: sellerNickname,
                          ),
                        ),
                      ),
                    )
                : () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يجب متابعة البائع أولاً للتواصل معه'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    ),
            icon: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 20,
              color: isFollowing ? AppColors.primary : AppColors.textHint,
            ),
            label: Text(
              'تواصل مع البائع',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isFollowing ? AppColors.primary : AppColors.textHint,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  isFollowing ? AppColors.primary : AppColors.textHint,
              side: BorderSide(
                color: isFollowing ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        if (!isFollowing)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'تابع هذا البائع للتواصل معه',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ),
      ],
    );
  }
}

// ── Stat cell ─────────────────────────────────────────────────────────────────
class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _StatCell({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(icon, size: 16, color: AppColors.primary),
                const Spacer(),
                ?trailing,
              ],
            ),
            const SizedBox(height: 4),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Auction placeholder tile ──────────────────────────────────────────────────
class _AuctionPlaceholderTile extends StatelessWidget {
  final int index;
  final int seed;
  const _AuctionPlaceholderTile({required this.index, required this.seed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  index == 0 ? 'مزاد زاجل بلجيكي' : 'مزاد زوج تربية',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  index == 0 ? 'سعر مبدئي: ج.م 5,000' : 'سعر مبدئي: ج.م 12,000',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.primaryLight,
              child: const Icon(
                Icons.flutter_dash,
                color: AppColors.primary,
                  size: 28,
                ),
              ),
          ),
        ],
      ),
    );
  }
}

// ── Tag chip ──────────────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
