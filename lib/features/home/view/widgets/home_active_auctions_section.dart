import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../auctions/view/pages/auction_detail_page.dart';
import '../../../auctions/view/pages/auctions_page.dart';

import '../../../../l10n/app_localizations.dart';
class HomeActiveAuctionsSection extends StatefulWidget {
  final List<Map<String, dynamic>> auctions;

  HomeActiveAuctionsSection({super.key, required this.auctions});

  @override
  State<HomeActiveAuctionsSection> createState() =>
      _HomeActiveAuctionsSectionState();
}

class _HomeActiveAuctionsSectionState
    extends State<HomeActiveAuctionsSection> {
  static String _allTypes = 'كل الأنواع';

  String _selectedType = _allTypes;
  String _query = '';
  bool _favoritesOnly = false;
  bool _searchOpen = false;
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
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Distinct auction-type labels present in the data, plus an "all" option.
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
    // Keep the dropdown value valid if the data no longer has the selected type.
    final options = _typeOptions;
    if (!options.contains(_selectedType)) _selectedType = _allTypes;

    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context).activeAuctions,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AuctionsPage()),
                ),
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

        // ── Filter row ─────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // type filter dropdown
              Expanded(
                child: Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      isExpanded: true,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontFamily: 'Cairo'),
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
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
              SizedBox(width: 8),
              // favorites filter
              _IconBtn(
                icon: _favoritesOnly
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                active: _favoritesOnly,
                onTap: () =>
                    setState(() => _favoritesOnly = !_favoritesOnly),
              ),
              SizedBox(width: 8),
              // search toggle
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
            ],
          ),
        ),

        // ── Search field (toggled) ─────────────────────────────────────────
        if (_searchOpen) ...[
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchActiveAuctionsHint,
                hintStyle:
                    TextStyle(color: AppColors.textHint, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 20),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ],

        SizedBox(height: 8),

        // ── Count label ────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'عرض ${filtered.length} من ${widget.auctions.length} مزاد',
            style: TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.start,
          ),
        ),

        SizedBox(height: 10),

        // ── Grid / empty state ─────────────────────────────────────────────
        if (filtered.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 40,
                      color: AppColors.textHint.withValues(alpha: 0.7)),
                  SizedBox(height: 8),
                  Text(
                    'لا توجد مزادات مطابقة',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemCount: filtered.length,
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
  final bool active;

  _IconBtn({required this.icon, required this.onTap, this.active = false});

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

  _ActiveAuctionCard({
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
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ──────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
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
                // type badge — top right
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      a['type'] as String,
                      style: TextStyle(
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
                    onTap: onToggleFavorite,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.red : AppColors.textHint,
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
                    padding: EdgeInsets.symmetric(
                        vertical: 5, horizontal: 8),
                    color: AppColors.primary.withValues(alpha: 0.92),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time_rounded,
                            color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          a['timeLabel'] as String,
                          style: TextStyle(
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
              padding: EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a['ring'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    a['breed'] as String,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 1),
                  Text(
                    a['desc'] as String,
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textHint),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'ج.م ${a['price']}',
                    style: TextStyle(
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
        child: Center(
          child: Icon(Icons.flutter_dash, color: Colors.white54, size: 36),
        ),
      );
}
