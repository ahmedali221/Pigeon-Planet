import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../viewmodel/pedigrees_bloc.dart';
import '../../viewmodel/pedigrees_event.dart';
import '../../viewmodel/pedigrees_state.dart';

class PedigreeAddPage extends StatefulWidget {
  final int? prefilledBirdId;

  const PedigreeAddPage({super.key, this.prefilledBirdId});

  @override
  State<PedigreeAddPage> createState() => _PedigreeAddPageState();
}

class _PedigreeAddPageState extends State<PedigreeAddPage> {
  final _ringCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _ringCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final ring = _ringCtrl.text.trim();
    if (ring.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل رقم حلقة الطائر'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    context.read<PedigreesBloc>().add(PedigreeCreateSubmitted(
          ringNumber: ring,
          description: _descCtrl.text.trim(),
          birdId: widget.prefilledBirdId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PedigreesBloc, PedigreesState>(
      listenWhen: (prev, curr) => prev.status == PedigreesStatus.creating,
      listener: (context, state) {
        if (state.status == PedigreesStatus.loaded) {
          Navigator.pop(context);
        } else if (state.status == PedigreesStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'حدث خطأ، حاول مجدداً'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isCreating = state.status == PedigreesStatus.creating;
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: const PPWAppBar(title: 'إضافة شهادة نسب'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.blue.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.blue, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'أدخل بيانات نسب الطائر لإضافتها إلى سجله',
                          style:
                              TextStyle(fontSize: 13, color: AppColors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'بيانات النسب',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ringCtrl,
                  textAlign: TextAlign.start,
                  enabled: !isCreating,
                  decoration: InputDecoration(
                    labelText: 'رقم حلقة الطائر *',
                    hintText: 'أدخل رقم الحلقة',
                    filled: true,
                    fillColor: AppColors.inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.tag_rounded,
                        color: AppColors.purple),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  textAlign: TextAlign.start,
                  maxLines: 3,
                  enabled: !isCreating,
                  decoration: InputDecoration(
                    labelText: 'وصف النسب',
                    hintText: 'أدخل وصفاً للنسب (اختياري)',
                    filled: true,
                    fillColor: AppColors.inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.notes_rounded,
                        color: AppColors.purple),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed:
                        isCreating ? null : () => _submit(context),
                    icon: isCreating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: Text(
                        isCreating ? 'جارٍ الحفظ...' : 'حفظ شهادة النسب'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
