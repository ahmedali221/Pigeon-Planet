import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../../../core/di/injection.dart';
import '../../../complaints/view/pages/complaints_page.dart';
import '../../../payments/view/pages/payments_page.dart';
import '../../../pedigrees/view/pages/pedigrees_page.dart';
import '../../../feed/view/pages/following_page.dart';
import '../../../feed/viewmodel/feed_bloc.dart';
import '../../../promotions/view/pages/cashback_history_page.dart';
import '../../../promotions/view/pages/promotions_offers_page.dart';
import '../../model/profile_model.dart';
import '../../viewmodel/profile_bloc.dart';
import 'edit_profile_page.dart';
import '../../../notifications/view/pages/notifications_page.dart';

import '../../../../l10n/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  final int unreadNotificationCount;
  ProfilePage({super.key, this.unreadNotificationCount = 0});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) =>
          curr.status == ProfileStatus.deleted ||
          curr.status == ProfileStatus.photoUpdated ||
          (curr.status == ProfileStatus.error &&
              (prev.status == ProfileStatus.deleting ||
                  prev.status == ProfileStatus.photoUploading)),
      listener: (context, state) {
        if (state.status == ProfileStatus.deleted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).profileDeletedSuccess),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (state.status == ProfileStatus.photoUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث صورة الملف الشخصي'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (state.status == ProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ??
                    AppLocalizations.of(context).errorOccurred,
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == ProfileStatus.loading ||
            state.status == ProfileStatus.initial) {
          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == ProfileStatus.error && state.profile == null) {
          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            appBar: PPWAppBar(title: AppLocalizations.of(context).profile),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 12),
                  Text(
                    state.errorMessage ?? AppLocalizations.of(context).loading8,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileBloc>().add(
                      ProfileStarted(state.profile?.type ?? 'Customer'),
                    ),
                    child: Text(AppLocalizations.of(context).retry),
                  ),
                ],
              ),
            ),
          );
        }
        final profile = state.profile!;
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: CustomScrollView(
            slivers: [
              _ProfileHeader(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _GreenAvatarHeader(
                      profile: profile,
                      isUploading:
                          state.status == ProfileStatus.photoUploading,
                      onEditPhoto: () async {
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );
                        if (picked == null || !context.mounted) return;
                        context.read<ProfileBloc>().add(
                          ProfilePhotoUpdateRequested(
                            profileId: profile.id,
                            profileType: profile.type,
                            filePath: picked.path,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: _GreenAvatarHeader.avatarRadius + 20),
                    _ProfileNameSection(profile: profile),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          if (profile.isSeller) ...[
                            _RatingStatsCard(profile: profile),
                            SizedBox(height: 16),
                          ],
                          _InfoCard(profile: profile),
                          SizedBox(height: 16),
                          if (!profile.isSeller &&
                              ((profile.levelDiscountPercent ?? 0) > 0 ||
                                  (profile.levelCashbackPercent ?? 0) > 0)) ...[
                            _BenefitsCard(profile: profile),
                            SizedBox(height: 16),
                          ],
                          _NotificationsNavTile(
                            unreadCount: unreadNotificationCount,
                          ),
                          SizedBox(height: 12),
                          _PaymentsNavTile(),
                          SizedBox(height: 12),
                          _ComplaintsNavTile(),
                          SizedBox(height: 12),
                          if (!profile.isSeller) ...[
                            _CashbackHistoryNavTile(),
                            SizedBox(height: 12),
                            _PromotionsOffersNavTile(),
                            SizedBox(height: 12),
                            _FollowingNavTile(),
                            SizedBox(height: 12),
                          ],
                          _PedigreesNavTile(),
                          SizedBox(height: 12),
                          _EditButton(profile: profile),
                          SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: Text(
        AppLocalizations.of(context).profile,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _GreenAvatarHeader extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback? onEditPhoto;
  final bool isUploading;
  _GreenAvatarHeader({
    required this.profile,
    this.onEditPhoto,
    this.isUploading = false,
  });

  static const double barHeight = 130;
  static const double avatarRadius = 70;

  @override
  Widget build(BuildContext context) {
    final levelLabel = profile.isSeller
        ? profile.sellerLevelLabel
        : profile.customerLevelLabel;
    final avatarUrl = profile.avatarUrl?.trim();
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return SizedBox(
      height: barHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Green gradient bar — fills the full SizedBox height
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), AppColors.primary],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
          // "تعديل الصورة" — bottom-start of green bar
          Positioned(
            bottom: 14,
            left: 16,
            child: GestureDetector(
              onTap: onEditPhoto,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'تعديل الصورة',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          // Avatar — center aligned at the bottom edge of the green bar,
          // extending below it (clipBehavior: Clip.none lets it overflow)
          Positioned(
            bottom: -avatarRadius,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: avatarRadius * 2,
                      height: avatarRadius * 2,
                      child: hasAvatar
                          ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: Colors.white.withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 74,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.white.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 74,
                              ),
                            ),
                    ),
                  ),
                ),
                // Level badge — bottom-right
                if (levelLabel != null && levelLabel.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    right: -6,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                // Verified badge — bottom-left
                if (profile.isValid)
                  Positioned(
                    bottom: 0,
                    left: -6,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                // Camera edit button — bottom center
                Positioned(
                  bottom: -8,
                  child: GestureDetector(
                    onTap: isUploading ? null : onEditPhoto,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: isUploading
                          ? Padding(
                              padding: EdgeInsets.all(6),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
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

class _ProfileNameSection extends StatelessWidget {
  final ProfileModel profile;
  _ProfileNameSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final avg = profile.avgRating ?? 0.0;
    final ratingCount = profile.ratingsCount ?? 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          Text(
            profile.displayName,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if ((profile.username ?? '').isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              '@${profile.username}',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
          if (profile.isSeller && avg > 0) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  avg.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 6),
                ...List.generate(5, (i) {
                  final filled = i < avg.floor();
                  final half = !filled && i < avg;
                  return Icon(
                    half
                        ? Icons.star_half_rounded
                        : (filled
                              ? Icons.star_rounded
                              : Icons.star_border_rounded),
                    color: Colors.amber,
                    size: 17,
                  );
                }),
                SizedBox(width: 6),
                Text(
                  '($ratingCount تقييم)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatusChip(
                label: profile.isActive
                    ? AppLocalizations.of(context).statusActive
                    : AppLocalizations.of(context).inactive,
                icon: profile.isActive
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                color: profile.isActive ? Colors.green : Colors.grey,
              ),
              SizedBox(width: 10),
              _StatusChip(
                label: profile.isValid
                    ? AppLocalizations.of(context).salh
                    : AppLocalizations.of(context).ghyrSalh,
                icon: profile.isValid
                    ? Icons.verified_rounded
                    : Icons.cancel_outlined,
                color: profile.isValid ? Colors.blue : Colors.red,
              ),
            ],
          ),
          if ((profile.address ?? '').isNotEmpty) ...[
            SizedBox(height: 10),
            Text(
              profile.address!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  _StatusChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ProfileModel profile;
  _InfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if ((profile.username ?? '').isNotEmpty) ...[
            _InfoRow(
              icon: Icons.alternate_email_rounded,
              label: AppLocalizations.of(context).username,
              value: profile.username!,
            ),
            Divider(height: 1, indent: 16, endIndent: 16),
          ],
          if ((profile.phoneNumber ?? '').isNotEmpty) ...[
            _InfoRow(
              icon: Icons.phone_outlined,
              label: AppLocalizations.of(context).phoneNumber,
              value: profile.phoneNumber!,
            ),
            Divider(height: 1, indent: 16, endIndent: 16),
          ],
          if (!profile.isSeller) ...[
            _InfoRow(
              icon: Icons.account_balance_wallet_outlined,
              label: AppLocalizations.of(context).rsydAlkashbak,
              value:
                  '${(profile.cashbackBalance ?? 0.0).toStringAsFixed(2)} ${profile.currency}',
            ),
            Divider(height: 1, indent: 16, endIndent: 16),
          ],
          _InfoRow(
            icon: Icons.flag_outlined,
            label: AppLocalizations.of(context).country,
            value: profile.countryName,
          ),
          Divider(height: 1, indent: 16, endIndent: 16),
          _InfoRow(
            icon: Icons.currency_exchange_outlined,
            label: AppLocalizations.of(context).alamla2,
            value: profile.currency,
          ),
          if (profile.created != null) ...[
            Divider(height: 1, indent: 16, endIndent: 16),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: AppLocalizations.of(context).no19,
              value:
                  '${profile.created!.year}-${profile.created!.month.toString().padLeft(2, '0')}-${profile.created!.day.toString().padLeft(2, '0')}',
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingStatsCard extends StatelessWidget {
  final ProfileModel profile;
  _RatingStatsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final avg = profile.avgRating ?? 0.0;
    final count = profile.ratingsCount ?? 0;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 26),
                  SizedBox(height: 8),
                  Text(
                    avg.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'متوسط التقييم',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  SizedBox(height: 8),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'عدد التقييمات',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
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

class _BenefitsCard extends StatelessWidget {
  final ProfileModel profile;
  _BenefitsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final discount = profile.levelDiscountPercent ?? 0;
    final cashback = profile.levelCashbackPercent ?? 0;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (discount > 0)
            Expanded(
              child: _BenefitChip(
                label: AppLocalizations.of(context).khsmAlmstwa,
                value: '$discount%',
                color: AppColors.blue,
                icon: Icons.local_offer_outlined,
              ),
            ),
          if (discount > 0 && cashback > 0) SizedBox(width: 12),
          if (cashback > 0)
            Expanded(
              child: _BenefitChip(
                label: AppLocalizations.of(context).kashBakAlmstwa,
                value: '$cashback%',
                color: AppColors.primary,
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
        ],
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  _BenefitChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationsNavTile extends StatelessWidget {
  final int unreadCount;
  _NotificationsNavTile({this.unreadCount = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NotificationsPage()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.orange,
                    size: 20,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                AppLocalizations.of(context).notifications,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentsNavTile extends StatelessWidget {
  _PaymentsNavTile();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PaymentsPage()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.payment_rounded,
                color: AppColors.blue,
                size: 20,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                AppLocalizations.of(context).paymentRequests,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplaintsNavTile extends StatelessWidget {
  _ComplaintsNavTile();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ComplaintsPage()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.report_problem_outlined,
                color: AppColors.orange,
                size: 20,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'الشكاوى',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _PedigreesNavTile extends StatelessWidget {
  _PedigreesNavTile();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PedigreesPage()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.purpleLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_rounded,
                color: AppColors.purple,
                size: 20,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'شهادات النسب',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowingNavTile extends StatelessWidget {
  _FollowingNavTile();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<FeedBloc>()..add(FeedStarted()),
            child: FollowingPage(),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'من أتابع',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionsOffersNavTile extends StatelessWidget {
  _PromotionsOffersNavTile();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PromotionsOffersPage()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'العروض والتخفيضات',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _CashbackHistoryNavTile extends StatelessWidget {
  _CashbackHistoryNavTile();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CashbackHistoryPage()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'سجل الكاش باك',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final ProfileModel profile;
  _EditButton({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final updated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ProfileBloc>(),
                child: EditProfilePage(),
              ),
            ),
          );
          if (updated == true && context.mounted) {
            final profileType =
                context.read<ProfileBloc>().state.profile?.type ?? 'Customer';
            context.read<ProfileBloc>().add(ProfileStarted(profileType));
          }
        },
        icon: Icon(Icons.edit_outlined, size: 18),
        label: Text(AppLocalizations.of(context).editProfile),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
