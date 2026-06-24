import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../feed/viewmodel/feed_bloc.dart';
import '../../model/auction_item_model.dart';
import '../../model/auction_model.dart';
import '../../viewmodel/auctions_bloc.dart';
import '../widgets/auction_chat_section.dart';
import 'auction_edit_page.dart';
import 'auction_item_detail_page.dart';

class AuctionDetailPage extends StatelessWidget {
  final int auctionId;
  const AuctionDetailPage({super.key, required this.auctionId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<AuctionsBloc>()..add(AuctionDetailRequested(auctionId)),
        ),
        BlocProvider(
          create: (_) => sl<FeedBloc>()..add(const FeedStarted()),
        ),
      ],
      child: const _AuctionOverviewView(),
    );
  }
}

class _AuctionOverviewView extends StatelessWidget {
  const _AuctionOverviewView();

  void _confirmCancel(BuildContext context, int auctionId) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.cancelAuctionTitle),
        content: Text(l.cancelAuctionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.back),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuctionsBloc>().add(AuctionCancelRequested(auctionId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l.cancelAuctionTitle, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PPWAppBar(
        title: l.auctionDetails,
        actions: [
          BlocBuilder<AuctionsBloc, AuctionsState>(
            buildWhen: (p, c) =>
                p.selectedAuction?.isOwner != c.selectedAuction?.isOwner ||
                p.selectedAuction?.status != c.selectedAuction?.status ||
                p.isCancelling != c.isCancelling ||
                p.isUpdating != c.isUpdating,
            builder: (context, state) {
              final auction = state.selectedAuction;
              if (auction == null) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (auction.isOwner && auction.isActive) ...[
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      tooltip: l.edit,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AuctionsBloc>(),
                            child: AuctionEditPage(auction: auction),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: state.isCancelling
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.cancel_outlined, color: Colors.white),
                      tooltip: l.cancelAuctionTitle,
                      onPressed: state.isCancelling
                          ? null
                          : () => _confirmCancel(context, auction.id),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<AuctionsBloc, AuctionsState>(
        listenWhen: (p, c) =>
            (p.isCancelling && !c.isCancelling),
        listener: (context, state) {
          if (state.cancelError != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.cancelError!),
              backgroundColor: AppColors.error,
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l.auctionCancelledSuccess),
              backgroundColor: AppColors.success,
            ));
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state.status == AuctionsStatus.loading ||
              state.selectedAuction == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state.status == AuctionsStatus.error) {
            return Center(
              child: Text(
                state.errorMessage ?? l.errorOccurred,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            );
          }

          final auction = state.selectedAuction!;
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AuctionHeader(auction: auction),
                const SizedBox(height: 12),
                if (auction.description.isNotEmpty) ...[
                  _DescriptionCard(text: auction.description),
                  const SizedBox(height: 12),
                ],
                AuctionChatSection(auction: auction),
                const SizedBox(height: 12),
                _SectionLabel(
                  label: l.birdsInThisAuction,
                  count: auction.items.length,
                ),
                const SizedBox(height: 8),
                ...auction.items.map(
                  (item) => _AuctionItemCard(
                    auction: auction,
                    item: item,
                    bloc: context.read<AuctionsBloc>(),
                  ),
                ),
                if (auction.events.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SectionLabel(
                    label: 'Events',
                    count: auction.events.length,
                  ),
                  const SizedBox(height: 8),
                  ...auction.events.map((event) => _AuctionEventRow(
                        title: event.eventTypeDisplay.isNotEmpty
                            ? event.eventTypeDisplay
                            : event.eventType,
                        notes: event.notes,
                        created: event.created,
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Auction header card ───────────────────────────────────────────────────────
class _AuctionEventRow extends StatelessWidget {
  final String title;
  final String notes;
  final DateTime? created;

  const _AuctionEventRow({
    required this.title,
    required this.notes,
    required this.created,
  });

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.history_rounded,
              size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    notes,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (created != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    _formatDate(created!),
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuctionHeader extends StatelessWidget {
  final AuctionModel auction;
  const _AuctionHeader({required this.auction});

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _timeRemaining(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = DateTime.now();
    if (auction.isEnded || auction.endTime.isBefore(now)) return l.auctionEnded;
    final diff = auction.endTime.difference(now);
    if (diff.inDays > 0) return l.daysRemaining(diff.inDays);
    if (diff.inHours > 0) return l.hoursRemaining(diff.inHours);
    if (diff.inMinutes > 0) return l.minutesRemaining(diff.inMinutes);
    return l.endingSoon;
  }

  String _statusLabel(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (auction.statusDisplay.isNotEmpty) return auction.statusDisplay;
    if (auction.isActive) return l.statusActive;
    if (auction.isEnded) return l.statusEnded;
    return l.statusUpcoming;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final statusColor = auction.isActive
        ? AppColors.primary
        : auction.isEnded
            ? AppColors.textSecondary
            : AppColors.blue;
    final statusLabel = _statusLabel(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── top row: title + type badge ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    auction.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 8),
                _Badge(
                    label: auction.auctionTypeDisplay.isNotEmpty
                        ? auction.auctionTypeDisplay
                        : auction.auctionType,
                    color: AppColors.blue),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── status + seller ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _Badge(label: statusLabel, color: statusColor),
                const SizedBox(width: 10),
                const Icon(Icons.person_outline,
                    size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  auction.sellerNickname.isNotEmpty
                      ? auction.sellerNickname
                      : '—',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),

          // ── timing grid ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.access_time_rounded,
                  label: _timeRemaining(context),
                  color: auction.isActive
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: _formatDate(auction.endTime),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── min increment + item count ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.trending_up_rounded,
                  label: l.minBidLabel(_fmt(auction.minBidIncrement)),
                  color: AppColors.orange,
                ),
                _InfoChip(
                  icon: Icons.filter_none_rounded,
                  label: l.birdCount(auction.items.length),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v == 0) return '0';
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(',');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }
}

// ── Description card ──────────────────────────────────────────────────────────
class _DescriptionCard extends StatelessWidget {
  final String text;
  const _DescriptionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.auctionDescriptionLabel,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(text,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5)),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  const _SectionLabel({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10)),
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Per-item card ─────────────────────────────────────────────────────────────
class _AuctionItemCard extends StatelessWidget {
  final AuctionModel auction;
  final AuctionItemModel item;
  final AuctionsBloc bloc;

  const _AuctionItemCard({
    required this.auction,
    required this.item,
    required this.bloc,
  });

  String _fmt(double v) {
    if (v == 0) return '0';
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(',');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }

  Color get _statusColor {
    if (item.status == 'sold') return AppColors.orange;
    if (item.status == 'unsold' || item.status == 'cancelled') {
      return AppColors.textSecondary;
    }
    if (auction.isActive) return AppColors.primary;
    if (auction.isEnded) return AppColors.textSecondary;
    return AppColors.blue;
  }

  String _statusLabel(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (item.status == 'sold') return l.statusSold;
    if (item.status == 'unsold') return l.statusUnsold;
    if (item.status == 'cancelled') return l.statusCancelled;
    if (auction.isActive) return l.statusActive;
    if (auction.isEnded) return l.statusEnded;
    return l.statusUpcoming;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bird = item.bird;
    final thumb = bird.imageUrls.isNotEmpty ? bird.imageUrls.first : null;
    final isDone = item.isSold ||
        item.status == 'unsold' ||
        item.status == 'cancelled';
    final statusLabel = _statusLabel(context);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: bloc),
              BlocProvider.value(value: context.read<FeedBloc>()),
            ],
            child: AuctionItemDetailPage(auction: auction, item: item),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Stack(
          children: [
            Row(
          children: [
            // ── thumbnail ──
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(14)),
              child: thumb != null
                  ? Image.network(thumb,
                      width: 100,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _PlaceholderThumb())
                  : _PlaceholderThumb(),
            ),
            const SizedBox(width: 12),

            // ── info ──
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bird.name.isNotEmpty
                                ? bird.name
                                : l.birdNumber(item.id),
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _Badge(
                            label: statusLabel,
                            color: _statusColor),
                        const SizedBox(width: 12),
                      ],
                    ),
                    if (bird.colour.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(bird.colour,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(l.startingPriceLabel,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color:
                                        AppColors.textSecondary)),
                            Text(
                              '${_fmt(item.startingPrice)} ج.م',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textHint,
                                  decoration:
                                      TextDecoration.lineThrough),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(l.currentPrice,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color:
                                        AppColors.textSecondary)),
                            Text(
                              '${_fmt(item.currentPrice)} ج.م',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.gavel_rounded,
                            size: 13,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          l.bidCountLabel(item.bids.length),
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.chevron_left_rounded,
                            size: 16,
                            color: AppColors.textHint),
                        Text(l.details,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (isDone) ...[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                  color: Colors.black.withValues(alpha: 0.06)),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: item.isSold
                    ? AppColors.primary.withValues(alpha: 0.88)
                    : AppColors.textSecondary.withValues(alpha: 0.88),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.isSold
                        ? Icons.check_circle_rounded
                        : Icons.block_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
        ),
      ),
    );
  }
}

class _PlaceholderThumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 100,
        height: 110,
        color: AppColors.primaryLight,
        child: const Icon(Icons.flutter_dash_rounded,
            color: AppColors.primary, size: 36),
      );
}

// ── Shared helpers ────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color)),
      );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      );
}
