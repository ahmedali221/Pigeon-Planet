import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../auctions/model/auction_model.dart';
import '../../../auctions/model/bird_summary_model.dart';

import '../../../../l10n/app_localizations.dart';
class HomeMyListingsSection extends StatelessWidget {
  final List<AuctionModel> auctions;
  final List<BirdSummaryModel> birds;
  final VoidCallback? onSeeAllAuctions;
  final VoidCallback? onSeeAllBirds;
  final void Function(AuctionModel)? onAuctionTap;
  final void Function(BirdSummaryModel)? onBirdTap;

  HomeMyListingsSection({
    super.key,
    required this.auctions,
    required this.birds,
    this.onSeeAllAuctions,
    this.onSeeAllBirds,
    this.onAuctionTap,
    this.onBirdTap,
  });

  static String _fmtTime(int? seconds) {
    if (seconds == null || seconds <= 0) return 'انتهى';
    final days = seconds ~/ 86400;
    if (days > 0) return '$days يوم';
    final hours = seconds ~/ 3600;
    if (hours > 0) return '$hours ساعة';
    return '${seconds ~/ 60} دقيقة';
  }

  static String _fmtPrice(double v) {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (auctions.isNotEmpty || true) ...[
            _SectionHeader(
              title: AppLocalizations.of(context).myAuctions,
              count: auctions.length,
              icon: Icons.gavel_rounded,
              iconColor: AppColors.blue,
              onSeeAll: onSeeAllAuctions,
            ),
            SizedBox(height: 10),
            auctions.isEmpty
                ? _EmptyCard(
                    icon: Icons.gavel_rounded,
                    message: 'لا توجد مزادات مضافة بعد',
                  )
                : SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: auctions.length,
                      itemBuilder: (_, i) => _AuctionCard(
                        auction: auctions[i],
                        onTap: onAuctionTap,
                        fmtTime: _fmtTime,
                        fmtPrice: _fmtPrice,
                      ),
                    ),
                  ),
            SizedBox(height: 20),
          ],
          if (birds.isNotEmpty || true) ...[
            _SectionHeader(
              title: 'طيوري المعروضة',
              count: birds.length,
              icon: Icons.flutter_dash,
              iconColor: AppColors.orange,
              onSeeAll: onSeeAllBirds,
            ),
            SizedBox(height: 10),
            birds.isEmpty
                ? _EmptyCard(
                    icon: Icons.flutter_dash,
                    message: 'لا توجد طيور مضافة بعد',
                  )
                : SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: birds.length,
                      itemBuilder: (_, i) => _BirdCard(
                        bird: birds[i],
                        onTap: onBirdTap,
                        fmtPrice: _fmtPrice,
                      ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onSeeAll;

  _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 15),
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (count > 0) ...[
          SizedBox(width: 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ),
        ],
        Spacer(),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  'عرض الكل',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                Icon(Icons.chevron_left_rounded,
                    color: AppColors.textSecondary, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;

  _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textHint, size: 28),
          SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Auction card ──────────────────────────────────────────────────────────────

class _AuctionCard extends StatelessWidget {
  final AuctionModel auction;
  final void Function(AuctionModel)? onTap;
  final String Function(int?) fmtTime;
  final String Function(double) fmtPrice;

  _AuctionCard({
    required this.auction,
    required this.fmtTime,
    required this.fmtPrice,
    this.onTap,
  });

  Color get _statusColor {
    switch (auction.status) {
      case 'active':
        return AppColors.success;
      case 'ended':
        return AppColors.textHint;
      case 'cancelled':
        return AppColors.red;
      default:
        return AppColors.orange;
    }
  }

  String get _statusLabel {
    switch (auction.status) {
      case 'active':
        return 'نشط';
      case 'ended':
        return 'منتهي';
      case 'cancelled':
        return 'ملغي';
      default:
        return auction.statusDisplay.isNotEmpty
            ? auction.statusDisplay
            : auction.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = auction.isActive
        ? 'ينتهي خلال ${fmtTime(auction.timeRemaining)}'
        : _statusLabel;

    return GestureDetector(
      onTap: onTap != null ? () => onTap!(auction) : null,
      child: Container(
        width: 200,
        margin: EdgeInsetsDirectional.only(end: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                    ),
                  ),
                ),
                Spacer(),
                if (auction.itemCount > 0)
                  Text(
                    '${auction.itemCount} طير',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textSecondary),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              auction.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 11, color: AppColors.textHint),
                SizedBox(width: 3),
                Expanded(
                  child: Text(
                    timeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: auction.isActive
                          ? AppColors.orange
                          : AppColors.textHint,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (auction.currentPrice > 0) ...[
              SizedBox(height: 2),
              Text(
                'السعر الحالي: ${fmtPrice(auction.currentPrice)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Bird card ─────────────────────────────────────────────────────────────────

class _BirdCard extends StatelessWidget {
  final BirdSummaryModel bird;
  final void Function(BirdSummaryModel)? onTap;
  final String Function(double) fmtPrice;

  _BirdCard({
    required this.bird,
    required this.fmtPrice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(bird) : null,
      child: Container(
        width: 150,
        margin: EdgeInsetsDirectional.only(end: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(14)),
              child: SizedBox(
                height: 80,
                width: double.infinity,
                child: bird.thumbnailUrl != null
                    ? Image.network(
                        bird.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Text(
                bird.name.isNotEmpty ? bird.name : bird.ringNumber,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 2, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${fmtPrice(bird.price)} ج.م',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: bird.gender == 'male'
                          ? AppColors.blueLight
                          : AppColors.redLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      bird.gender == 'male'
                          ? 'ذكر'
                          : bird.gender == 'female'
                              ? 'أنثى'
                              : 'صغير',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: bird.gender == 'male'
                            ? AppColors.blue
                            : AppColors.red,
                      ),
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

  Widget _placeholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(Icons.flutter_dash, color: AppColors.primary, size: 32),
      ),
    );
  }
}
