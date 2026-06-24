import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../model/lucky_wheel_spin_history_model.dart';
import '../../viewmodel/lucky_wheel_history_cubit.dart';
import '../../model/datasources/lucky_wheel_datasource.dart';

class LuckyWheelHistoryPage extends StatelessWidget {
  LuckyWheelHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LuckyWheelHistoryCubit(sl<LuckyWheelDataSource>())..load(),
      child: _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  _HistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_forward_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'سجل عجلة الحظ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<LuckyWheelHistoryCubit, LuckyWheelHistoryState>(
            buildWhen: (prev, curr) => prev.status != curr.status,
            builder: (context, state) => IconButton(
              icon: Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: state.status == LuckyWheelHistoryStatus.loading
                  ? null
                  : () => context.read<LuckyWheelHistoryCubit>().load(),
            ),
          ),
        ],
      ),
      body: BlocBuilder<LuckyWheelHistoryCubit, LuckyWheelHistoryState>(
        builder: (context, state) {
          if (state.status == LuckyWheelHistoryStatus.initial ||
              state.status == LuckyWheelHistoryStatus.loading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state.status == LuckyWheelHistoryStatus.error) {
            return _ErrorState(
              message: state.errorMessage ?? 'حدث خطأ',
              onRetry: () => context.read<LuckyWheelHistoryCubit>().load(),
            );
          }
          if (state.spins.isEmpty) {
            return _EmptyState();
          }
          final isLoadingMore =
              state.status == LuckyWheelHistoryStatus.loadingMore;
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: state.spins.length + (state.hasMore ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == state.spins.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: isLoadingMore
                        ? CircularProgressIndicator(color: AppColors.primary)
                        : TextButton(
                            onPressed: () =>
                                context.read<LuckyWheelHistoryCubit>().loadMore(),
                            child: Text(
                              'تحميل المزيد',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                  ),
                );
              }
              return _SpinTile(spin: state.spins[i]);
            },
          );
        },
      ),
    );
  }
}

class _SpinTile extends StatelessWidget {
  final LuckyWheelSpinHistoryModel spin;

  _SpinTile({required this.spin});

  @override
  Widget build(BuildContext context) {
    final awarded = spin.wasAwarded;
    final color = awarded ? AppColors.success : AppColors.textSecondary;

    final d = spin.createdAt;
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(spin.emoji, style: TextStyle(fontSize: 22)),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spin.prizeLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '$dateStr  $timeStr',
                  style: TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              awarded ? 'تم الفوز' : 'لم تفز',
              style: TextStyle(
                fontSize: 12,
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

class _EmptyState extends StatelessWidget {
  _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد لفات بعد',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ستظهر هنا نتائج لفات عجلة الحظ الخاصة بك',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
