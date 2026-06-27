import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../pigeon_id/view/widgets/pigeon_id_shared_widgets.dart';
import '../../model/pedigree_tree_model.dart';
import '../../viewmodel/pedigree_tree_cubit.dart';
import '../widgets/pedigree_node_form.dart';
import 'loft_bird_detail_page.dart';

class PedigreeTreeAddPage extends StatefulWidget {
  // null = new bird; set = editing existing tree for that key
  final String? existingTreeKey;
  final PedigreeTree? existingTree;

  const PedigreeTreeAddPage({
    super.key,
    this.existingTreeKey,
    this.existingTree,
  });

  @override
  State<PedigreeTreeAddPage> createState() => _PedigreeTreeAddPageState();
}

class _PedigreeTreeAddPageState extends State<PedigreeTreeAddPage> {
  int _currentStep = 0;
  int _maxStep = 2;
  final Map<String, PedigreeNode?> _drafts = {};

  @override
  void initState() {
    super.initState();
    final tree = widget.existingTree;
    if (tree != null) {
      for (final entry in tree.nodes.entries) {
        _drafts[entry.key] = entry.value;
      }
      _maxStep = tree.maxGeneration.clamp(2, 6);
    }
  }

  List<String> _positionsForStep(int step) =>
      PedigreeNode.positionsForGeneration(step);

  bool get _isLastStep => _currentStep == _maxStep;
  bool get _canExpand => _maxStep < 6;

  void _onNext() {
    if (_currentStep == 0 && _drafts[''] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل رقم حلقة الطائر الأصلي'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _currentStep++);
  }

  void _onBack() => setState(() => _currentStep--);

  void _expandGeneration() => setState(() => _maxStep++);

  void _saveTree() {
    final root = _drafts[''];
    if (root == null) return;

    final cubit = context.read<PedigreeTreeCubit>();

    final nodes = <String, PedigreeNode>{'': root};
    for (int g = 1; g <= _maxStep; g++) {
      for (final pos in PedigreeNode.positionsForGeneration(g)) {
        final n = _drafts[pos];
        if (n != null) nodes[pos] = n;
      }
    }

    cubit.saveTree(PedigreeTree(nodes: nodes));

    if (widget.existingTreeKey != null) {
      // Editing — pop back to the page already in the stack.
      Navigator.pop(context);
    } else {
      // New bird — navigate to its detail page.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: LoftBirdDetailPage(treeKey: root.ringNumber),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final positions = _positionsForStep(_currentStep);
    final genName = PedigreeNode.generationName(_currentStep);
    final ancestorCount = positions.length;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PPWAppBar(
        title: widget.existingTreeKey != null
            ? 'تعديل شجرة النسب'
            : 'إضافة شجرة النسب',
      ),
      body: Column(
        children: [
          PigeonStepHeader(
            current: _currentStep + 1,
            total: _maxStep + 1,
            label: genName,
          ),
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _currentStep == 0
                    ? 'الطائر الأصلي — رقم الحلقة مطلوب'
                    : '$genName — $ancestorCount ${ancestorCount == 1 ? 'سلف' : 'أسلاف'}',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: _currentStep == 0
                ? _SubjectStep(
                    draft: _drafts[''],
                    onChanged: (n) => setState(() => _drafts[''] = n),
                  )
                : _GenerationStep(
                    step: _currentStep,
                    positions: positions,
                    drafts: _drafts,
                    onChanged: (pos, n) =>
                        setState(() => _drafts[pos] = n),
                    canExpand: _isLastStep && _canExpand,
                    onExpand: _expandGeneration,
                  ),
          ),
          _BottomNav(
            isFirst: _currentStep == 0,
            isLast: _isLastStep,
            onBack: _onBack,
            onNext: _isLastStep ? _saveTree : _onNext,
          ),
        ],
      ),
    );
  }
}

// ── Step 0: Subject bird ──────────────────────────────────────────────────────

class _SubjectStep extends StatelessWidget {
  final PedigreeNode? draft;
  final ValueChanged<PedigreeNode?> onChanged;

  const _SubjectStep({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: PedigreeNodeForm(
          position: '',
          initialValue: draft,
          ringRequired: true,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Steps 1-6: Ancestor generation ──────────────────────────────────────────

class _GenerationStep extends StatelessWidget {
  final int step;
  final List<String> positions;
  final Map<String, PedigreeNode?> drafts;
  final void Function(String pos, PedigreeNode? node) onChanged;
  final bool canExpand;
  final VoidCallback onExpand;

  const _GenerationStep({
    required this.step,
    required this.positions,
    required this.drafts,
    required this.onChanged,
    required this.canExpand,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      children: [
        for (final pos in positions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AncestorSlot(
              position: pos,
              draft: drafts[pos],
              onChanged: (n) => onChanged(pos, n),
            ),
          ),
        if (canExpand)
          TextButton.icon(
            onPressed: onExpand,
            icon: const Icon(Icons.expand_more_rounded, size: 18),
            label: Text('إضافة ${PedigreeNode.generationName(step + 1)}'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AncestorSlot extends StatelessWidget {
  final String position;
  final PedigreeNode? draft;
  final ValueChanged<PedigreeNode?> onChanged;

  const _AncestorSlot({
    required this.position,
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final label = PedigreeNode.positionLabel(position);
    final isFilled = draft != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFilled
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: _SlotIcon(isFilled: isFilled),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  isFilled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          subtitle: isFilled
              ? Text(
                  draft!.ringNumber,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.primary),
                )
              : const Text(
                  'اختياري — اضغط للإضافة',
                  style: TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
          children: [
            PedigreeNodeForm(
              position: position,
              initialValue: draft,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotIcon extends StatelessWidget {
  final bool isFilled;
  const _SlotIcon({required this.isFilled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isFilled
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.border.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isFilled ? Icons.check_rounded : Icons.add_rounded,
        size: 18,
        color: isFilled ? AppColors.primary : AppColors.textHint,
      ),
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomNav({
    required this.isFirst,
    required this.isLast,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Row(
        children: [
          if (!isFirst)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('السابق'),
              ),
            ),
          if (!isFirst) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isLast ? AppColors.purple : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLast
                        ? Icons.account_tree_rounded
                        : Icons.arrow_back_ios_rounded,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isLast ? 'حفظ الشجرة' : 'التالي',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
