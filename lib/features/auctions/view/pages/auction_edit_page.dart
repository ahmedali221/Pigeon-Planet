import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/auction_model.dart';
import '../../viewmodel/auctions_bloc.dart';

class AuctionEditPage extends StatefulWidget {
  final AuctionModel auction;

  const AuctionEditPage({super.key, required this.auction});

  @override
  State<AuctionEditPage> createState() => _AuctionEditPageState();
}

class _AuctionEditPageState extends State<AuctionEditPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _tagsCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.auction.title);
    _descCtrl = TextEditingController(text: widget.auction.description);
    _tagsCtrl = TextEditingController(text: widget.auction.tags ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuctionsBloc>().add(AuctionUpdateRequested(
          auctionId: widget.auction.id,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          tags: _tagsCtrl.text.trim().isEmpty ? null : _tagsCtrl.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuctionsBloc, AuctionsState>(
      listenWhen: (p, c) =>
          (p.isUpdating && !c.isUpdating) ||
          (c.updateError != null && c.updateError != p.updateError),
      listener: (context, state) {
        if (!state.isUpdating && state.updateError == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث المزاد بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else if (state.updateError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.updateError!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'تعديل المزاد',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
            ),
            actions: [
              if (state.isUpdating)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                )
              else
                TextButton(
                  onPressed: () => _submit(context),
                  child: const Text('حفظ',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _FieldCard(
                  label: 'عنوان المزاد',
                  child: TextFormField(
                    controller: _titleCtrl,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'العنوان مطلوب' : null,
                    decoration: _inputDec(hint: 'أدخل عنوان المزاد'),
                  ),
                ),
                const SizedBox(height: 12),
                _FieldCard(
                  label: 'الوصف',
                  child: TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: _inputDec(hint: 'أدخل وصف المزاد'),
                  ),
                ),
                const SizedBox(height: 12),
                _FieldCard(
                  label: 'الوسوم (Tags)',
                  child: TextFormField(
                    controller: _tagsCtrl,
                    decoration: _inputDec(hint: 'مثال: حمام, سباق, نادر'),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'يمكن تعديل العنوان والوصف والوسوم فقط، ولا يمكن تعديل الأسعار أو الطيور بعد إنشاء المزاد.',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDec({required String hint}) => InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 14, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.pageBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.error, width: 1.5)),
      );
}

class _FieldCard extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
