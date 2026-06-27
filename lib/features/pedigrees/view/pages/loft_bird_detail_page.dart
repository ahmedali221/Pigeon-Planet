import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../model/pedigree_tree_model.dart';
import '../../viewmodel/pedigree_tree_cubit.dart';
import '../widgets/pedigree_node_detail_sheet.dart';
import 'pedigree_tree_add_page.dart';
import 'pedigree_tree_page.dart';

// Shows a single bird's ancestor list + link to the visual tree canvas.
class LoftBirdDetailPage extends StatelessWidget {
  final String treeKey; // = root bird ring number
  final bool isReadOnly;

  const LoftBirdDetailPage({
    super.key,
    required this.treeKey,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedigreeTreeCubit, PedigreeTreeState>(
      builder: (context, state) {
        final tree = state.trees[treeKey];
        final cubit = context.read<PedigreeTreeCubit>();
        final root = tree?.nodes[''];

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: PPWAppBar(title: root?.name ?? treeKey),
          floatingActionButton: isReadOnly
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: PedigreeTreeAddPage(
                          existingTreeKey: treeKey,
                          existingTree: tree,
                        ),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('تعديل النسب'),
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                ),
          body: tree == null
              ? const Center(
                  child: Text(
                    'لم يتم العثور على شجرة النسب',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : _BirdDetailBody(
                  tree: tree,
                  treeKey: treeKey,
                  isReadOnly: isReadOnly,
                  cubit: cubit,
                ),
        );
      },
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _BirdDetailBody extends StatelessWidget {
  final PedigreeTree tree;
  final String treeKey;
  final bool isReadOnly;
  final PedigreeTreeCubit cubit;

  const _BirdDetailBody({
    required this.tree,
    required this.treeKey,
    required this.isReadOnly,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final maxGen = tree.maxGeneration;
    final root = tree.nodes[''];

    final items = <Widget>[
      // ── Metadata summary card ────────────────────────────────────
      _MetaCard(tree: tree, root: root),
      const SizedBox(height: 12),
      _ViewTreeBanner(treeKey: treeKey, cubit: cubit, isReadOnly: isReadOnly),
      const SizedBox(height: 20),
    ];

    for (int gen = 0; gen <= maxGen; gen++) {
      final nodes = tree.nodesForGeneration(gen)
        ..sort((a, b) => PedigreeNode.slotIndex(a.position)
            .compareTo(PedigreeNode.slotIndex(b.position)));
      if (nodes.isEmpty) continue;
      items.add(_GenSectionHeader(gen: gen));
      items.add(const SizedBox(height: 8));
      for (final node in nodes) {
        items.add(_AncestorTile(
          node: node,
          treeKey: treeKey,
          isReadOnly: isReadOnly,
          cubit: cubit,
        ));
        items.add(const SizedBox(height: 10));
      }
      items.add(const SizedBox(height: 6));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: items,
    );
  }
}

// ── Metadata summary card ─────────────────────────────────────────────────────

class _MetaCard extends StatelessWidget {
  final PedigreeTree tree;
  final PedigreeNode? root;

  const _MetaCard({required this.tree, required this.root});

  @override
  Widget build(BuildContext context) {
    final ancestorCount = tree.nodes.length - 1; // exclude root
    final maxGen = tree.maxGeneration;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ring number
          Row(
            children: [
              const Icon(Icons.tag_rounded, size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  root?.ringNumber ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              if (root?.gender != null)
                Icon(
                  root!.gender == 'male'
                      ? Icons.male_rounded
                      : Icons.female_rounded,
                  size: 18,
                  color: root!.gender == 'male'
                      ? AppColors.blue
                      : AppColors.purple,
                ),
            ],
          ),
          if (root?.name != null) ...[
            const SizedBox(height: 6),
            Text(
              root!.name!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          const Divider(height: 20),
          // Stats column
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatChip(
                icon: Icons.account_tree_rounded,
                label: 'الأجيال',
                value: '$maxGen',
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              _StatChip(
                icon: Icons.people_outline_rounded,
                label: 'الأسلاف',
                value: '$ancestorCount',
                color: AppColors.blue,
              ),
              if (root?.owner != null) ...[
                const SizedBox(height: 8),
                _StatChip(
                  icon: Icons.person_outline_rounded,
                  label: 'المربّي',
                  value: root!.owner!,
                  color: AppColors.purple,
                ),
              ],
              if (root?.breed != null) ...[
                const SizedBox(height: 8),
                _StatChip(
                  icon: Icons.category_outlined,
                  label: 'السلالة',
                  value: root!.breed!,
                  color: AppColors.orange,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── View tree canvas banner ───────────────────────────────────────────────────

class _ViewTreeBanner extends StatelessWidget {
  final String treeKey;
  final PedigreeTreeCubit cubit;
  final bool isReadOnly;

  const _ViewTreeBanner({
    required this.treeKey,
    required this.cubit,
    required this.isReadOnly,
  });

  @override
  Widget build(BuildContext context) {
    final tree = context.read<PedigreeTreeCubit>().state.trees[treeKey];
    final nodeCount = tree?.nodes.length ?? 0;
    final maxGen = tree?.maxGeneration ?? 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: PedigreeTreePage(treeKey: treeKey, isReadOnly: isReadOnly),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF2B8A3E)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_tree_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'عرض شجرة النسب كاملة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$nodeCount سلف • حتى الجيل $maxGen',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}

// ── Generation section header ─────────────────────────────────────────────────

class _GenSectionHeader extends StatelessWidget {
  final int gen;
  const _GenSectionHeader({required this.gen});

  Color get _color => switch (gen) {
        0 => AppColors.primary,
        1 => AppColors.blue,
        2 => AppColors.purple,
        3 => AppColors.orange,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          PedigreeNode.generationName(gen),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _color,
          ),
        ),
      ],
    );
  }
}

// ── Ancestor tile ─────────────────────────────────────────────────────────────

class _AncestorTile extends StatelessWidget {
  final PedigreeNode node;
  final String treeKey;
  final bool isReadOnly;
  final PedigreeTreeCubit cubit;

  const _AncestorTile({
    required this.node,
    required this.treeKey,
    required this.isReadOnly,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final genColor = switch (node.generation) {
      0 => AppColors.primary,
      1 => AppColors.blue,
      2 => AppColors.purple,
      3 => AppColors.orange,
      _ => AppColors.textSecondary,
    };

    return GestureDetector(
      onTap: () => showPedigreeNodeDetail(
        context: context,
        node: node,
        isReadOnly: isReadOnly,
        cubit: cubit,
        treeKey: treeKey,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: genColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                node.gender == 'male'
                    ? Icons.male_rounded
                    : node.gender == 'female'
                        ? Icons.female_rounded
                        : Icons.pets_rounded,
                color: genColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.ringNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    node.name ?? PedigreeNode.positionLabel(node.position),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: genColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                node.generation == 0 ? 'الطائر' : 'ج${node.generation}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: genColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }
}
