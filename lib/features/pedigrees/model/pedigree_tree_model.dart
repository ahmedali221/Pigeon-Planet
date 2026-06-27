import 'package:equatable/equatable.dart';

class PedigreeNode extends Equatable {
  // Position encoding: '' = subject, 'f' = father, 'm' = mother,
  // 'ff' = father's father, 'fm' = father's mother, etc. Up to 6 chars (Gen 6).
  final String position;
  final String ringNumber;
  final String? name;
  final String? owner;
  final String? gender; // 'male' | 'female' | null
  final String? breed;
  final List<String> raceResults;

  const PedigreeNode({
    required this.position,
    required this.ringNumber,
    this.name,
    this.owner,
    this.gender,
    this.breed,
    this.raceResults = const [],
  });

  int get generation => position.length;
  String get fatherKey => '${position}f';
  String get motherKey => '${position}m';
  String get parentKey =>
      position.isEmpty ? '' : position.substring(0, position.length - 1);

  static String positionLabel(String pos) {
    if (pos.isEmpty) return 'الطائر';
    return _buildLabel(pos);
  }

  static String _buildLabel(String pos) {
    if (pos.length == 1) return pos == 'f' ? 'الأب' : 'الأم';
    final last = pos[pos.length - 1];
    final prefix = last == 'f' ? 'أب ' : 'أم ';
    return prefix + _buildLabel(pos.substring(0, pos.length - 1));
  }

  static String generationName(int gen) {
    return switch (gen) {
      0 => 'الطائر',
      1 => 'الجيل الأول',
      2 => 'الجيل الثاني',
      3 => 'الجيل الثالث',
      4 => 'الجيل الرابع',
      5 => 'الجيل الخامس',
      _ => 'الجيل السادس',
    };
  }

  // Slot index within a generation (f=0, m=1 at each level → binary number).
  static int slotIndex(String pos) {
    int result = 0;
    for (int i = 0; i < pos.length; i++) {
      result = result * 2 + (pos[i] == 'm' ? 1 : 0);
    }
    return result;
  }

  // All positions for a given generation in slot order.
  static List<String> positionsForGeneration(int gen) {
    if (gen == 0) return [''];
    final result = <String>[];
    for (final p in positionsForGeneration(gen - 1)) {
      result.add('${p}f');
      result.add('${p}m');
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        'position': position,
        'ringNumber': ringNumber,
        if (name != null) 'name': name,
        if (owner != null) 'owner': owner,
        if (gender != null) 'gender': gender,
        if (breed != null) 'breed': breed,
        'raceResults': raceResults,
      };

  factory PedigreeNode.fromJson(Map<String, dynamic> json) => PedigreeNode(
        position: json['position'] as String,
        ringNumber: json['ringNumber'] as String,
        name: json['name'] as String?,
        owner: json['owner'] as String?,
        gender: json['gender'] as String?,
        breed: json['breed'] as String?,
        raceResults: (json['raceResults'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
      );

  @override
  List<Object?> get props =>
      [position, ringNumber, name, owner, gender, breed, raceResults];
}

class PedigreeTree extends Equatable {
  final Map<String, PedigreeNode> nodes;

  const PedigreeTree({required this.nodes});

  List<PedigreeNode> nodesForGeneration(int gen) =>
      nodes.values.where((n) => n.generation == gen).toList();

  int get maxGeneration {
    if (nodes.isEmpty) return 0;
    return nodes.keys.map((k) => k.length).reduce((a, b) => a > b ? a : b);
  }

  Map<String, dynamic> toJson() => {
        'nodes': nodes.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory PedigreeTree.fromJson(Map<String, dynamic> json) {
    final raw = json['nodes'] as Map<String, dynamic>? ?? {};
    return PedigreeTree(
      nodes: raw.map(
        (k, v) =>
            MapEntry(k, PedigreeNode.fromJson(v as Map<String, dynamic>)),
      ),
    );
  }

  @override
  List<Object?> get props => [nodes];
}
