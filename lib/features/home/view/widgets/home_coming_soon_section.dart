import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../auctions/model/auction_model.dart';
import '../../../auctions/view/pages/auction_detail_page.dart';

class HomeComingSoonSection extends StatelessWidget {
  final List<AuctionModel> auctions;

  const HomeComingSoonSection({super.key, required this.auctions});

  @override
  Widget build(BuildContext context) {
    if (auctions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              const Text(
                'مزادات قادمة',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    Text(
                      'الكل',
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

        const SizedBox(height: 10),

        // ── Alert banner ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDD835)),
            ),
            child: const Text(
              'سوف تنزل المزادات قريباً - كن مستعداً!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF795548),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Cards list ─────────────────────────────────────────────────────
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: auctions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
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

  const _ComingSoonCard({required this.auction});

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
        : 'لا يوجد وصف';
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
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Image area ────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
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
                            errorBuilder: (_, _, _) =>
                                _placeholder(auction.id),
                          )
                        : Image.network(
                            'https://picsum.photos/seed/${auction.id}/400/220',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _placeholder(auction.id),
                          ),
                  ),
                ),
                // type badge — top right
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      auction.auctionTypeDisplay.isNotEmpty
                          ? auction.auctionTypeDisplay
                          : 'قريباً',
                      style: const TextStyle(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'نشط',
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    color: AppColors.primary.withValues(alpha: 0.92),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CountdownUnit(
                            value: t.seconds
                                .toString()
                                .padLeft(2, '0'),
                            label: 'ثانية'),
                        _sep(),
                        _CountdownUnit(
                            value: t.minutes
                                .toString()
                                .padLeft(2, '0'),
                            label: 'دقيقة'),
                        _sep(),
                        _CountdownUnit(
                            value: t.hours
                                .toString()
                                .padLeft(2, '0'),
                            label: 'ساعة'),
                        _sep(),
                        _CountdownUnit(
                            value: t.days.toString(), label: 'يوم'),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Details ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // name + gender + ring
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (bird != null) const SizedBox(width: 4),
                      if (bird != null)
                        Icon(
                          isMale
                              ? Icons.male_rounded
                              : Icons.female_rounded,
                          size: 18,
                          color: isMale
                              ? const Color(0xFF1565C0)
                              : const Color(0xFFC62828),
                        ),
                      if (ring.isNotEmpty) const SizedBox(width: 6),
                      if (ring.isNotEmpty)
                        Text(
                          ring,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                  if (breed.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      breed,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('👤', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          pedigree,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 18, color: AppColors.divider),

                  // price row
                  Row(
                    children: [
                      // notify button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                              Icons.notifications_active_rounded,
                              size: 16),
                          label: const Text('أخبرني',
                              style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                                color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'السعر المبدئي',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                          ),
                          Text(
                            'ج.م ${_fmtPrice(price)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // seller row
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        auction.sellerNickname,
                        style: const TextStyle(
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

  Widget _sep() => const Padding(
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

  const _CountdownUnit({required this.value, required this.label});

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
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
