import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../auctions/model/auction_model.dart';
import '../../../auctions/view/pages/auction_detail_page.dart';

import '../../../../l10n/app_localizations.dart';
class HomeComingSoonSection extends StatelessWidget {
  final List<AuctionModel> auctions;

  HomeComingSoonSection({super.key, required this.auctions});

  @override
  Widget build(BuildContext context) {
    if (auctions.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('🔥', style: TextStyle(fontSize: 18)),
              SizedBox(width: 6),
              Text(
                AppLocalizations.of(context).upcomingAuctions,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).all,
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    Icon(Icons.chevron_left_rounded,
                        color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 10),

        // ── Alert banner ───────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding:
                EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: Color(0xFFFFFDE7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color(0xFFFDD835)),
            ),
            child: Text(
              AppLocalizations.of(context).auctionsComingSoonBanner,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF795548),
              ),
            ),
          ),
        ),

        SizedBox(height: 12),

        // ── Cards list ─────────────────────────────────────────────────────
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: auctions.length,
          separatorBuilder: (_, _) => SizedBox(height: 14),
          itemBuilder: (context, i) =>
              _ComingSoonCard(auction: auctions[i]),
        ),
      ],
    );
  }
}

// ── Coming soon card ─────────────────────────────────────────────────────────
class _ComingSoonCard extends StatelessWidget {
  final AuctionModel auction;

  _ComingSoonCard({required this.auction});

  ({int days, int hours, int minutes, int seconds}) _breakdown(
      AuctionModel a) {
    final remaining = a.timeRemaining ??
        a.endTime.difference(DateTime.now()).inSeconds.clamp(0, 999999999);
    final secs = remaining.clamp(0, 999999999);
    return (
      days: secs ~/ 86400,
      hours: (secs % 86400) ~/ 3600,
      minutes: (secs % 3600) ~/ 60,
      seconds: secs % 60,
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final bird =
        auction.items.isNotEmpty ? auction.items.first.bird : null;
    final isMale = bird?.gender == 'male';
    final ring = bird?.ringNumber ?? '';
    final breed = bird?.colour ?? '';
    final name = auction.title.isNotEmpty
        ? auction.title
        : (bird?.name.isNotEmpty == true ? bird!.name : ring);
    final pedigree = auction.description.isNotEmpty
        ? auction.description
        : AppLocalizations.of(context).noDescription;
    final price = auction.items.isNotEmpty
        ? auction.items.first.startingPrice
        : auction.currentPrice;
    // Prefer the auction's own uploaded cover, then a bird image.
    final thumbnailUrl = (auction.thumbnailUrl?.isNotEmpty == true)
        ? auction.thumbnailUrl
        : bird?.thumbnailUrl;
    final t = _breakdown(auction);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AuctionDetailPage(auctionId: auction.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Image area ────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: thumbnailUrl != null
                        ? Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _placeholder(auction.id),
                          )
                        : _placeholder(auction.id),
                  ),
                ),
                // type badge — top right
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      auction.auctionTypeDisplay.isNotEmpty
                          ? auction.auctionTypeDisplay
                          : AppLocalizations.of(context).comingSoon,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // status badge — top left
                if (auction.isActive)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(context).statusActive,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                // countdown bar — bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    color: AppColors.primary.withValues(alpha: 0.92),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CountdownUnit(
                            value: t.seconds
                                .toString()
                                .padLeft(2, '0'),
                            label: AppLocalizations.of(context).countdownSecond),
                        _sep(),
                        _CountdownUnit(
                            value: t.minutes
                                .toString()
                                .padLeft(2, '0'),
                            label: AppLocalizations.of(context).countdownMinute),
                        _sep(),
                        _CountdownUnit(
                            value: t.hours
                                .toString()
                                .padLeft(2, '0'),
                            label: AppLocalizations.of(context).countdownHour),
                        _sep(),
                        _CountdownUnit(
                            value: t.days.toString(), label: AppLocalizations.of(context).countdownDay),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Details ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // name + gender + ring
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (bird != null) SizedBox(width: 4),
                      if (bird != null)
                        Icon(
                          isMale
                              ? Icons.male_rounded
                              : Icons.female_rounded,
                          size: 18,
                          color: isMale
                              ? Color(0xFF1565C0)
                              : Color(0xFFC62828),
                        ),
                      if (ring.isNotEmpty) SizedBox(width: 6),
                      if (ring.isNotEmpty)
                        Text(
                          ring,
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                  if (breed.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      breed,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary),
                    ),
                  ],
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text('👤', style: TextStyle(fontSize: 13)),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          pedigree,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),

                  Divider(height: 18, color: AppColors.divider),

                  // price row
                  Row(
                    children: [
                      // notify button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(
                              Icons.notifications_active_rounded,
                              size: 16),
                          label: Text(AppLocalizations.of(context).notifyMe,
                              style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                                color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                            padding:
                                EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppLocalizations.of(context).startingPriceLabel,
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                          ),
                          Text(
                            AppLocalizations.of(context).priceEgpFormat(_fmtPrice(price)),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // seller row
                  Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 16),
                      SizedBox(width: 6),
                      Text(
                        auction.sellerNickname,
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(int seed) => Container(
        color: AppColors.primaryLight,
        child: Center(
          child: Icon(Icons.flutter_dash,
              color: AppColors.primary.withValues(alpha: 0.4), size: 50),
        ),
      );

  Widget _sep() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Text(':',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      );
}

// ── Shared helpers ────────────────────────────────────────────────────────────
class _CountdownUnit extends StatelessWidget {
  final String value;
  final String label;

  _CountdownUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(value,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(height: 2),
        Text(label,
            style: TextStyle(color: Colors.white70, fontSize: 9)),
      ],
    );
  }
}
