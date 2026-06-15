import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
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

  String _formatTimeLeft(int? seconds) {
    if (seconds == null || seconds <= 0) return 'انتهى';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
            // ── Image area ─────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: a.thumbnailUrl != null
                        ? Image.network(
                            a.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.primary,
                              child: const Icon(Icons.flutter_dash,
                                  color: Colors.white54, size: 40),
                            ),
                          )
                        : Container(
                            color: AppColors.primary,
                            child: const Icon(Icons.flutter_dash,
                                color: Colors.white54, size: 40),
                          ),
                  ),
                ),
                // end time — top right (RTL: start = right)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: Colors.white, size: 10),
                        const SizedBox(width: 3),
                        Text(
                          '${a.endTime.day}/${a.endTime.month}/${a.endTime.year}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
                // favorite — top left (RTL: end = left)
                Positioned(
                  top: 6,
                  left: 6,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _isFavorite = !_isFavorite),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        _isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _isFavorite
                            ? AppColors.red
                            : AppColors.textHint,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                // watermark
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'PIGEON PLANET',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Ring + bid count row ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      ringNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$bidsCount',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),

            // ── Countdown ──────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: AppColors.red, size: 12),
                  const SizedBox(width: 3),
                  Text(
                    _formatTimeLeft(a.timeRemaining),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.divider),

            // ── Labels ────────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('السعر الحالي',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary)),
                  Text('عدد المزايدات',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),

            // ── Values ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ج.م ${_formatPrice(a.currentPrice)}',
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

            // ── Sponsor ───────────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.home_work_rounded,
                      color: AppColors.primary, size: 12),
                  const SizedBox(width: 4),
                  const Text('برعاية',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary)),
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
    );
  }
}
