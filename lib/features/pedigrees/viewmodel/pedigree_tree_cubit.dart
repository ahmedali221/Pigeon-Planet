import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../model/pedigree_tree_model.dart';

class PedigreeTreeState extends Equatable {
  final Map<String, PedigreeTree> trees; // key = root bird ring number

  const PedigreeTreeState({this.trees = const {}});

  List<PedigreeNode> get birds => trees.values
      .where((t) => t.nodes.containsKey(''))
      .map((t) => t.nodes['']!)
      .toList();

  @override
  List<Object?> get props => [trees];
}

class PedigreeTreeCubit extends Cubit<PedigreeTreeState> {
  PedigreeTreeCubit() : super(const PedigreeTreeState()) {
    _initAndLoad();
  }

  static const _kFile = 'pedigree_tree.json';

  // Cached synchronously once the platform provides it in _initAndLoad.
  String? _filePath;

  // ── Boot ─────────────────────────────────────────────────────────────────────

  Future<void> _initAndLoad() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _filePath = '${dir.path}/$_kFile';

      final file = File(_filePath!);
      if (!file.existsSync()) return;

      final raw = file.readAsStringSync();
      final json = jsonDecode(raw) as Map<String, dynamic>;

      Map<String, PedigreeTree> trees;
      if (json.containsKey('version') && json['version'] == 2) {
        // Current multi-tree format
        final treesJson = json['trees'] as Map<String, dynamic>? ?? {};
        trees = treesJson.map(
          (k, v) =>
              MapEntry(k, PedigreeTree.fromJson(v as Map<String, dynamic>)),
        );
      } else if (json.containsKey('nodes')) {
        // Migrate old single-tree format
        final tree = PedigreeTree.fromJson(json);
        final key = tree.nodes['']?.ringNumber;
        trees = key != null && key.isNotEmpty ? {key: tree} : {};
      } else {
        trees = {};
      }

      if (!isClosed) emit(PedigreeTreeState(trees: trees));
    } catch (_) {
      // Corrupt or missing file — start empty.
    }
  }

  // ── Persistence ───────────────────────────────────────────────────────────────

  void _persist() {
    if (_filePath == null) return;
    try {
      final file = File(_filePath!);
      if (state.trees.isEmpty) {
        if (file.existsSync()) file.deleteSync();
      } else {
        final json = {
          'version': 2,
          'trees': state.trees.map((k, v) => MapEntry(k, v.toJson())),
        };
        file.writeAsStringSync(jsonEncode(json));
      }
    } catch (_) {}
  }

  // ── Mutations ─────────────────────────────────────────────────────────────────

  // Create or replace an entire tree (keyed by its root bird ring number).
  void saveTree(PedigreeTree tree) {
    final key = tree.nodes['']?.ringNumber;
    if (key == null || key.trim().isEmpty) return;
    emit(PedigreeTreeState(trees: {...state.trees, key: tree}));
    _persist();
  }

  // Update a single node within a specific tree.
  void upsertNode(String treeKey, PedigreeNode node) {
    final current = state.trees[treeKey];
    if (current == null) return;
    final updatedTree =
        PedigreeTree(nodes: {...current.nodes, node.position: node});
    emit(PedigreeTreeState(trees: {...state.trees, treeKey: updatedTree}));
    _persist();
  }

  void removeNode(String treeKey, String position) {
    final current = state.trees[treeKey];
    if (current == null) return;
    final updated = Map<String, PedigreeNode>.from(current.nodes)
      ..remove(position);
    if (updated.isEmpty) {
      deleteTree(treeKey);
      return;
    }
    emit(PedigreeTreeState(
        trees: {
          ...state.trees,
          treeKey: PedigreeTree(nodes: updated),
        }));
    _persist();
  }

  void deleteTree(String treeKey) {
    final updated = Map<String, PedigreeTree>.from(state.trees)
      ..remove(treeKey);
    emit(PedigreeTreeState(trees: updated));
    _persist();
  }
}
