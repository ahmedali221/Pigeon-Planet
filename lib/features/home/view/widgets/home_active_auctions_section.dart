import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../auctions/view/pages/auction_detail_page.dart';
import '../../../auctions/view/pages/auctions_page.dart';

import '../../../../l10n/app_localizations.dart';

class HomeActiveAuctionsSection extends StatefulWidget {
  final List<Map<String, dynamic>> auctions;
  final bool isSellerView;

  const HomeActiveAuctionsSection({
    super.key,
    required this.auctions,
    this.isSellerView = false,
  });

  @override
  State<HomeActiveAuctionsSection> createState() =>
      _HomeActiveAuctionsSectionState();
}

class _HomeActiveAuctionsSectionState
    extends State<HomeActiveAuctionsSection> {
  String _allTypes = '';

  String _selectedType = '';
  String _query = '';
  bool _favoritesOnly = false;
  bool _searchOpen = false;
  bool _initialized = false;
  bool _isHorizontal = false;
  int _displayCount = 10;
  static const _countOptions = [4, 6, 8, 10, 12];
  final _searchCtrl = TextEditingController();
  final Set<int> _favorites = {};

  @override
  void initState() {
    super.initState();
    for (final a in widget.auctions) {
      if (a['isFavorite'] == true && a['id'] is int) {
        _favorites.add(a['id'] as int);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _allTypes = AppLocalizations.of(context).klAlanwaa;
      _selectedType = _allTypes;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _typeOptions {
    final types = <String>{};
    for (final a in widget.auctions) {
      final t = (a['type'] as String?)?.trim();
      if (t != null && t.isNotEmpty) types.add(t);
    }
    return [_allTypes, ...types];
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _query.trim().toLowerCase();
    return widget.auctions.where((a) {
      if (_selectedType != _allTypes && (a['type'] as String?) != _selectedType) {
        return false;
      }
      if (_favoritesOnly && !_favorites.contains(a['id'])) {
        return false;
      }
      if (q.isNotEmpty) {
        final hay =
            '${a['ring'] ?? ''} ${a['breed'] ?? ''} ${a['desc'] ?? ''}'
                .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  void _toggleFavorite(int id) {
    setState(() {
      if (!_favorites.add(id)) _favorites.remove(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = _typeOptions;
    if (!options.contains(_selectedType)) _selectedType = _allTypes;

    final filtered = _filtered;
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
                widget.isSellerView ? l.myAuctions : l.activeAuctions,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (!widget.isSellerView)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AuctionsPage()),
                  ),
                  child: Row(
                    children: [
                      Text(
                        l.all,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.chevron_left_rounded,
                          color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Filter row ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
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
                      value: _selectedType,
                      isExpanded: true,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontFamily: 'Cairo'),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary),
                      items: options
                          .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v, textAlign: TextAlign.start)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedType = v ?? _selectedType),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // count dropdown — grid (vertical) mode, customers only
              if (!_isHorizontal && !widget.isSellerView) ...[
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          color: AppColors.textSecondary, size: 18),
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
              _IconBtn(
                icon: _favoritesOnly
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                active: _favoritesOnly,
                onTap: () =>
                    setState(() => _favoritesOnly = !_favoritesOnly),
              ),
              const SizedBox(width: 8),
              _IconBtn(
                icon: _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                active: _searchOpen,
                onTap: () => setState(() {
                  _searchOpen = !_searchOpen;
                  if (!_searchOpen) {
                    _searchCtrl.clear();
                    _query = '';
                  }
                }),
              ),
              const SizedBox(width: 8),
              // Layout toggle
              _IconBtn(
                icon: _isHorizontal
                    ? Icons.grid_view_rounded
                    : Icons.view_carousel_rounded,
                active: false,
                onTap: () => setState(() => _isHorizontal = !_isHorizontal),
              ),
            ],
          ),
        ),

        // ── Search field ────────────────────────────────────────────────────
        if (_searchOpen) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: l.searchActiveAuctionsHint,
                hintStyle:
                    const TextStyle(color: AppColors.textHint, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 20),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ],

        const SizedBox(height: 8),

        // ── Count label ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            () {
              final int shown;
              if (_isHorizontal || widget.isSellerView) {
                shown = filtered.length;
              } else {
                shown = filtered.length > _displayCount
                    ? _displayCount
                    : filtered.length;
              }
              return 'عرض $shown من ${widget.auctions.length} مزاد';
            }(),
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.start,
          ),
        ),

        const SizedBox(height: 10),

        // ── Content: grid or horizontal scroll ──────────────────────────────
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 40,
                      color: AppColors.textHint.withValues(alpha: 0.7)),
                  const SizedBox(height: 8),
                  const Text(
                    'لا توجد مزادات مطابقة',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else if (_isHorizontal)
          // ── Horizontal carousel ───────────────────────────────────────────
          SizedBox(
            height: screenH * 0.30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.only(start: 12),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final a = filtered[i];
                final id = a['id'] as int?;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: SizedBox(
                    width: screenW * 0.42,
                    child: _ActiveAuctionCard(
                      auction: a,
                      isFavorite: id != null && _favorites.contains(id),
                      onToggleFavorite:
                          id != null ? () => _toggleFavorite(id) : null,
                    ),
                  ),
                );
              },
            ),
          )
        else ...[
          // ── Responsive grid ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final w = constraints.maxWidth;
                final cols = w < 380 ? 1 : w < 640 ? 2 : 3;
                final ratio = cols == 1 ? 1.6 : cols == 2 ? 0.72 : 0.68;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: ratio,
                  ),
                  itemCount: widget.isSellerView
                      ? filtered.length
                      : (filtered.length > _displayCount
                          ? _displayCount
                          : filtered.length),
                  itemBuilder: (context, i) {
                    final a = filtered[i];
                    final id = a['id'] as int?;
                    return _ActiveAuctionCard(
                      auction: a,
                      isFavorite: id != null && _favorites.contains(id),
                      onToggleFavorite:
                          id != null ? () => _toggleFavorite(id) : null,
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          if (!widget.isSellerView)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AuctionsPage()),
                  ),
                  icon: const Icon(Icons.gavel_rounded, size: 18),
                  label: Text(
                    'عرض جميع المزادات (${widget.auctions.length})',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

// ── Small icon button ────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: active ? AppColors.primary : AppColors.border),
        ),
        child: Icon(icon,
            color: active ? AppColors.primary : AppColors.textSecondary,
            size: 20),
      ),
    );
  }
}

// ── Auction grid card ────────────────────────────────────────────────────────
class _ActiveAuctionCard extends StatelessWidget {
  final Map<String, dynamic> auction;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const _ActiveAuctionCard({
    required this.auction,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final a = auction;
    final typeColor = Color(a['typeColor'] as int);
    final auctionId = a['id'] as int?;
    final thumbnailUrl = a['thumbnailUrl'] as String?;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ───────────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                        ? Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _placeholder(a['color'] as int),
                          )
                        : _placeholder(a['color'] as int),
                  ),
                ),
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
                Positioned(
                  top: 6,
                  left: 6,
                  child: GestureDetector(
                    onTap: onToggleFavorite,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.red : AppColors.textHint,
                        size: 16,
                      ),
                    ),
                  ),
                ),
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

            // ── Info ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a['ring'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    a['breed'] as String,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    a['desc'] as String,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textHint),
                    textAlign: TextAlign.start,
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
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(int color) => Container(
        color: Color(color),
        child: const Center(
          child: Icon(Icons.flutter_dash, color: Colors.white54, size: 36),
        ),
      );
}
