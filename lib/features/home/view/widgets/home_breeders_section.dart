import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../features/feed/view/pages/people_you_may_know_page.dart';
import '../../../../features/feed/viewmodel/feed_bloc.dart';
import '../../model/seller_model.dart';
import '../pages/breeder_profile_page.dart';

import '../../../../l10n/app_localizations.dart';
class HomeBreedersSection extends StatelessWidget {
  final List<SellerModel> sellers;

  HomeBreedersSection({super.key, required this.sellers});

  @override
  Widget build(BuildContext context) {
    if (sellers.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.people_rounded,
                    color: AppColors.primary, size: 18),
              ),
              SizedBox(width: 8),
              Text(
                'مربيون قد تعرفهم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<FeedBloc>(),
                      child: PeopleYouMayKnowPage(),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).all,
                      style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_left_rounded,
                        color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12),

        // ── Horizontal list ────────────────────────────────────────────────
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: sellers.length,
            itemBuilder: (context, i) => _BreederCard(seller: sellers[i]),
          ),
        ),
      ],
    );
  }
}

// ── Breeder card ──────────────────────────────────────────────────────────────
class _BreederCard extends StatelessWidget {
  final SellerModel seller;

  _BreederCard({required this.seller});

  @override
  Widget build(BuildContext context) {
    final s = seller;
    final hasNew = s.activeAuctionsCount > 0;

    return BlocBuilder<FeedBloc, FeedState>(
      buildWhen: (prev, curr) =>
          prev.followedSellerIds.contains(s.id) !=
          curr.followedSellerIds.contains(s.id),
      builder: (context, feedState) {
        final isFollowing = feedState.followedSellerIds.contains(s.id);

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<FeedBloc>(),
                child: BreederProfilePage(seller: s),
              ),
            ),
          ),
          child: Container(
            width: 160,
            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Gradient header ──────────────────────────────────────────
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.85),
                        AppColors.primary.withValues(alpha: 0.55),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -10,
                        left: -10,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.07),
                          ),
                        ),
                      ),
                      if (hasNew)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              AppLocalizations.of(context).newAuction,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      // avatar — bottom centre, overflowing
                      Positioned(
                        bottom: -24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage: (s.avatarUrl != null && s.avatarUrl!.isNotEmpty)
                                  ? NetworkImage(s.avatarUrl!) as ImageProvider
                                  : null,
                              child: (s.avatarUrl == null || s.avatarUrl!.isEmpty)
                                  ? Text(
                                      s.nickname.isNotEmpty
                                          ? s.nickname[0].toUpperCase()
                                          : 'م',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28),

                // ── Info ─────────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Text(
                        s.nickname,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        s.country,
                        style: TextStyle(
                            fontSize: 10, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 11, color: Colors.amber),
                          SizedBox(width: 2),
                          Text(
                            s.avgRating.toStringAsFixed(1),
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textHint),
                          ),
                          Container(
                            width: 3,
                            height: 3,
                            margin:
                                EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textHint,
                            ),
                          ),
                          Icon(Icons.gavel_rounded,
                              size: 10, color: AppColors.textHint),
                          SizedBox(width: 2),
                          Text(
                            '${s.activeAuctionsCount} مزاد',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Spacer(),

                // ── Follow button ─────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: isFollowing
                        ? OutlinedButton(
                            onPressed: () => context
                                .read<FeedBloc>()
                                .add(FeedUnfollowRequested(s.id)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side:
                                  BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.zero,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_rounded, size: 13),
                                SizedBox(width: 3),
                                Text(AppLocalizations.of(context).followed,
                                    style: TextStyle(fontSize: 11)),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () => context
                                .read<FeedBloc>()
                                .add(FeedFollowRequested(s.id)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.zero,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add_rounded, size: 13),
                                SizedBox(width: 3),
                                Text(AppLocalizations.of(context).follow,
                                    style: TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
