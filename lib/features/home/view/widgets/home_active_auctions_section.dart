import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class HomeActiveAuctionsSection extends StatefulWidget {
  final List<Map<String, dynamic>> auctions;

  const HomeActiveAuctionsSection({super.key, required this.auctions});

  @override
  State<HomeActiveAuctionsSection> createState() =>
      _HomeActiveAuctionsSectionState();
}

class _HomeActiveAuctionsSectionState
    extends State<HomeActiveAuctionsSection> {
  String _selectedFilter = '6 عرادات';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.chevron_left_rounded,
                        color: AppColors.primary, size: 20),
                    Text(
                      '← الكل',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'المزادات النشطة',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Filter row ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // filter type dropdown
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      isExpanded: true,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontFamily: 'Cairo'),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary),
                      items: ['6 عرادات', '4 عرادات', 'الكل']
                          .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v, textAlign: TextAlign.right)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedFilter = v ?? _selectedFilter),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // filter icon
              _IconBtn(icon: Icons.tune_rounded, onTap: () {}),
              const SizedBox(width: 8),
              // search icon
              _IconBtn(icon: Icons.search_rounded, onTap: () {}),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── Count label ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'عرض ${widget.auctions.length} من 6 مزاد',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.right,
          ),
        ),

        const SizedBox(height: 10),

        // ── Grid ───────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemCount: widget.auctions.length,
            itemBuilder: (context, i) =>
                _ActiveAuctionCard(auction: widget.auctions[i]),
          ),
        ),
      ],
    );
  }
}

// ── Small icon button ────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}

// ── Auction grid card ────────────────────────────────────────────────────────
class _ActiveAuctionCard extends StatefulWidget {
  final Map<String, dynamic> auction;

  const _ActiveAuctionCard({required this.auction});

  @override
  State<_ActiveAuctionCard> createState() => _ActiveAuctionCardState();
}

class _ActiveAuctionCardState extends State<_ActiveAuctionCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.auction['isFavorite'] as bool;
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.auction;
    final typeColor = Color(a['typeColor'] as int);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Image area ──────────────────────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Image.network(
                    'https://picsum.photos/seed/${a['seed']}/300/200',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Color(a['color'] as int),
                      child: const Icon(Icons.flutter_dash,
                          color: Colors.white54, size: 36),
                    ),
                  ),
                ),
              ),
              // type badge — top right
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    a['type'] as String,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // favorite — top left
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
              // countdown bar — bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5, horizontal: 8),
                  color: AppColors.primary.withValues(alpha: 0.92),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time_rounded,
                          color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        a['timeLabel'] as String,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Info area ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  a['ring'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  a['breed'] as String,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 1),
                Text(
                  a['desc'] as String,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textHint),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'ج.م ${a['price']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
