import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../auctions/model/bird_summary_model.dart';
import '../../../auctions/view/pages/bird_detail_page.dart';
import '../../../auctions/viewmodel/auctions_bloc.dart';
import '../../../cart/viewmodel/cart_bloc.dart';
import '../../../pigeon_id/view/pages/pigeon_id_form_page.dart';
import '../../../pigeon_id/viewmodel/pigeon_id_bloc.dart';

class SellerMyBirdsPage extends StatelessWidget {
  const SellerMyBirdsPage({super.key, this.mineOnly = true});

  final bool mineOnly;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuctionsBloc>()
        ..add(AuctionSellerBirdsRequested(mineOnly: mineOnly))
        ..add(const AuctionAvailableBirdIdsRequested()),
      child: const _SellerMyBirdsView(),
    );
  }
}

class _SellerMyBirdsView extends StatefulWidget {
  const _SellerMyBirdsView();

  @override
  State<_SellerMyBirdsView> createState() => _SellerMyBirdsViewState();
}

class _SellerMyBirdsViewState extends State<_SellerMyBirdsView> {
  // null = no filter applied
  String? _genderFilter;
  String? _auctionFilter; // 'available' | 'in_auction'

  void _refresh() {
    context.read<AuctionsBloc>()
      ..add(const AuctionSellerBirdsRequested(mineOnly: true))
      ..add(const AuctionAvailableBirdIdsRequested());
  }

  void _openAddBird() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<PigeonIdBloc>(),
          child: const PigeonIdFormPage(),
        ),
      ),
    );
    if (mounted) _refresh();
  }

  List<BirdSummaryModel> _applyFilters(
    List<BirdSummaryModel> birds,
    Set<int>? availableIds,
  ) {
    return birds.where((b) {
      if (_genderFilter != null && b.gender != _genderFilter) return false;
      if (_auctionFilter != null && availableIds != null) {
        final isAvailable = availableIds.contains(b.id);
        if (_auctionFilter == 'available' && !isAvailable) return false;
        if (_auctionFilter == 'in_auction' && isAvailable) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddBird,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'إضافة طائر',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<AuctionsBloc, AuctionsState>(
        builder: (context, state) {
          final filtered = _applyFilters(
            state.sellerBirds,
            state.availableForAuctionBirdIds,
          );
          final total = state.sellerBirds.length;
          final isFiltering = _genderFilter != null || _auctionFilter != null;
          final titleCount = isFiltering
              ? '${filtered.length}/$total'
              : total > 0
              ? '$total'
              : null;

          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                title: Text(
                  titleCount != null ? 'طيوري ($titleCount)' : 'طيوري',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: AppColors.primary,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    onPressed: _refresh,
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: _FilterBar(
                    genderFilter: _genderFilter,
                    auctionFilter: _auctionFilter,
                    availableIdsLoaded:
                        state.availableForAuctionBirdIds != null,
                    onGenderChanged: (v) => setState(() => _genderFilter = v),
                    onAuctionChanged: (v) => setState(() => _auctionFilter = v),
                  ),
                ),
              ),
            ],
            body: state.sellerBirdsLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : state.sellerBirds.isEmpty
                ? _EmptyState(onAdd: _openAddBird)
                : filtered.isEmpty
                ? _NoResultsState(
                    onClear: () => setState(() {
                      _genderFilter = null;
                      _auctionFilter = null;
                    }),
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => _refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) =>
                          _BirdListTile(bird: filtered[i]),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final String? genderFilter;
  final String? auctionFilter;
  final bool availableIdsLoaded;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onAuctionChanged;

  const _FilterBar({
    required this.genderFilter,
    required this.auctionFilter,
    required this.availableIdsLoaded,
    required this.onGenderChanged,
    required this.onAuctionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // ── Gender group ──────────────────────────────────────────────
            _FilterChip(
              label: 'الكل',
              selected: genderFilter == null,
              onTap: () => onGenderChanged(null),
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: 'ذكر',
              selected: genderFilter == 'male',
              selectedColor: AppColors.blue,
              onTap: () =>
                  onGenderChanged(genderFilter == 'male' ? null : 'male'),
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: 'أنثى',
              selected: genderFilter == 'female',
              selectedColor: AppColors.red,
              onTap: () =>
                  onGenderChanged(genderFilter == 'female' ? null : 'female'),
            ),

            // ── Divider ───────────────────────────────────────────────────
            Container(
              width: 1,
              height: 22,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: AppColors.divider,
            ),

            // ── Auction status group ──────────────────────────────────────
            _FilterChip(
              label: 'متاح للمزاد',
              selected: auctionFilter == 'available',
              selectedColor: AppColors.primary,
              loading: !availableIdsLoaded,
              onTap: () => onAuctionChanged(
                auctionFilter == 'available' ? null : 'available',
              ),
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: 'في مزاد',
              selected: auctionFilter == 'in_auction',
              selectedColor: AppColors.orange,
              loading: !availableIdsLoaded,
              onTap: () => onAuctionChanged(
                auctionFilter == 'in_auction' ? null : 'in_auction',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final bool loading;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor = AppColors.primary,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.12)
              : AppColors.pageBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? selectedColor : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected
                ? selectedColor
                : loading
                ? AppColors.textHint
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Empty states ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flutter_dash,
                size: 58,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد طيور بعد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أضف طيورك لعرضها في المزادات والسوق',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final VoidCallback onClear;
  const _NoResultsState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.filter_list_off_rounded,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد طيور بهذا الفلتر',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onClear,
            child: const Text(
              'مسح الفلاتر',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bird tile ─────────────────────────────────────────────────────────────────

class _BirdListTile extends StatelessWidget {
  final BirdSummaryModel bird;
  const _BirdListTile({required this.bird});

  @override
  Widget build(BuildContext context) {
    final genderLabel = bird.gender == 'male'
        ? 'ذكر'
        : bird.gender == 'female'
        ? 'أنثى'
        : 'صغير';
    final genderColor = bird.gender == 'male'
        ? AppColors.blue
        : bird.gender == 'female'
        ? AppColors.red
        : AppColors.orange;

    final availableIds = context
        .read<AuctionsBloc>()
        .state
        .availableForAuctionBirdIds;
    final auctionStatusKnown = availableIds != null;
    final isAvailable = availableIds?.contains(bird.id) ?? true;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<CartBloc>()..add(const CartStarted()),
            child: BirdDetailPage(
              bird: bird,
              sellerNickname: bird.sellerNickname,
              isOwner: true,
            ),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(15),
              ),
              child: SizedBox(
                width: 90,
                height: 96,
                child: bird.thumbnailUrl != null
                    ? Image.network(
                        bird.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _PlaceholderImg(),
                      )
                    : _PlaceholderImg(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bird.name.isNotEmpty ? bird.name : bird.ringNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bird.ringNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // gender badge
                        _Badge(label: genderLabel, color: genderColor),
                        const SizedBox(width: 6),
                        // auction status badge
                        if (auctionStatusKnown)
                          _Badge(
                            label: isAvailable ? 'متاح' : 'في مزاد',
                            color: isAvailable
                                ? AppColors.primary
                                : AppColors.orange,
                          ),
                        if (bird.price > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            'ج.م ${bird.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.only(end: 14),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _PlaceholderImg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      child: const Center(
        child: Icon(Icons.flutter_dash, color: AppColors.primary, size: 36),
      ),
    );
  }
}
