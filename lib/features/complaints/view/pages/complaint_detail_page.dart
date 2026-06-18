import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/complaint_model.dart';
import '../../viewmodel/complaints_bloc.dart';
import '../../viewmodel/complaints_event.dart';
import '../../viewmodel/complaints_state.dart';

class ComplaintDetailPage extends StatelessWidget {
  final ComplaintModel initialComplaint;

  const ComplaintDetailPage({super.key, required this.initialComplaint});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComplaintsBloc, ComplaintsState>(
      listenWhen: (p, c) =>
          p.cancelSuccess != c.cancelSuccess ||
          (p.errorMessage != c.errorMessage && c.errorMessage != null),
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.cancelSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إلغاء الشكوى'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final complaint =
            state.selectedComplaint?.id == initialComplaint.id
                ? state.selectedComplaint!
                : initialComplaint;
        final cancelling = state.status == ComplaintsStatus.cancelling;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'شكوى #${complaint.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusCard(complaint: complaint),
              const SizedBox(height: 14),
              _DetailsCard(complaint: complaint),
              const SizedBox(height: 14),
              _DescriptionCard(complaint: complaint),
              if (complaint.adminNote != null) ...[
                const SizedBox(height: 14),
                _AdminNoteCard(adminNote: complaint.adminNote!),
              ],
              if (complaint.isOpen) ...[
                const SizedBox(height: 14),
                _CancelCard(
                  isCancelling: cancelling,
                  onCancel: () => _confirmCancel(context, complaint.id),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmCancel(BuildContext context, int complaintId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إلغاء الشكوى'),
        content: const Text('هل تريد إلغاء هذه الشكوى؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ComplaintsBloc>().add(ComplaintCancelRequested(complaintId));
    }
  }
}

class _StatusCard extends StatelessWidget {
  final ComplaintModel complaint;

  const _StatusCard({required this.complaint});

  Color get _color => switch (complaint.status) {
        'open' => AppColors.orange,
        'in_review' => AppColors.blue,
        'resolved' => AppColors.success,
        'rejected' => AppColors.error,
        'cancelled' => AppColors.textSecondary,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.report_problem_outlined, color: color, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            complaint.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              complaint.statusLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final ComplaintModel complaint;

  const _DetailsCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy/MM/dd HH:mm');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.tag_rounded,
            label: 'رقم الشكوى',
            value: '#${complaint.id}',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _DetailRow(
            icon: Icons.payment_rounded,
            label: 'طلب الدفع',
            value: '#${complaint.paymentRequestId}',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _DetailRow(
            icon: Icons.category_outlined,
            label: 'النوع',
            value: complaint.typeLabel,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'تاريخ الإنشاء',
            value: fmt.format(complaint.createdAt),
          ),
          if (complaint.resolvedAt != null) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            _DetailRow(
              icon: Icons.check_circle_outline_rounded,
              label: 'تاريخ الحل',
              value: fmt.format(complaint.resolvedAt!),
            ),
          ],
          if (complaint.cancelledAt != null) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            _DetailRow(
              icon: Icons.cancel_outlined,
              label: 'تاريخ الإلغاء',
              value: fmt.format(complaint.cancelledAt!),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final ComplaintModel complaint;

  const _DescriptionCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الوصف',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            complaint.description?.isNotEmpty == true
                ? complaint.description!
                : 'لا يوجد وصف',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNoteCard extends StatelessWidget {
  final String adminNote;

  const _AdminNoteCard({required this.adminNote});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings_outlined,
                  color: AppColors.blue, size: 16),
              const SizedBox(width: 6),
              const Text(
                'ملاحظة الإدارة',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            adminNote,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelCard extends StatelessWidget {
  final bool isCancelling;
  final VoidCallback onCancel;

  const _CancelCard({required this.isCancelling, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: isCancelling
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                label: const Text(
                  'إلغاء الشكوى',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
    );
  }
}
