import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../model/pedigree_tree_model.dart';
import '../../viewmodel/pedigree_tree_cubit.dart';
import '../widgets/pedigree_node_card.dart';
import '../widgets/pedigree_node_detail_sheet.dart';
import '../widgets/pedigree_node_form.dart';
import 'pedigree_tree_add_page.dart';

// Holds computed layout dimensions passed through the canvas hierarchy.
class _LP {
  final double nodeW;
  final double nodeH;
  final double hGap;
  final double vGap = 10.0;
  final double headerH = 36.0;

  const _LP({
    required this.nodeW,
    required this.nodeH,
    required this.hGap,
  });
}

// ── Page ──────────────────────────────────────────────────────────────────────

class PedigreeTreePage extends StatefulWidget {
  final String treeKey;
  final bool isReadOnly;

  const PedigreeTreePage({
    super.key,
    required this.treeKey,
    this.isReadOnly = false,
  });

  @override
  State<PedigreeTreePage> createState() => _PedigreeTreePageState();
}

class _PedigreeTreePageState extends State<PedigreeTreePage> {
  final _repaintKey = GlobalKey();
  bool _exporting = false;

  Future<void> _exportAsImage() async {
    if (_exporting) return;
    setState(() => _exporting = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      Directory dir;
      if (Platform.isAndroid) {
        dir = (await getExternalStorageDirectory()) ??
            await getApplicationDocumentsDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final fileName =
          'pedigree_${widget.treeKey}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم الحفظ في: ${file.path}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل تصدير الصورة'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedigreeTreeCubit, PedigreeTreeState>(
      builder: (context, state) {
        final tree = state.trees[widget.treeKey];
        final cubit = context.read<PedigreeTreeCubit>();
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: PPWAppBar(
            title: 'شجرة النسب',
            actions: [
              if (tree != null)
                _exporting
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.download_rounded),
                        tooltip: 'حفظ كصورة',
                        onPressed: _exportAsImage,
                      ),
            ],
          ),
          floatingActionButton: widget.isReadOnly
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: PedigreeTreeAddPage(
                          existingTreeKey: widget.treeKey,
                          existingTree: tree,
                        ),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('تعديل الشجرة'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
          body: tree == null
              ? const _EmptyTreeState()
              : _TreeBody(
                  tree: tree,
                  treeKey: widget.treeKey,
                  isReadOnly: widget.isReadOnly,
                  cubit: cubit,
                  repaintKey: _repaintKey,
                ),
        );
      },
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyTreeState extends StatelessWidget {
  const _EmptyTreeState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_tree_rounded,
                color: AppColors.textHint, size: 52),
            SizedBox(height: 16),
            Text(
              'لم يتم العثور على شجرة النسب',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tree body — responsive layout ────────────────────────────────────────────

class _TreeBody extends StatelessWidget {
  final PedigreeTree tree;
  final String treeKey;
  final bool isReadOnly;
  final PedigreeTreeCubit cubit;
  final GlobalKey repaintKey;

  const _TreeBody({
    required this.tree,
    required this.treeKey,
    required this.isReadOnly,
    required this.cubit,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final filledMaxGen = tree.maxGeneration;
        final layoutMaxGen =
            !isReadOnly && filledMaxGen < 6 ? filledMaxGen + 1 : filledMaxGen;
        final totalCols = layoutMaxGen + 1;

        const hGap = 24.0;
        const padding = 32.0;
        final fittedW =
            (constraints.maxWidth - padding - hGap * (totalCols - 1)) /
                totalCols;
        final nodeW = fittedW.clamp(145.0, 175.0);
        final nodeH = (nodeW * 0.87).clamp(120.0, 145.0);

        final lp = _LP(nodeW: nodeW, nodeH: nodeH, hGap: hGap);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: RepaintBoundary(
                key: repaintKey,
                child: ColoredBox(
                  color: AppColors.pageBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _TreeCanvas(
                      tree: tree,
                      treeKey: treeKey,
                      isReadOnly: isReadOnly,
                      cubit: cubit,
                      lp: lp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Layout computation ────────────────────────────────────────────────────────

class _NodeLayout {
  final String position;
  final PedigreeNode? node;
  final double left;
  final double top;

  const _NodeLayout({
    required this.position,
    required this.node,
    required this.left,
    required this.top,
  });

  Offset centerLeft(_LP lp) =>
      Offset(left, top + lp.nodeH / 2 + lp.headerH);

  Offset centerRight(_LP lp) =>
      Offset(left + lp.nodeW, top + lp.nodeH / 2 + lp.headerH);
}

class _TreeLayout {
  final List<_NodeLayout> layouts;
  final double totalWidth;
  final double totalHeight;

  const _TreeLayout({
    required this.layouts,
    required this.totalWidth,
    required this.totalHeight,
  });

  static _TreeLayout compute(
    PedigreeTree tree, {
    required bool showPlaceholders,
    required _LP lp,
  }) {
    final filled = Set<String>.from(tree.nodes.keys);
    final toShow = <String>{...filled};

    if (showPlaceholders) {
      for (final pos in filled) {
        if (pos.length < 6) {
          toShow.add('${pos}f');
          toShow.add('${pos}m');
        }
      }
    }

    if (toShow.isEmpty) toShow.add('');

    final maxGen =
        toShow.map((p) => p.length).reduce((a, b) => a > b ? a : b);
    final totalSlots = math.max(1, 1 << maxGen);

    final nodeAreaH = totalSlots * (lp.nodeH + lp.vGap) - lp.vGap;
    final canvasW = (maxGen + 1) * (lp.nodeW + lp.hGap) - lp.hGap;
    final totalH = lp.headerH + nodeAreaH + 24;

    final layouts = <_NodeLayout>[];
    for (final pos in toShow) {
      final gen = pos.length;
      final slot = PedigreeNode.slotIndex(pos);
      final cellH = (nodeAreaH + lp.vGap) / math.max(1, 1 << gen);
      final top = slot * cellH + (cellH - lp.nodeH) / 2;
      final left = gen * (lp.nodeW + lp.hGap);

      layouts.add(_NodeLayout(
        position: pos,
        node: tree.nodes[pos],
        left: left,
        top: top,
      ));
    }

    return _TreeLayout(
      layouts: layouts,
      totalWidth: math.max(canvasW, lp.nodeW + 48),
      totalHeight: totalH,
    );
  }
}

// ── Canvas ────────────────────────────────────────────────────────────────────

class _TreeCanvas extends StatelessWidget {
  final PedigreeTree tree;
  final String treeKey;
  final bool isReadOnly;
  final PedigreeTreeCubit cubit;
  final _LP lp;

  const _TreeCanvas({
    required this.tree,
    required this.treeKey,
    required this.isReadOnly,
    required this.cubit,
    required this.lp,
  });

  @override
  Widget build(BuildContext context) {
    final layout =
        _TreeLayout.compute(tree, showPlaceholders: !isReadOnly, lp: lp);
    final maxGen =
        layout.layouts.map((l) => l.position.length).reduce(math.max);

    return SizedBox(
      width: layout.totalWidth + 48,
      height: layout.totalHeight,
      child: Stack(
        children: [
          ..._buildHeaders(maxGen),
          Positioned.fill(
            child: CustomPaint(
              painter: _LinesPainter(
                layouts: layout.layouts,
                filledPositions: Set.from(tree.nodes.keys),
                lp: lp,
              ),
            ),
          ),
          for (final nl in layout.layouts)
            Positioned(
              left: nl.left,
              top: lp.headerH + nl.top,
              child: PedigreeNodeCard(
                position: nl.position,
                node: nl.node,
                isReadOnly: isReadOnly,
                width: lp.nodeW,
                height: lp.nodeH,
                onTap: nl.node == null
                    ? null
                    : () => showPedigreeNodeDetail(
                          context: context,
                          node: nl.node!,
                          isReadOnly: isReadOnly,
                          cubit: cubit,
                          treeKey: treeKey,
                        ),
                onAddTap: nl.node == null && !isReadOnly
                    ? () => _openAddNode(context, nl.position)
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildHeaders(int maxGen) {
    return [
      for (int g = 0; g <= maxGen; g++)
        Positioned(
          left: g * (lp.nodeW + lp.hGap),
          top: 0,
          width: lp.nodeW,
          height: lp.headerH,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _genColor(g).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                PedigreeNode.generationName(g),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _genColor(g),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
    ];
  }

  Color _genColor(int gen) => switch (gen) {
        0 => AppColors.primary,
        1 => AppColors.blue,
        2 => AppColors.purple,
        3 => AppColors.orange,
        _ => AppColors.textSecondary,
      };

  void _openAddNode(BuildContext context, String position) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddNodeSheet(
        position: position,
        onSave: (n) {
          if (n != null) cubit.upsertNode(treeKey, n);
        },
      ),
    );
  }
}

// ── Lines painter ─────────────────────────────────────────────────────────────

class _LinesPainter extends CustomPainter {
  final List<_NodeLayout> layouts;
  final Set<String> filledPositions;
  final _LP lp;

  const _LinesPainter({
    required this.layouts,
    required this.filledPositions,
    required this.lp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final layoutMap = {for (final l in layouts) l.position: l};

    for (final nl in layouts) {
      if (nl.position.isEmpty) continue;
      if (!filledPositions.contains(nl.position)) continue;

      final parentPos = nl.position.substring(0, nl.position.length - 1);
      final parentLayout = layoutMap[parentPos];
      if (parentLayout == null) continue;

      final start = parentLayout.centerRight(lp);
      final end = nl.centerLeft(lp);
      final midX = (start.dx + end.dx) / 2;

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LinesPainter old) =>
      old.layouts != layouts || old.filledPositions != filledPositions;
}

// ── Add node bottom sheet ─────────────────────────────────────────────────────

class _AddNodeSheet extends StatefulWidget {
  final String position;
  final ValueChanged<PedigreeNode?> onSave;

  const _AddNodeSheet({required this.position, required this.onSave});

  @override
  State<_AddNodeSheet> createState() => _AddNodeSheetState();
}

class _AddNodeSheetState extends State<_AddNodeSheet> {
  PedigreeNode? _draft;

  @override
  Widget build(BuildContext context) {
    final label = PedigreeNode.positionLabel(widget.position);

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
                  Expanded(
                    child: Text(
                      'إضافة: $label',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onSave(_draft);
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
                    position: widget.position,
                    onChanged: (n) => setState(() => _draft = n),
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
