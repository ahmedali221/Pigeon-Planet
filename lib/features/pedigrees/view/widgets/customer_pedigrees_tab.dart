import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../model/pedigree_tree_model.dart' show PedigreeNode;
import '../../viewmodel/pedigree_tree_cubit.dart';
import '../pages/loft_bird_detail_page.dart';

class CustomerPedigreesTab extends StatelessWidget {
  const CustomerPedigreesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedigreeTreeCubit, PedigreeTreeState>(
      builder: (context, state) {
        final cubit = context.read<PedigreeTreeCubit>();
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: const PPWAppBar(title: 'شهادات النسب'),
          body: state.birds.isEmpty
              ? const _EmptyState()
              : _BirdList(birds: state.birds, cubit: cubit),
        );
      },
    );
  }
}

// ── Bird list ─────────────────────────────────────────────────────────────────

class _BirdList extends StatelessWidget {
  final List<PedigreeNode> birds;
  final PedigreeTreeCubit cubit;

  const _BirdList({required this.birds, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: birds.length,
      itemBuilder: (context, i) =>
          _BirdTile(bird: birds[i], cubit: cubit),
    );
  }
}

class _BirdTile extends StatelessWidget {
  final PedigreeNode bird;
  final PedigreeTreeCubit cubit;

  const _BirdTile({required this.bird, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final genderColor = bird.gender == 'male'
        ? AppColors.blue
        : bird.gender == 'female'
            ? AppColors.purple
            : AppColors.primary;

    final genderIcon = bird.gender == 'male'
        ? Icons.male_rounded
        : bird.gender == 'female'
            ? Icons.female_rounded
            : Icons.flutter_dash;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: LoftBirdDetailPage(
              treeKey: bird.ringNumber,
              isReadOnly: true,
            ),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: genderColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(genderIcon, color: genderColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bird.name ?? bird.ringNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      bird.ringNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (bird.owner != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded,
                              size: 12, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(
                            bird.owner!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'عرض النسب',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.purpleLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.purple,
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'اكتشف الطيور الموثّقة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'يمكنك الاطلاع على شهادة نسب أي طائر من خلال صفحة تفاصيله',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 36),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'كيفية الوصول',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _HowToCard(
            icon: Icons.gavel_rounded,
            color: AppColors.orange,
            title: 'من تفاصيل المزاد',
            description:
                'افتح تفاصيل أي مزاد واضغط على زر "عرض شهادة النسب"',
          ),
          const SizedBox(height: 10),
          const _HowToCard(
            icon: Icons.credit_card_rounded,
            color: AppColors.blue,
            title: 'من بطاقة الطائر',
            description: 'افتح بطاقة الطائر واضغط على زر "شهادة النسب"',
          ),
          const SizedBox(height: 10),
          const _HowToCard(
            icon: Icons.verified_rounded,
            color: AppColors.success,
            title: 'الطيور الموثّقة',
            description:
                'شهادات النسب الموثّقة تظهر بشارة خضراء على بطاقة الطائر',
          ),
        ],
      ),
    );
  }
}

class _HowToCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _HowToCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
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
