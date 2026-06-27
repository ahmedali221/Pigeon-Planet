import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/pedigree_tree_model.dart';

const double kNodeCardWidth = 160.0;
const double kNodeCardHeight = 130.0;

class PedigreeNodeCard extends StatelessWidget {
  final PedigreeNode? node;
  final String position;
  final bool isReadOnly;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;
  final double width;
  final double height;

  const PedigreeNodeCard({
    super.key,
    required this.position,
    required this.isReadOnly,
    this.node,
    this.onTap,
    this.onAddTap,
    this.width = kNodeCardWidth,
    this.height = kNodeCardHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (node == null) {
      return isReadOnly
          ? SizedBox(width: width, height: height)
          : _EmptyCard(onTap: onAddTap, width: width, height: height);
    }
    return GestureDetector(
      onTap: onTap,
      child: _FilledCard(node: node!, width: width, height: height),
    );
  }
}

// ── Filled card — database-table style ─────────────────────────────────────

class _FilledCard extends StatelessWidget {
  final PedigreeNode node;
  final double width;
  final double height;

  const _FilledCard(
      {required this.node, required this.width, required this.height});

  Color _genColor(int gen) => switch (gen) {
        0 => AppColors.primary,
        1 => AppColors.blue,
        2 => AppColors.purple,
        3 => AppColors.orange,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final genColor = _genColor(node.generation);
    final hasDetails = node.breed != null || node.raceResults.isNotEmpty;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Colored header: ring number + name + owner + gender ───
          Container(
            padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
            decoration: BoxDecoration(
              color: genColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(9)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ring number
                      Text(
                        node.ringNumber,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: genColor,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (node.name != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          node.name!,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: genColor.withValues(alpha: 0.85),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (node.owner != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          node.owner!,
                          style: TextStyle(
                            fontSize: 9,
                            color: genColor.withValues(alpha: 0.65),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (node.gender != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 4),
                    child: Icon(
                      node.gender == 'male'
                          ? Icons.male_rounded
                          : Icons.female_rounded,
                      size: 14,
                      color: node.gender == 'male'
                          ? AppColors.blue
                          : AppColors.purple,
                    ),
                  ),
              ],
            ),
          ),
          // ── White body: breed + race results ──────────────────────
          if (hasDetails)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (node.breed != null)
                      _FieldRow(label: 'السلالة', value: node.breed!),
                    if (node.raceResults.isNotEmpty) ...[
                      if (node.breed != null) const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_rounded,
                              size: 10, color: AppColors.orange),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              node.raceResults.take(2).join(' · '),
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Field row ─────────────────────────────────────────────────────────────────

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;

  const _FieldRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 8.5, color: AppColors.textHint),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty card ────────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  final VoidCallback? onTap;
  final double width;
  final double height;

  const _EmptyCard({this.onTap, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.primary, size: 24),
            SizedBox(height: 6),
            Text(
              'إضافة سلف',
              style: TextStyle(fontSize: 10, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

