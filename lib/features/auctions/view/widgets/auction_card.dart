import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../model/auction_model.dart';
import '../pages/auction_detail_page.dart';

class AuctionCard extends StatefulWidget {
  final AuctionModel auction;

  const AuctionCard({super.key, required this.auction});

  @override
  State<AuctionCard> createState() => _AuctionCardState();
}

class _AuctionCardState extends State<AuctionCard> {
  bool _isFavorite = false;

  String _formatTimeLeft(BuildContext context, int? seconds) {
    final l = AppLocalizations.of(context);
    if (seconds == null || seconds <= 0) return l.auctionEnded;
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _countdownColor(int? seconds) {
    if (seconds == null || seconds <= 0) return AppColors.textHint;
    if (seconds < 3600) return AppColors.red;
    if (seconds < 21600) return AppColors.orange;
    return AppColors.primary;
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      final parts = price.toStringAsFixed(0);
      final result = StringBuffer();
      int count = 0;
      for (int i = parts.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) result.write(',');
        result.write(parts[i]);
        count++;
      }
      return result.toString().split('').reversed.join();
    }
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final a = widget.auction;
    final ringNumber = a.items.isNotEmpty ? a.items.first.bird.ringNumber : a.title;
    final bidsCount = a.items.isNotEmpty ? a.items.first.bids.length : a.itemCount;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AuctionDetailPage(auctionId: a.id)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image (flex 2) ─────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    child: a.thumbnailUrl != null
                        ? Image.network(
                            a.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.primaryLight,
                              child: const Icon(Icons.image_not_supported_rounded,
                                  color: AppColors.primary, size: 64),
                            ),
                          )
                        : Container(
                            color: AppColors.primaryLight,
                            child: const Icon(Icons.flutter_dash,
                                color: AppColors.primary, size: 64),
                          ),
                  ),
                  // auction type badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        a.auctionTypeDisplay,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // favorite
                  Positioned(
                    top: 6,
                    left: 6,
                    child: GestureDetector(
                      onTap: () => setState(() => _isFavorite = !_isFavorite),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? AppColors.red : AppColors.textHint,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  // end date strip
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: Colors.white70, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            '${a.endTime.day}/${a.endTime.month}/${a.endTime.year}',
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Ring + countdown (flex 1) ──────────────────────────────────
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 3),
                    child: Text(
                      ringNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            color: _countdownColor(a.timeRemaining), size: 12),
                        const SizedBox(width: 3),
                        Text(
                          _formatTimeLeft(context, a.timeRemaining),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _countdownColor(a.timeRemaining),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Price + sponsor (flex 1) ───────────────────────────────────
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(height: 1, color: AppColors.divider),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l.currentPrice,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textSecondary)),
                        Text(l.bidCount,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l.priceEgpFormat(_formatPrice(a.currentPrice)),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '$bidsCount',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.home_work_rounded,
                            color: AppColors.primary, size: 12),
                        const SizedBox(width: 4),
                        Text(l.sponsored,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textSecondary)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            a.sellerNickname,
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
