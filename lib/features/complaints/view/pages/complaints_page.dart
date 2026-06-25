import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../../../core/di/injection.dart';
import '../../model/complaint_model.dart';
import '../../viewmodel/complaints_bloc.dart';
import '../../viewmodel/complaints_event.dart';
import '../../viewmodel/complaints_state.dart';
import 'complaint_detail_page.dart';

import '../../../../l10n/app_localizations.dart';
class ComplaintsPage extends StatelessWidget {
  ComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ComplaintsBloc>()..add(ComplaintsLoadRequested()),
      child: _ComplaintsView(),
    );
  }
}

class _ComplaintsView extends StatelessWidget {
  _ComplaintsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PPWAppBar(
        title: AppLocalizations.of(context).complaints,
      ),
      body: BlocConsumer<ComplaintsBloc, ComplaintsState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage && c.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        builder: (context, state) {
          if (state.status == ComplaintsStatus.loading ||
              state.status == ComplaintsStatus.initial) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.status == ComplaintsStatus.error &&
              state.complaints.isEmpty) {
            return _ErrorState(
              message: state.errorMessage ?? AppLocalizations.of(context).errorOccurred,
              onRetry: () => context
                  .read<ComplaintsBloc>()
                  .add(ComplaintsLoadRequested()),
            );
          }

          if (state.complaints.isEmpty) {
            return _EmptyState();
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => context
                .read<ComplaintsBloc>()
                .add(ComplaintsLoadRequested()),
            child: ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: state.complaints.length,
              separatorBuilder: (_, _) => SizedBox(height: 10),
              itemBuilder: (context, index) {
                final complaint = state.complaints[index];
                return _ComplaintCard(
                  complaint: complaint,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ComplaintsBloc>(),
                        child: ComplaintDetailPage(initialComplaint: complaint),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback onTap;

  _ComplaintCard({required this.complaint, required this.onTap});

  Color get _statusColor => switch (complaint.status) {
        'open' => AppColors.orange,
        'in_review' => AppColors.blue,
        'resolved' => AppColors.success,
        'rejected' => AppColors.error,
        'cancelled' => AppColors.textSecondary,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    final date = DateFormat('yyyy/MM/dd').format(complaint.createdAt);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
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
              child: Icon(
                Icons.report_problem_outlined,
                color: color,
                size: 22,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${complaint.typeLabel} · طلب دفع #${complaint.paymentRequestId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                complaint.statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          SizedBox(height: 12),
          Text(
            'لا توجد شكاوى حتى الآن',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}
