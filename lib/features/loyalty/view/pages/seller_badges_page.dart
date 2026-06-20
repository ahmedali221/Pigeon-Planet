import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../model/badge_model.dart';
import '../../viewmodel/badges_bloc.dart';

class SellerBadgesPage extends StatelessWidget {
  const SellerBadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BadgesBloc>()..add(const BadgesLoadRequested()),
      child: const _SellerBadgesView(),
    );
  }
}

class _SellerBadgesView extends StatelessWidget {
  const _SellerBadgesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: BlocBuilder<BadgesBloc, BadgesState>(
        builder: (context, state) {
          return NestedScrollView(
            headerSliverBuilder: (_, _) => [
              SliverAppBar(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                title: Text(
                  state.badges.isNotEmpty
                      ? 'الأوسمة (${state.badges.length})'
                      : 'الأوسمة',
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
                        .read<BadgesBloc>()
                        .add(const BadgesLoadRequested()),
                  ),
                ],
              ),
            ],
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, BadgesState state) {
    if (state.status == BadgesStatus.loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state.status == BadgesStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'حدث خطأ في تحميل الأوسمة',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context
                    .read<BadgesBloc>()
                    .add(const BadgesLoadRequested()),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('إعادة المحاولة',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    if (state.badges.isEmpty) {
      return const _EmptyBadges();
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          context.read<BadgesBloc>().add(const BadgesLoadRequested()),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: state.badges.length,
        itemBuilder: (context, i) => _BadgeCard(badge: state.badges[i]),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyBadges extends StatelessWidget {
  const _EmptyBadges();

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
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.military_tech_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد أوسمة بعد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أكمل صفقاتك وتفاعل مع المنصة لتحصل على أوسمة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge card ────────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  final BadgeModel badge;

  const _BadgeCard({required this.badge});

  IconData _iconForKey(String key) {
    switch (key) {
      case 'first_order':
        return Icons.shopping_bag_rounded;
      case 'points_starter':
        return Icons.stars_rounded;
      case 'seller_starter':
        return Icons.storefront_rounded;
      default:
        return Icons.military_tech_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3), width: 2),
              ),
              child: badge.iconUrl != null && badge.iconUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        badge.iconUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          _iconForKey(badge.key),
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Icon(
                      _iconForKey(badge.key),
                      size: 32,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              badge.name.isNotEmpty ? badge.name : badge.key,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (badge.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                badge.description,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
