import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../pigeon_id/view/widgets/pigeon_id_shared_widgets.dart';
import '../../model/pedigree_tree_model.dart';

class PedigreeNodeForm extends StatefulWidget {
  final String position;
  final PedigreeNode? initialValue;
  final ValueChanged<PedigreeNode?> onChanged;
  final bool ringRequired;

  const PedigreeNodeForm({
    super.key,
    required this.position,
    required this.onChanged,
    this.initialValue,
    this.ringRequired = false,
  });

  @override
  State<PedigreeNodeForm> createState() => _PedigreeNodeFormState();
}

class _PedigreeNodeFormState extends State<PedigreeNodeForm> {
  late final TextEditingController _ringCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ownerCtrl;
  late final TextEditingController _breedCtrl;
  String? _gender;
  final List<TextEditingController> _raceCtrls = [];

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    _ringCtrl = TextEditingController(text: v?.ringNumber ?? '');
    _nameCtrl = TextEditingController(text: v?.name ?? '');
    _ownerCtrl = TextEditingController(text: v?.owner ?? '');
    _breedCtrl = TextEditingController(text: v?.breed ?? '');
    _gender = v?.gender;
    for (final r in v?.raceResults ?? <String>[]) {
      final ctrl = TextEditingController(text: r);
      ctrl.addListener(_notify);
      _raceCtrls.add(ctrl);
    }
    _ringCtrl.addListener(_notify);
    _nameCtrl.addListener(_notify);
    _ownerCtrl.addListener(_notify);
    _breedCtrl.addListener(_notify);
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _nameCtrl.dispose();
    _ownerCtrl.dispose();
    _breedCtrl.dispose();
    for (final c in _raceCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _notify() {
    final ring = _ringCtrl.text.trim();
    if (ring.isEmpty) {
      widget.onChanged(null);
      return;
    }
    widget.onChanged(PedigreeNode(
      position: widget.position,
      ringNumber: ring,
      name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      owner: _ownerCtrl.text.trim().isEmpty ? null : _ownerCtrl.text.trim(),
      gender: _gender,
      breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
      raceResults: _raceCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    ));
  }

  void _addRaceResult() {
    setState(() {
      final ctrl = TextEditingController();
      ctrl.addListener(_notify);
      _raceCtrls.add(ctrl);
    });
  }

  void _removeRaceResult(int index) {
    setState(() {
      _raceCtrls[index].dispose();
      _raceCtrls.removeAt(index);
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PigeonFieldLabel(
          text: widget.ringRequired ? 'رقم الحلقة *' : 'رقم الحلقة',
        ),
        const SizedBox(height: 6),
        PigeonAppInput(
          controller: _ringCtrl,
          hint: 'مثال: EG 3603-2022',
        ),
        const SizedBox(height: 12),
        const PigeonFieldLabel(text: 'الاسم'),
        const SizedBox(height: 6),
        PigeonAppInput(controller: _nameCtrl, hint: 'اسم الطائر (اختياري)'),
        const SizedBox(height: 12),
        const PigeonFieldLabel(text: 'المالك'),
        const SizedBox(height: 6),
        PigeonAppInput(controller: _ownerCtrl, hint: 'اسم المالك (اختياري)'),
        const SizedBox(height: 12),
        const PigeonFieldLabel(text: 'السلالة'),
        const SizedBox(height: 6),
        PigeonAppInput(controller: _breedCtrl, hint: 'نوع السلالة (اختياري)'),
        const SizedBox(height: 12),
        const PigeonFieldLabel(text: 'الجنس'),
        const SizedBox(height: 6),
        _GenderSelector(
          value: _gender,
          onChanged: (g) {
            setState(() => _gender = g);
            _notify();
          },
        ),
        if (_raceCtrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          const PigeonFieldLabel(text: 'نتائج السباق'),
          const SizedBox(height: 6),
          for (int i = 0; i < _raceCtrls.length; i++) ...[
            Row(
              children: [
                Expanded(
                  child: PigeonAppInput(
                    controller: _raceCtrls[i],
                    hint: 'مثال: 30th 200km 1602p',
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _removeRaceResult(i),
                  child: const Icon(Icons.remove_circle_outline,
                      color: AppColors.error, size: 22),
                ),
              ],
            ),
            if (i < _raceCtrls.length - 1) const SizedBox(height: 8),
          ],
        ],
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _addRaceResult,
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text('إضافة نتيجة سباق'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _GenderSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GenderButton(
          label: 'ذكر',
          icon: Icons.male_rounded,
          color: AppColors.blue,
          selected: value == 'male',
          onTap: () => onChanged(value == 'male' ? null : 'male'),
        ),
        const SizedBox(width: 8),
        _GenderButton(
          label: 'أنثى',
          icon: Icons.female_rounded,
          color: AppColors.purple,
          selected: value == 'female',
          onTap: () => onChanged(value == 'female' ? null : 'female'),
        ),
        const SizedBox(width: 8),
        _GenderButton(
          label: 'غير محدد',
          icon: Icons.help_outline_rounded,
          color: AppColors.textSecondary,
          selected: value == null,
          onTap: () => onChanged(null),
        ),
      ],
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 44,
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.1) : Colors.white,
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16, color: selected ? color : AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? color : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
