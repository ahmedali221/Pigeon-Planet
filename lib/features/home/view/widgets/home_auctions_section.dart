import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../auctions/view/pages/auction_detail_page.dart';

import '../../../../l10n/app_localizations.dart';
class HomeAuctionsSection extends StatelessWidget {
  final List<Map<String, dynamic>> auctions;

  HomeAuctionsSection({super.key, required this.auctions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: auctions.map((auction) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: _AuctionCard(auction: auction),
          );
        }).toList(),
      ),
    );
  }
}

class _AuctionCard extends StatelessWidget {
  final Map<String, dynamic> auction;

  _AuctionCard({required this.auction});

  @override
  Widget build(BuildContext context) {
    final auctionId = auction['id'] as int?;
    final thumbnailUrl = auction['thumbnailUrl'] as String?;
    final placeholderColor = Color(auction['color'] as int);
    return GestureDetector(
      onTap: auctionId != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AuctionDetailPage(auctionId: auctionId),
                ),
              )
          : null,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // image + countdown overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                      ? Image.network(
                          thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: placeholderColor,
                            child: Center(
                              child: Icon(Icons.flutter_dash,
                                  color: Colors.white54, size: 50),
                            ),
                          ),
                        )
                      : Container(
                          color: placeholderColor,
                          child: Center(
                            child: Icon(Icons.flutter_dash,
                                color: Colors.white54, size: 50),
                          ),
                        ),
                ),
              ),
              // rating + views
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    _OverlayChip(
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: Colors.amber, size: 13),
                          SizedBox(width: 3),
                          Text(auction['rating'] as String,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                    SizedBox(width: 6),
                    _OverlayChip(
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined,
                              color: Colors.white70, size: 12),
                          SizedBox(width: 3),
                          Text(auction['views'] as String,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // countdown bar
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
                          value: auction['seconds'] as String,
                          label: 'ثانية'),
                      _sep(),
                      _CountdownUnit(
                          value: auction['minutes'] as String,
                          label: 'دقيقة'),
                      _sep(),
                      _CountdownUnit(
                          value: auction['hours'] as String, label: 'ساعة'),
                      _sep(),
                      _CountdownUnit(
                          value: auction['days'] as String, label: 'يوم'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // details
          Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  auction['name'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(auction['origin'] as String,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                SizedBox(height: 2),
                Text(auction['note'] as String,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.notifications_none_rounded,
                            size: 16),
                        label: Text(AppLocalizations.of(context).notifyWhenAvailable,
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(AppLocalizations.of(context).expectedPrice,
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                        Text(
                          'ج.م ${auction['price']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      auction['seller'] as String,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 6),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.primaryLight,
                      child: Text('م',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.primary)),
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

  Widget _sep() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Text(':',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      );
}

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
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(value,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

class _OverlayChip extends StatelessWidget {
  final Widget child;
  _OverlayChip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}
