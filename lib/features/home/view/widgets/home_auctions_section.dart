import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../auctions/view/pages/auction_detail_page.dart';

import '../../../../l10n/app_localizations.dart';

class HomeAuctionsSection extends StatefulWidget {
  final List<Map<String, dynamic>> auctions;

  const HomeAuctionsSection({super.key, required this.auctions});

  @override
  State<HomeAuctionsSection> createState() => _HomeAuctionsSectionState();
}

class _HomeAuctionsSectionState extends State<HomeAuctionsSection> {
  bool _isHorizontal = false;
  int _displayCount = 10;
  static const _countOptions = [4, 6, 8, 10, 12];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final screenH = MediaQuery.sizeOf(context).height;
    final screenW = MediaQuery.sizeOf(context).width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                l.endingSoon,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.auctions.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              // Count dropdown — shown only in vertical mode
              if (!_isHorizontal) ...[
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _displayCount,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontFamily: 'Cairo'),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary, size: 16),
                      items: _countOptions
                          .map((n) => DropdownMenuItem(
                              value: n, child: Text('$n')))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _displayCount = v ?? _displayCount),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Layout toggle
              GestureDetector(
                onTap: () => setState(() => _isHorizontal = !_isHorizontal),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    _isHorizontal
                        ? Icons.view_agenda_rounded
                        : Icons.view_carousel_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (_isHorizontal)
          // ── Horizontal carousel ─────────────────────────────────────────
          SizedBox(
            height: screenH * 0.41,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.only(start: 16),
              itemCount: widget.auctions.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsetsDirectional.only(end: 14),
                child: SizedBox(
                  width: screenW * 0.67,
                  child: _AuctionCard(auction: widget.auctions[i]),
                ),
              ),
            ),
          )
        else
          // ── Vertical list ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: widget.auctions
                  .take(_displayCount)
                  .map((auction) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _AuctionCard(auction: auction),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _AuctionCard extends StatelessWidget {
  final Map<String, dynamic> auction;

  const _AuctionCard({required this.auction});

  @override
  Widget build(BuildContext context) {
    final auctionId = auction['id'] as int?;
    final thumbnailUrl = auction['thumbnailUrl'] as String?;
    final placeholderColor = Color(auction['color'] as int);
    final l = AppLocalizations.of(context);

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
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // image + countdown overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                        ? Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: placeholderColor,
                              child: const Center(
                                child: Icon(Icons.flutter_dash,
                                    color: Colors.white54, size: 50),
                              ),
                            ),
                          )
                        : Container(
                            color: placeholderColor,
                            child: const Center(
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
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 13),
                            const SizedBox(width: 3),
                            Text(auction['rating'] as String,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      _OverlayChip(
                        child: Row(
                          children: [
                            const Icon(Icons.visibility_outlined,
                                color: Colors.white70, size: 12),
                            const SizedBox(width: 3),
                            Text(auction['views'] as String,
                                style: const TextStyle(
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    color: AppColors.primary.withValues(alpha: 0.92),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CountdownUnit(
                            value: auction['seconds'] as String,
                            label: l.thanya),
                        _sep(),
                        _CountdownUnit(
                            value: auction['minutes'] as String,
                            label: l.dqyqa),
                        _sep(),
                        _CountdownUnit(
                            value: auction['hours'] as String,
                            label: l.saaa2),
                        _sep(),
                        _CountdownUnit(
                            value: auction['days'] as String,
                            label: l.ywm2),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    auction['name'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(auction['origin'] as String,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(auction['note'] as String,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none_rounded,
                              size: 16),
                          label: Text(l.notifyWhenAvailable,
                              style: const TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(l.expectedPrice,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                          Text(
                            'ج.م ${auction['price']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        auction['seller'] as String,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 6),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.primaryLight,
                        child: Text('م',
                            style: const TextStyle(
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

  Widget _sep() => const Padding(
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

  const _CountdownUnit({required this.value, required this.label});

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
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ],
    );
  }
}

class _OverlayChip extends StatelessWidget {
  final Widget child;

  const _OverlayChip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}
