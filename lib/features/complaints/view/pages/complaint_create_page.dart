import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../payments/model/payment_request_model.dart';
import '../../viewmodel/complaints_bloc.dart';
import '../../viewmodel/complaints_event.dart';
import '../../viewmodel/complaints_state.dart';

class ComplaintCreatePage extends StatelessWidget {
  final PaymentRequestModel paymentRequest;

  const ComplaintCreatePage({super.key, required this.paymentRequest});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ComplaintsBloc>(),
      child: _ComplaintCreateView(paymentRequest: paymentRequest),
    );
  }
}

class _ComplaintCreateView extends StatefulWidget {
  final PaymentRequestModel paymentRequest;

  const _ComplaintCreateView({required this.paymentRequest});

  @override
  State<_ComplaintCreateView> createState() => _ComplaintCreateViewState();
}

class _ComplaintCreateViewState extends State<_ComplaintCreateView> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late String _type;

  @override
  void initState() {
    super.initState();
    _type = widget.paymentRequest.isRejected ? 'payment_rejected' : 'post_sale';
    _titleCtrl = TextEditingController(text: _defaultTitle);
    _descriptionCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  String get _defaultTitle => widget.paymentRequest.isRejected
      ? 'اعتراض على رفض الدفع'
      : 'شكوى ما بعد البيع';

  void _submit(BuildContext context) {
    final title = _titleCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل عنوان الشكوى ووصفها'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.read<ComplaintsBloc>().add(
          ComplaintCreateRequested(
            paymentRequestId: widget.paymentRequest.id,
            title: title,
            description: description,
            complaintType: _type,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComplaintsBloc, ComplaintsState>(
      listenWhen: (p, c) =>
          p.createSuccess != c.createSuccess ||
          (p.errorMessage != c.errorMessage && c.errorMessage != null),
      listener: (context, state) {
        if (state.createSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تقديم الشكوى بنجاح'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
          return;
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final creating = state.status == ComplaintsStatus.creating;
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'تقديم شكوى',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PaymentSummary(request: widget.paymentRequest),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'عنوان الشكوى',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: AppColors.pageBackground,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: const InputDecoration(
                        labelText: 'نوع الشكوى',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: AppColors.pageBackground,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'post_sale',
                          child: Text('ما بعد البيع'),
                        ),
                        DropdownMenuItem(
                          value: 'payment_rejected',
                          child: Text('دفع مرفوض'),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text('أخرى'),
                        ),
                      ],
                      onChanged: creating
                          ? null
                          : (value) => setState(() {
                                if (value != null) _type = value;
                              }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'وصف المشكلة',
                        hintText: 'اشرح ما حدث بوضوح...',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: AppColors.pageBackground,
                      ),
                      minLines: 4,
                      maxLines: 6,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: creating ? null : () => _submit(context),
                        icon: creating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          creating ? 'جاري الإرسال...' : 'تقديم الشكوى',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  final PaymentRequestModel request;

  const _PaymentSummary({required this.request});

  @override
  Widget build(BuildContext context) {
    final color = request.isApproved ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.payment_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب دفع #${request.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${request.statusLabel} · ${request.typeLabel} · ${request.amount.toStringAsFixed(2)} ج.م',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
