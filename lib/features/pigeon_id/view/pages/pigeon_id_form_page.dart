import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../model/pigeon_model.dart';
import '../../viewmodel/pigeon_id_bloc.dart';
import '../widgets/pigeon_id_shared_widgets.dart';
import 'pigeon_id_photos_page.dart';

class PigeonIdFormPage extends StatefulWidget {
  const PigeonIdFormPage({super.key});

  @override
  State<PigeonIdFormPage> createState() => _PigeonIdFormPageState();
}

class _PigeonIdFormPageState extends State<PigeonIdFormPage> {
  final _ringCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _raceCtrl = TextEditingController();

  @override
  void dispose() {
    _ringCtrl.dispose();
    _breedCtrl.dispose();
    _raceCtrl.dispose();
    super.dispose();
  }

  void _pickHatchDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      helpText: 'تاريخ الفقس',
    );
    if (picked != null && context.mounted) {
      context.read<PigeonIdBloc>().add(PigeonIdHatchDateChanged(picked));
    }
  }

  void _addRaceResult(BuildContext context) {
    final text = _raceCtrl.text.trim();
    if (text.isEmpty) return;
    context.read<PigeonIdBloc>().add(PigeonIdRaceResultAdded(text));
    _raceCtrl.clear();
  }

  void _next(BuildContext context, PigeonIdState state) {
    if (!state.canProceedToPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رقم الحلقة والسلالة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PigeonIdBloc>(),
          child: const PigeonIdPhotosPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PigeonIdBloc, PigeonIdState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'الهوية الرقمية للحمامة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            actions: [
              IconButton(
                icon:
                    const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: Column(
            children: [
              PigeonStepHeader(
                  current: 1, total: 4, label: 'البيانات الأساسية'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Ring number ──────────────────────────────────
                      const PigeonFieldLabel(text: 'رقم الحلقة *'),
                      const SizedBox(height: 6),
                      PigeonAppInput(
                        controller: _ringCtrl,
                        hint: 'مثال: EG-2024-001',
                        onChanged: (v) => context
                            .read<PigeonIdBloc>()
                            .add(PigeonIdRingNumberChanged(v)),
                      ),

                      const SizedBox(height: 16),

                      // ── Breed ────────────────────────────────────────
                      const PigeonFieldLabel(text: 'السلالة / النسب *'),
                      const SizedBox(height: 6),
                      PigeonAppInput(
                        controller: _breedCtrl,
                        hint: 'مثال: زاجل بلجيكي أصيل',
                        onChanged: (v) => context
                            .read<PigeonIdBloc>()
                            .add(PigeonIdBreedChanged(v)),
                      ),

                      const SizedBox(height: 16),

                      // ── Gender ───────────────────────────────────────
                      const PigeonFieldLabel(text: 'الجنس *'),
                      const SizedBox(height: 8),
                      _GenderSelector(
                        selected: state.gender,
                        onChanged: (g) => context
                            .read<PigeonIdBloc>()
                            .add(PigeonIdGenderChanged(g)),
                      ),

                      const SizedBox(height: 20),

                      // ── Optional divider ─────────────────────────────
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                            child: Text(
                              'بيانات اختيارية',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Hatch date ───────────────────────────────────
                      const PigeonFieldLabel(text: 'تاريخ الفقس'),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _pickHatchDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary),
                              const SizedBox(width: 10),
                              Text(
                                state.hatchDate != null
                                    ? '${state.hatchDate!.day}/${state.hatchDate!.month}/${state.hatchDate!.year}'
                                    : 'اختر تاريخ الفقس',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: state.hatchDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Race results ─────────────────────────────────
                      const PigeonFieldLabel(text: 'نتائج السباقات'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: PigeonAppInput(
                              controller: _raceCtrl,
                              hint: 'مثال: المركز الأول - سباق 500كم',
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _addRaceResult(context),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),

                      if (state.raceResults.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ...state.raceResults.asMap().entries.map(
                              (e) => _RaceResultChip(
                                label: e.value,
                                onRemove: () => context
                                    .read<PigeonIdBloc>()
                                    .add(PigeonIdRaceResultRemoved(e.key)),
                              ),
                            ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              PigeonNextButton(
                label: 'التالي — إضافة الصور',
                enabled: state.canProceedToPhotos,
                onTap: () => _next(context, state),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Local widgets ────────────────────────────────────────────────────────────

class _GenderSelector extends StatelessWidget {
  final PigeonGender selected;
  final ValueChanged<PigeonGender> onChanged;

  const _GenderSelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderOption(
            label: 'ذكر',
            emoji: '🔵',
            isSelected: selected == PigeonGender.male,
            selectedColor: AppColors.blue,
            selectedBg: AppColors.blueLight,
            onTap: () => onChanged(PigeonGender.male),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GenderOption(
            label: 'أنثى',
            emoji: '🔴',
            isSelected: selected == PigeonGender.female,
            selectedColor: AppColors.red,
            selectedBg: AppColors.redLight,
            onTap: () => onChanged(PigeonGender.female),
          ),
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final Color selectedColor;
  final Color selectedBg;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.selectedColor,
    required this.selectedBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color:
                    isSelected ? selectedColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RaceResultChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _RaceResultChip(
      {required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textPrimary)),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
