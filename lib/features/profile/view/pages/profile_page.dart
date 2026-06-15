import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/profile_model.dart';
import '../../viewmodel/profile_bloc.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
            const SnackBar(
              content: Text('تم حذف الملف الشخصي'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (state.status == ProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'حدث خطأ'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == ProfileStatus.loading ||
            state.status == ProfileStatus.initial) {
          return const Scaffold(
            backgroundColor: AppColors.pageBackground,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == ProfileStatus.error && state.profile == null) {
          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              title: const Text('الملف الشخصي'),
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(state.errorMessage ?? 'حدث خطأ في تحميل الملف الشخصي'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ProfileBloc>()
                        .add(ProfileStarted(
                            state.profile?.type ?? 'Customer')),
                    child: const Text('إعادة المحاولة'),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusChips(profile: profile),
                      const SizedBox(height: 16),
                      _InfoCard(profile: profile),
                      const SizedBox(height: 16),
                      if (profile.isSeller) ...[
                        _RatingCard(profile: profile),
                        const SizedBox(height: 16),
                      ],
                      _EditButton(profile: profile),
                      const SizedBox(height: 80),
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
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: const Text('الملف الشخصي',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
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
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? const Icon(Icons.person_rounded,
                          color: Colors.white, size: 44)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  profile.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.isSeller ? 'بائع' : 'مشتري',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13),
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
  const _StatusChips({required this.profile});

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
          label: profile.isActive ? 'نشط' : 'غير نشط',
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

  Widget _chip(
      {required String label,
      required Color color,
      required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ProfileModel profile;
  const _InfoCard({required this.profile});

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
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          if ((profile.username ?? '').isNotEmpty) ...[
            _InfoRow(
              icon: Icons.alternate_email_rounded,
              label: 'اسم المستخدم',
              value: profile.username!,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
          ],
          _InfoRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'الرصيد',
            value:
                '${profile.balance.toStringAsFixed(2)} ${profile.currency}',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _InfoRow(
            icon: Icons.flag_outlined,
            label: 'الدولة',
            value: profile.countryName,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _InfoRow(
            icon: Icons.currency_exchange_outlined,
            label: 'العملة',
            value: profile.currency,
          ),
          if (profile.created != null) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
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

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final ProfileModel profile;
  const _RatingCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final avg = profile.avgRating ?? 0.0;
    final count = profile.ratingsCount ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
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
            child: const Icon(Icons.star_rounded,
                color: AppColors.orange, size: 28),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              Text(
                '$count تقييم',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final filled = i < avg.floor();
              final half = !filled && i < avg;
              return Icon(
                half
                    ? Icons.star_half_rounded
                    : (filled
                        ? Icons.star_rounded
                        : Icons.star_border_rounded),
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

class _EditButton extends StatelessWidget {
  final ProfileModel profile;
  const _EditButton({required this.profile});

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
                child: const EditProfilePage(),
              ),
            ),
          );
          if (updated == true && context.mounted) {
            final profileType =
                context.read<ProfileBloc>().state.profile?.type ??
                    'Customer';
            context
                .read<ProfileBloc>()
                .add(ProfileStarted(profileType));
          }
        },
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text('تعديل الملف الشخصي'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
