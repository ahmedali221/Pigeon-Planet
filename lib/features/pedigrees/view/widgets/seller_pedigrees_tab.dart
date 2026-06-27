import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../model/pedigree_tree_model.dart';
import '../../viewmodel/pedigree_tree_cubit.dart';
import '../pages/loft_bird_detail_page.dart';
import '../pages/pedigree_tree_add_page.dart';

class SellerPedigreesTab extends StatelessWidget {
  const SellerPedigreesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedigreeTreeCubit, PedigreeTreeState>(
      builder: (context, state) {
        final cubit = context.read<PedigreeTreeCubit>();
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: const PPWAppBar(title: 'برنامج اللوفت'),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: const PedigreeTreeAddPage(),
                ),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة طائر'),
            backgroundColor: AppColors.purple,
            foregroundColor: Colors.white,
          ),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
            child: LoftBirdDetailPage(treeKey: bird.ringNumber),
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
              // Gender icon circle
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
              // Bird info
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
                      Text(
                        bird.owner!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (bird.breed != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        bird.breed!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 20),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.purpleLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_tree_rounded,
                  color: AppColors.purple, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد طيور',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أضف طيورك وأشجار نسبها لعرضها هنا',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
