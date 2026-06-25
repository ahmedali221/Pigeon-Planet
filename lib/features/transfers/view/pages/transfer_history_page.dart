import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../model/ownership_transfer_model.dart';
import '../../viewmodel/transfers_bloc.dart';

class TransferHistoryPage extends StatelessWidget {
  final int? assetId;
  final String? assetTitle;

  const TransferHistoryPage({super.key, this.assetId, this.assetTitle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TransfersBloc>()
        ..add(TransfersLoadRequested(assetId: assetId)),
      child: _TransferHistoryView(assetTitle: assetTitle),
    );
  }
}

class _TransferHistoryView extends StatelessWidget {
  final String? assetTitle;
  const _TransferHistoryView({this.assetTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PPWAppBar(
        title: assetTitle != null
            ? 'سجل ملكية: $assetTitle'
            : 'سجل نقل الملكية',
      ),
      body: BlocBuilder<TransfersBloc, TransfersState>(
        builder: (context, state) {
          if (state.status == TransfersStatus.loading ||
              state.status == TransfersStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TransfersStatus.error) {
            return _ErrorState(
              message: state.errorMessage,
              onRetry: () => context
                  .read<TransfersBloc>()
                  .add(TransfersLoadRequested(assetId: null)),
            );
          }

          if (state.transfers.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => context
                .read<TransfersBloc>()
                .add(TransfersLoadRequested(assetId: null)),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.transfers.length,
              itemBuilder: (context, i) =>
                  _TransferTile(transfer: state.transfers[i]),
            ),
          );
        },
      ),
    );
  }
}

class _TransferTile extends StatelessWidget {
  final OwnershipTransferModel transfer;
  const _TransferTile({required this.transfer});

  static const _typeColors = {
    'direct': AppColors.primary,
    'market': AppColors.orange,
    'auction': AppColors.purple,
  };

  Color get _typeColor => _typeColors[transfer.transferType] ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // bird headline + type badge
          Row(
            children: [
              // bird icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.flutter_dash_rounded,
                    color: _typeColor, size: 24),
              ),
              const SizedBox(width: 12),
              // bird name + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transfer.assetTitle.isNotEmpty
                          ? transfer.assetTitle
                          : 'طير #${transfer.assetId}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(transfer.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _TypeBadge(label: transfer.typeLabel, color: _typeColor),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          // from → to row
          Row(
            children: [
              _ProfileChip(
                name: transfer.fromProfile?.displayName ?? 'مالك أصلي',
                icon: Icons.person_outline_rounded,
                color: AppColors.textSecondary,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: AppColors.textHint,
                ),
              ),
              _ProfileChip(
                name: transfer.toProfile.displayName,
                icon: Icons.person_rounded,
                color: AppColors.primary,
              ),
            ],
          ),
          if (transfer.note?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              transfer.note!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  const _ProfileChip({
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.swap_horiz_rounded, size: 56, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            'لا يوجد سجل نقل ملكية بعد',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const _ErrorState({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            message ?? 'حدث خطأ',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
