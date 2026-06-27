import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/pedigree_tree_model.dart';
import '../../viewmodel/pedigree_tree_cubit.dart';
import 'pedigree_node_form.dart';

void showPedigreeNodeDetail({
  required BuildContext context,
  required PedigreeNode node,
  required bool isReadOnly,
  required PedigreeTreeCubit cubit,
  required String treeKey,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PedigreeNodeDetailSheet(
      node: node,
      isReadOnly: isReadOnly,
      cubit: cubit,
      treeKey: treeKey,
    ),
  );
}

class _PedigreeNodeDetailSheet extends StatelessWidget {
  final PedigreeNode node;
  final bool isReadOnly;
  final PedigreeTreeCubit cubit;
  final String treeKey;

  const _PedigreeNodeDetailSheet({
    required this.node,
    required this.isReadOnly,
    required this.cubit,
    required this.treeKey,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  _GenCircle(gen: node.generation),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PedigreeNode.positionLabel(node.position),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          PedigreeNode.generationName(node.generation),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isReadOnly)
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _openEdit(context);
                      },
                      icon: const Icon(Icons.edit_rounded,
                          color: AppColors.primary),
                      tooltip: 'تعديل',
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                children: [
                  _InfoRow(
                    icon: Icons.tag_rounded,
                    label: 'رقم الحلقة',
                    value: node.ringNumber,
                    valueColor: AppColors.primary,
                    valueBold: true,
                  ),
                  if (node.name != null)
                    _InfoRow(
                      icon: Icons.pets_rounded,
                      label: 'الاسم',
                      value: node.name!,
                    ),
                  if (node.owner != null)
                    _InfoRow(
                      icon: Icons.person_rounded,
                      label: 'المالك',
                      value: node.owner!,
                    ),
                  if (node.breed != null)
                    _InfoRow(
                      icon: Icons.category_rounded,
                      label: 'السلالة',
                      value: node.breed!,
                    ),
                  if (node.gender != null)
                    _InfoRow(
                      icon: node.gender == 'male'
                          ? Icons.male_rounded
                          : Icons.female_rounded,
                      label: 'الجنس',
                      value: node.gender == 'male' ? 'ذكر' : 'أنثى',
                      valueColor: node.gender == 'male'
                          ? AppColors.blue
                          : AppColors.purple,
                    ),
                  if (node.raceResults.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'نتائج السباق',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final result in node.raceResults)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.emoji_events_rounded,
                                size: 16, color: AppColors.orange),
                            const SizedBox(width: 8),
                            Text(
                              result,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSheet(
        node: node,
        onSave: (n) {
          if (n != null) cubit.upsertNode(treeKey, n);
        },
      ),
    );
  }
}

class _EditSheet extends StatelessWidget {
  final PedigreeNode node;
  final ValueChanged<PedigreeNode?> onSave;

  const _EditSheet({required this.node, required this.onSave});

  @override
  Widget build(BuildContext context) {
    PedigreeNode? draft = node;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'تعديل بيانات السلف',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onSave(draft);
                      Navigator.pop(context);
                    },
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                children: [
                  PedigreeNodeForm(
                    position: node.position,
                    initialValue: node,
                    ringRequired: node.generation == 0,
                    onChanged: (n) => draft = n,
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: valueBold
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: valueColor ?? AppColors.textPrimary,
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

class _GenCircle extends StatelessWidget {
  final int gen;
  const _GenCircle({required this.gen});

  @override
  Widget build(BuildContext context) {
    final color = switch (gen) {
      0 => AppColors.primary,
      1 => AppColors.blue,
      2 => AppColors.purple,
      3 => AppColors.orange,
      _ => AppColors.textSecondary,
    };
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          gen == 0 ? '🕊️' : 'ج$gen',
          style: TextStyle(
            fontSize: gen == 0 ? 22 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
