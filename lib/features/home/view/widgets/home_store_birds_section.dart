import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../auctions/model/bird_summary_model.dart';
import '../../../auctions/view/pages/bird_detail_page.dart';
import '../../../cart/viewmodel/cart_bloc.dart';
import '../../../../l10n/app_localizations.dart';

class HomeStoreBirdsSection extends StatefulWidget {
  final List<BirdSummaryModel> birds;
  final bool isLoading;

  HomeStoreBirdsSection({super.key, required this.birds, this.isLoading = false});

  @override
  State<HomeStoreBirdsSection> createState() => _HomeStoreBirdsSectionState();
}

class _HomeStoreBirdsSectionState extends State<HomeStoreBirdsSection> {
  String _selectedGender = '';
  String _query = '';
  bool _searchOpen = false;
  bool _initialized = false;

  String _allLabel = '';
  final _searchCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _allLabel = AppLocalizations.of(context).klAlanwaa;
      _selectedGender = _allLabel;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _genderOptions {
    final l = AppLocalizations.of(context);
    return [_allLabel, l.male, l.female, l.genderYoung];
  }

  List<BirdSummaryModel> get _filtered {
    final l = AppLocalizations.of(context);
    final q = _query.trim().toLowerCase();
    return widget.birds.where((b) {
      if (_selectedGender != _allLabel) {
        final gLabel = b.gender == 'male'
            ? l.male
            : b.gender == 'female'
                ? l.female
                : l.genderYoung;
        if (gLabel != _selectedGender) return false;
      }
      if (q.isNotEmpty) {
        final hay =
            '${b.name} ${b.ringNumber} ${b.colour} ${b.description}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  static String _fmt(double v) {
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

  void _navigateToBird(BirdSummaryModel bird) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CartBloc>(),
          child: BirdDetailPage(bird: bird, sellerNickname: bird.sellerNickname),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final filtered = _filtered;
    final displayed = filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ───────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.flutter_dash,
                    color: AppColors.primary, size: 18),
              ),
              SizedBox(width: 8),
              Text(
                l.fixedPriceBirds,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(l.all,
                        style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_left_rounded,
                        color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 10),

        // ── Filter row ───────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // gender dropdown
              Expanded(
                child: _Dropdown(
                  value: _selectedGender,
                  options: _genderOptions,
                  onChanged: (v) => setState(() => _selectedGender = v),
                ),
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

        // ── Search field ─────────────────────────────────────────────────────
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
                hintText: 'ابحث باسم الطائر أو رقم الحلقة...',
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
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
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ],

        SizedBox(height: 8),

        // ── Count label ──────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'عرض ${displayed.length} من ${widget.birds.length} طائر',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.start,
          ),
        ),

        SizedBox(height: 10),

        // ── Loading skeletons ────────────────────────────────────────────────
        if (widget.isLoading)
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: 4,
              itemBuilder: (_, _) => _SkeletonCard(),
            ),
          )
        // ── Empty state ──────────────────────────────────────────────────────
        else if (displayed.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.flutter_dash,
                      size: 40,
                      color: AppColors.textHint.withValues(alpha: 0.7)),
                  SizedBox(height: 8),
                  Text(
                    widget.birds.isEmpty
                        ? 'لا توجد طيور في المتجر'
                        : 'لا توجد طيور مطابقة',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        // ── Horizontal scroll list ───────────────────────────────────────────
        else ...[
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: displayed.length,
              itemBuilder: (context, i) => _BirdCard(
                bird: displayed[i],
                fmtPrice: _fmt,
                onTap: () => _navigateToBird(displayed[i]),
              ),
            ),
          ),
          SizedBox(height: 14),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.flutter_dash, size: 18),
                label: Text(
                  'عرض جميع الطيور (${widget.birds.length})',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

// ── Shared dropdown widget ────────────────────────────────────────────────────

class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  _Dropdown({required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          isExpanded: true,
          style: TextStyle(
              color: AppColors.textPrimary, fontSize: 13, fontFamily: 'Cairo'),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          items: options
              .map((v) => DropdownMenuItem(
                  value: v, child: Text(v, textAlign: TextAlign.start)))
              .toList(),
          onChanged: (v) => onChanged(v ?? value),
        ),
      ),
    );
  }
}

// ── Icon button ───────────────────────────────────────────────────────────────

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

// ── Bird card (breeder-card style) ────────────────────────────────────────────

class _BirdCard extends StatelessWidget {
  final BirdSummaryModel bird;
  final String Function(double) fmtPrice;
  final VoidCallback onTap;

  _BirdCard({required this.bird, required this.fmtPrice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final thumbnailUrl = bird.thumbnailUrl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
            // ── Gradient header with bird image ──────────────────────────────
            Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.85),
                    AppColors.primary.withValues(alpha: 0.55),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // decorative circle
                  Positioned(
                    top: -10,
                    left: -10,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  // gender badge
                  if (bird.gender.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: bird.gender == 'male'
                              ? AppColors.blue
                              : AppColors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bird.gender == 'male'
                              ? l.male
                              : bird.gender == 'female'
                                  ? l.female
                                  : l.genderYoung,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  // bird image — bottom centre, overflowing
                  Positioned(
                    bottom: -24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: (thumbnailUrl != null &&
                                  thumbnailUrl.isNotEmpty)
                              ? NetworkImage(thumbnailUrl) as ImageProvider
                              : null,
                          child: (thumbnailUrl == null || thumbnailUrl.isEmpty)
                              ? Icon(Icons.flutter_dash,
                                  color: AppColors.primary, size: 24)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 28),

            // ── Info ─────────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Text(
                    bird.name.isNotEmpty ? bird.name : bird.ringNumber,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3),
                  Text(
                    bird.colour,
                    style:
                        TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'ج.م ${fmtPrice(bird.price)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),

            // ── View details button ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: SizedBox(
                width: double.infinity,
                height: 30,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(l.viewDetails,
                      style: TextStyle(fontSize: 11)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton card ─────────────────────────────────────────────────────────────

class _SkeletonCard extends StatelessWidget {
  _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}
