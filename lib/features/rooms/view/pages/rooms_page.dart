import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/model/seller_model.dart';
import '../../../home/view/pages/breeder_profile_page.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final _searchController = TextEditingController();
  String _query = '';
  int _filterIndex = 0;
  final Set<int> _following = {2, 5};

  static const _sellers = [
    SellerModel(
      id: 1, username: 'khalid_birds', nickname: 'خالد الزاجل',
      country: 'مصر', avgRating: 4.6, ratingsCount: 120,
      activeAuctionsCount: 1, totalBirdsCount: 6,
    ),
    SellerModel(
      id: 2, username: 'ahmed_salem', nickname: 'أحمد السالم',
      country: 'السعودية', avgRating: 4.8, ratingsCount: 312,
      activeAuctionsCount: 2, totalBirdsCount: 15,
    ),
    SellerModel(
      id: 3, username: 'mo_otibi', nickname: 'محمد العتيبي',
      country: 'الكويت', avgRating: 4.9, ratingsCount: 487,
      activeAuctionsCount: 3, totalBirdsCount: 22,
    ),
    SellerModel(
      id: 4, username: 'saad_harbi', nickname: 'سعد الحربي',
      country: 'السعودية', avgRating: 4.3, ratingsCount: 89,
      activeAuctionsCount: 1, totalBirdsCount: 8,
    ),
    SellerModel(
      id: 5, username: 'nasser_uae', nickname: 'ناصر الإماراتي',
      country: 'الإمارات', avgRating: 4.7, ratingsCount: 201,
      activeAuctionsCount: 4, totalBirdsCount: 18,
    ),
    SellerModel(
      id: 6, username: 'ibrahim_belgika', nickname: 'إبراهيم البلجيكي',
      country: 'مصر', avgRating: 4.5, ratingsCount: 155,
      activeAuctionsCount: 0, totalBirdsCount: 12,
    ),
    SellerModel(
      id: 7, username: 'tariq_jo', nickname: 'طارق الأردن',
      country: 'الأردن', avgRating: 4.2, ratingsCount: 67,
      activeAuctionsCount: 2, totalBirdsCount: 9,
    ),
    SellerModel(
      id: 8, username: 'omar_dutch', nickname: 'عمر الهولندي',
      country: 'ليبيا', avgRating: 4.8, ratingsCount: 390,
      activeAuctionsCount: 5, totalBirdsCount: 30,
    ),
    SellerModel(
      id: 9, username: 'yousef_eagles', nickname: 'يوسف النسور',
      country: 'العراق', avgRating: 4.6, ratingsCount: 178,
      activeAuctionsCount: 0, totalBirdsCount: 11,
    ),
    SellerModel(
      id: 10, username: 'faisal_qtr', nickname: 'فيصل القطري',
      country: 'قطر', avgRating: 4.9, ratingsCount: 521,
      activeAuctionsCount: 6, totalBirdsCount: 40,
    ),
  ];

  static const _filters = ['الكل', 'نشط الآن', 'الأعلى تقييمًا'];

  List<SellerModel> get _filtered {
    var list = _sellers.toList();
    if (_filterIndex == 1) {
      list = list.where((s) => s.activeAuctionsCount > 0).toList();
    } else if (_filterIndex == 2) {
      list.sort((a, b) => b.avgRating.compareTo(a.avgRating));
    }
    if (_query.isNotEmpty) {
      list = list
          .where(
            (s) =>
                s.nickname.contains(_query) || s.country.contains(_query),
          )
          .toList();
    }
    return list;
  }

  int get _totalActiveAuctions =>
      _sellers.fold(0, (sum, s) => sum + s.activeAuctionsCount);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          // ── Green header (appbar + search) ─────────────────────────────────
          Container(
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Title row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'الغرف',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Stats badges
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        _StatBadge(
                          value: '${_sellers.length}',
                          label: 'مربي',
                        ),
                        const SizedBox(width: 10),
                        _StatBadge(
                          value:
                              '${_sellers.where((s) => s.activeAuctionsCount > 0).length}',
                          label: 'نشط الآن',
                        ),
                        const SizedBox(width: 10),
                        _StatBadge(
                          value: '$_totalActiveAuctions',
                          label: 'مزاد مفتوح',
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'ابحث عن مربي أو بلد...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.textHint,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 13),
                        ),
                        onChanged: (v) =>
                            setState(() => _query = v.trim()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Filter chips ────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: List.generate(_filters.length, (i) {
                final active = i == _filterIndex;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filterIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _filters[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── Seller list ─────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد نتائج',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final s = filtered[i];
                      return _SellerTile(
                        seller: s,
                        isFollowing: _following.contains(s.id),
                        onFollowToggle: () => setState(() {
                          if (_following.contains(s.id)) {
                            _following.remove(s.id);
                          } else {
                            _following.add(s.id);
                          }
                        }),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Stat badge ────────────────────────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final String value;
  final String label;

  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Seller tile ───────────────────────────────────────────────────────────────
class _SellerTile extends StatelessWidget {
  final SellerModel seller;
  final bool isFollowing;
  final VoidCallback onFollowToggle;

  const _SellerTile({
    required this.seller,
    required this.isFollowing,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    final hasActive = seller.activeAuctionsCount > 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BreederProfilePage(seller: seller),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar — rightmost in RTL
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: hasActive
                          ? [AppColors.primary, AppColors.primaryDark]
                          : [AppColors.border, AppColors.border],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: NetworkImage(
                      'https://picsum.photos/seed/${seller.id}/80/80',
                    ),
                    onBackgroundImageError: (_, _) {},
                  ),
                ),
                if (hasActive)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: Colors.green.shade500,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Name + info — expands in middle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          seller.nickname,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${seller.activeAuctionsCount} مزاد',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 11,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        seller.country,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${seller.avgRating.toStringAsFixed(1)} (${seller.ratingsCount})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Follow button — leftmost in RTL
            GestureDetector(
              onTap: onFollowToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isFollowing ? Colors.transparent : AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        isFollowing ? AppColors.border : AppColors.primary,
                  ),
                ),
                child: Text(
                  isFollowing ? 'متابَق' : 'متابعة',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isFollowing
                        ? AppColors.textSecondary
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
