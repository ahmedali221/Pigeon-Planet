import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../model/seller_package_follow_model.dart';
import '../../viewmodel/feed_bloc.dart';

import '../../../../l10n/app_localizations.dart';
class FollowingPage extends StatelessWidget {
  FollowingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: const PPWAppBar(
        title: 'من أتابع',
      ),
      body: BlocBuilder<FeedBloc, FeedState>(
        buildWhen: (p, c) =>
            p.following != c.following ||
            p.followedSellerIds != c.followedSellerIds ||
            p.followingPackages != c.followingPackages ||
            p.followedPackageIds != c.followedPackageIds ||
            p.status != c.status,
        builder: (context, state) {
          if (state.status == FeedStatus.loading ||
              state.status == FeedStatus.initial) {
            return Center(child: CircularProgressIndicator());
          }
          if (state.following.isEmpty && state.followingPackages.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32),
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
                      child: Icon(Icons.people_outline_rounded,
                          color: AppColors.primary, size: 36),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'لا تتابع أحداً بعد',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ابحث عن مربيين وتابعهم لترى مزاداتهم ومنتجاتهم أولاً',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // ── Followed sellers ──────────────────────────────────────
              if (state.following.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.people_rounded,
                  label: 'المربّون المتابَعون (${state.following.length})',
                ),
                SizedBox(height: 10),
                ...state.following.map((follow) {
                  final seller = follow.seller;
                  final isFollowing =
                      state.followedSellerIds.contains(seller.id);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage: seller.avatarUrl != null
                                  ? NetworkImage(seller.avatarUrl!)
                                  : null,
                              child: seller.avatarUrl == null
                                  ? Text(
                                      seller.nickname.isNotEmpty
                                          ? seller.nickname[0]
                                          : '؟',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    seller.nickname,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary),
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.star_rounded,
                                          size: 12, color: Colors.amber),
                                      SizedBox(width: 3),
                                      Text(
                                        seller.avgRating.toStringAsFixed(1),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        seller.country,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () =>
                                  context.read<FeedBloc>().add(
                                        FeedUnfollowRequested(seller.id),
                                      ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isFollowing
                                    ? AppColors.textSecondary
                                    : AppColors.primary,
                                side: BorderSide(
                                  color: isFollowing
                                      ? AppColors.border
                                      : AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                isFollowing
                                    ? AppLocalizations.of(context).followed
                                    : AppLocalizations.of(context).follow,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],

              // ── Followed packages ─────────────────────────────────────
              if (state.followingPackages.isNotEmpty) ...[
                if (state.following.isNotEmpty) SizedBox(height: 8),
                _SectionHeader(
                  icon: Icons.inventory_2_rounded,
                  label: 'الباقات المتابَعة (${state.followingPackages.length})',
                  color: AppColors.purple,
                ),
                SizedBox(height: 10),
                ...state.followingPackages.map((pkg) =>
                    _PackageFollowTile(pkg: pkg)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  _SectionHeader({
    required this.icon,
    required this.label,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PackageFollowTile extends StatelessWidget {
  final SellerPackageFollowModel pkg;

  _PackageFollowTile({required this.pkg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.purpleLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.inventory_2_rounded,
                    color: AppColors.purple, size: 22),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pkg.packageName,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    if (pkg.sellerNickname.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        pkg.sellerNickname,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => context.read<FeedBloc>().add(
                      FeedPackageUnfollowRequested(pkg.packageId),
                    ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppLocalizations.of(context).followed,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
