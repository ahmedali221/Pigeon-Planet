import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

import '../../../../l10n/app_localizations.dart';
class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) =>
          curr.status == ProfileStatus.deleted ||
          (curr.status == ProfileStatus.error &&
              prev.status == ProfileStatus.deleting),
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
        if (state.status == ProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? AppLocalizations.of(context).errorOccurred),
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
            appBar: PPWAppBar(
              title: AppLocalizations.of(context).profile,
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 12),
                  Text(state.errorMessage ?? 'حدث خطأ في تحميل الملف الشخصي'),
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
              _ProfileHeader(profile: profile),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusChips(profile: profile),
                      SizedBox(height: 12),
                      _LevelBadge(profile: profile),
                      SizedBox(height: 16),
                      _StatsCard(profile: profile),
                      SizedBox(height: 16),
                      _InfoCard(profile: profile),
                      SizedBox(height: 16),
                      if (profile.isSeller) ...[
                        _RatingCard(profile: profile),
                        SizedBox(height: 16),
                      ],
                      if (!profile.isSeller &&
                          ((profile.levelDiscountPercent ?? 0) > 0 ||
                              (profile.levelCashbackPercent ?? 0) > 0)) ...[
                        _BenefitsCard(profile: profile),
                        SizedBox(height: 16),
                      ],
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
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProfileModel profile;
  _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: Text(
        AppLocalizations.of(context).profile,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), AppColors.primary],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 44,
                        )
                      : null,
                ),
                SizedBox(height: 10),
                Text(
                  profile.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.isSeller ? 'بائع' : 'مشتري',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChips extends StatelessWidget {
  final ProfileModel profile;
  _StatusChips({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip(
          label: profile.activated ? 'مفعّل' : 'غير مفعّل',
          color: profile.activated ? Colors.green : Colors.orange,
          icon: profile.activated
              ? Icons.check_circle_outline
              : Icons.pending_outlined,
        ),
        _chip(
          label: profile.isActive ? AppLocalizations.of(context).statusActive : AppLocalizations.of(context).inactive,
          color: profile.isActive ? Colors.blue : Colors.grey,
          icon: profile.isActive
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
        _chip(
          label: profile.isValid ? 'صالح' : 'غير صالح',
          color: profile.isValid ? Colors.teal : Colors.red,
          icon: profile.isValid
              ? Icons.verified_outlined
              : Icons.block_outlined,
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          SizedBox(width: 4),
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
              label: 'رصيد الكاشباك',
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
            label: 'العملة',
            value: profile.currency,
          ),
          if (profile.created != null) ...[
            Divider(height: 1, indent: 16, endIndent: 16),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'تاريخ الانضمام',
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

  _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

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
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
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

class _RatingCard extends StatelessWidget {
  final ProfileModel profile;
  _RatingCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final avg = profile.avgRating ?? 0.0;
    final count = profile.ratingsCount ?? 0;
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_rounded,
              color: AppColors.orange,
              size: 28,
            ),
          ),
          SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$count تقييم',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final filled = i < avg.floor();
              final half = !filled && i < avg;
              return Icon(
                half
                    ? Icons.star_half_rounded
                    : (filled ? Icons.star_rounded : Icons.star_border_rounded),
                color: AppColors.orange,
                size: 20,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final ProfileModel profile;
  _LevelBadge({required this.profile});

  @override
  Widget build(BuildContext context) {
    final label = profile.isSeller
        ? profile.sellerLevelLabel
        : profile.customerLevelLabel;
    if (label == null || label.isEmpty) return SizedBox.shrink();
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: AppColors.primary, size: 15),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final ProfileModel profile;
  _StatsCard({required this.profile});

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
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatCell(
              icon: Icons.shopping_bag_outlined,
              label: 'الطلبات المكتملة',
              value: profile.completedOrdersCount.toString(),
              color: AppColors.blue,
            ),
            VerticalDivider(width: 1, thickness: 1),
            _StatCell(
              icon: Icons.person_add_alt_1_outlined,
              label: 'الدعوات الناجحة',
              value: profile.successfulInvitesCount.toString(),
              color: AppColors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  _StatCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
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
                label: 'خصم المستوى',
                value: '$discount%',
                color: AppColors.blue,
                icon: Icons.local_offer_outlined,
              ),
            ),
          if (discount > 0 && cashback > 0) SizedBox(width: 12),
          if (cashback > 0)
            Expanded(
              child: _BenefitChip(
                label: 'كاش باك المستوى',
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
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
