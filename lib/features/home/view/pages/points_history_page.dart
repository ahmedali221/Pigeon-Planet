import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../model/datasources/points_remote_datasource.dart';

class PointsHistoryPage extends StatefulWidget {
  const PointsHistoryPage({super.key});

  @override
  State<PointsHistoryPage> createState() => _PointsHistoryPageState();
}

class _PointsHistoryPageState extends State<PointsHistoryPage> {
  static const int _pageSize = 20;

  int _page = 1;
  int _count = 0;
  List<PointTransactionModel> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result =
          await sl<PointsRemoteDataSource>().fetchTransactionPage(page);
      setState(() {
        _page = page;
        _count = result.count;
        _items = result.results;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل السجل. تحقق من اتصالك وحاول مجدداً.';
      });
    }
  }

  int get _totalPages => (_count / _pageSize).ceil().clamp(1, 9999);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'سجل النقاط',
          style: TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loading ? null : () => _load(page: _page),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: () => _load(page: _page))
              : _items.isEmpty
                  ? const _EmptyState()
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            itemCount: _items.length,
                            itemBuilder: (_, i) =>
                                _TransactionTile(tx: _items[i]),
                          ),
                        ),
                        _PaginationBar(
                          page: _page,
                          totalPages: _totalPages,
                          count: _count,
                          pageSize: _pageSize,
                          onPrev: _page > 1 ? () => _load(page: _page - 1) : null,
                          onNext: _page < _totalPages
                              ? () => _load(page: _page + 1)
                              : null,
                        ),
                      ],
                    ),
    );
  }
}

// ── Pagination bar ─────────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final int count;
  final int pageSize;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.count,
    required this.pageSize,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final from = (page - 1) * pageSize + 1;
    final to = (page * pageSize).clamp(0, count);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            '$from–$to من $count',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            color: onPrev != null ? AppColors.primary : AppColors.textHint,
            onPressed: onPrev,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Text(
            '$page / $totalPages',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            color: onNext != null ? AppColors.primary : AppColors.textHint,
            onPressed: onNext,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

// ── Transaction tile ───────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final PointTransactionModel tx;

  const _TransactionTile({required this.tx});

  bool get _isEarn => tx.transactionType == 'earn';

  @override
  Widget build(BuildContext context) {
    final color = _isEarn ? AppColors.primary : AppColors.orange;
    final sign = _isEarn ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isEarn ? Icons.add_rounded : Icons.remove_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.reason.isEmpty ? 'معاملة نقاط' : tx.reason,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tx.created.length >= 10 ? tx.created.substring(0, 10) : tx.created,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${tx.points}',
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'الرصيد: ${tx.balanceAfter}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty / Error states ───────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 56, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            'لا توجد معاملات نقاط بعد',
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

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 56, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
