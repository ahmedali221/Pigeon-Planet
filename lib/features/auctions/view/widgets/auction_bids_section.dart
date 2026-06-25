import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../model/bid_model.dart';

class AuctionBidsSection extends StatelessWidget {
  final List<BidModel> bids;
  final bool isOwner;

  const AuctionBidsSection({
    super.key,
    required this.bids,
    this.isOwner = false,
  });

  String _fmtPrice(double v) {
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

  String _fmtDate(DateTime dt, AppLocalizations l) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return l.now;
    if (diff.inMinutes < 60) return l.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l.hoursAgo(diff.inHours);
    return l.daysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.gavel_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.bidders,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${bids.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            if (bids.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l.noBidsYet,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bids.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (_, i) {
                  final bid = bids[i];
                  final isTop = i == 0;
                  return _OwnerBidRow(
                      bid: bid,
                      isTop: isTop,
                      rank: i + 1,
                      fmtPrice: _fmtPrice,
                      fmtDate: (dt) => _fmtDate(dt, l),
                      l: l,
                    );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ── Owner view: shows username, phone, block/unblock ─────────────────────────
class _OwnerBidRow extends StatelessWidget {
  final BidModel bid;
  final bool isTop;
  final int rank;
  final String Function(double) fmtPrice;
  final String Function(DateTime) fmtDate;
  final AppLocalizations l;

  const _OwnerBidRow({
    required this.bid,
    required this.isTop,
    required this.rank,
    required this.fmtPrice,
    required this.fmtDate,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    final username = bid.bidderUsername?.isNotEmpty == true
        ? bid.bidderUsername!
        : l.unknown;
    final avatarLetter =
        bid.bidderUsername?.isNotEmpty == true ? bid.bidderUsername![0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isTop
                    ? const Color(0xFFD4A017)
                    : AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  avatarLetter,
                  style: TextStyle(
                    color: isTop ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isTop)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFD4A017),
                    size: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isTop ? const Color(0xFFD4A017) : AppColors.textPrimary,
                  ),
                ),
                if (bid.bidderPhone != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    bid.bidderPhone!,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  fmtDate(bid.created),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l.auctionBidAmountEgp(fmtPrice(bid.amount)),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isTop ? const Color(0xFFD4A017) : AppColors.textPrimary,
                ),
              ),
              if (bid.isWinningBid)
                Text(
                  l.highestBid,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFD4A017),
                      fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
