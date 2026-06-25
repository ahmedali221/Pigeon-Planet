import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../payments/model/payment_request_model.dart';
import '../../viewmodel/complaints_bloc.dart';
import '../../viewmodel/complaints_event.dart';
import '../../viewmodel/complaints_state.dart';

import '../../../../l10n/app_localizations.dart';
class ComplaintCreatePage extends StatelessWidget {
  final PaymentRequestModel paymentRequest;

  ComplaintCreatePage({super.key, required this.paymentRequest});

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

  _ComplaintCreateView({required this.paymentRequest});

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
      ? AppLocalizations.of(context).paymentRejectionDispute
      : AppLocalizations.of(context).postSaleComplaint;

  void _submit(BuildContext context) {
    final title = _titleCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).complaintValidation),
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
            SnackBar(
              content: Text(AppLocalizations.of(context).complaintSubmittedSuccess),
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
          appBar: PPWAppBar(
            title: AppLocalizations.of(context).submitComplaint,
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _PaymentSummary(request: widget.paymentRequest),
              SizedBox(height: 14),
              Container(
                padding: EdgeInsets.all(16),
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
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).complaintTitleLabel,
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: AppColors.pageBackground,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).complaintTypeLabel,
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: AppColors.pageBackground,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'post_sale',
                          child: Text(AppLocalizations.of(context).afterSaleComplaint),
                        ),
                        DropdownMenuItem(
                          value: 'payment_rejected',
                          child: Text(AppLocalizations.of(context).rejectedPaymentComplaint),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text(AppLocalizations.of(context).otherComplaint),
                        ),
                      ],
                      onChanged: creating
                          ? null
                          : (value) => setState(() {
                                if (value != null) _type = value;
                              }),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _descriptionCtrl,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).complaintDescLabel,
                        hintText: AppLocalizations.of(context).complaintDescHint,
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: AppColors.pageBackground,
                      ),
                      minLines: 4,
                      maxLines: 6,
                      textInputAction: TextInputAction.newline,
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: creating ? null : () => _submit(context),
                        icon: creating
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          creating ? AppLocalizations.of(context).submit : AppLocalizations.of(context).submitComplaintAction,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(vertical: 14),
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

  _PaymentSummary({required this.request});

  @override
  Widget build(BuildContext context) {
    final color = request.isApproved ? AppColors.success : AppColors.error;
    return Container(
      padding: EdgeInsets.all(16),
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
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب دفع #${request.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${request.statusLabel} · ${request.typeLabel} · ${request.amount.toStringAsFixed(2)} ج.م',
                  style: TextStyle(
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
