import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shell_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/model/seller_model.dart';
import '../../../home/view/pages/breeder_profile_page.dart';
import '../../viewmodel/feed_bloc.dart';

class SellersListPage extends StatefulWidget {
  const SellersListPage({super.key});

  @override
  State<SellersListPage> createState() => _SellersListPageState();
}

class _SellersListPageState extends State<SellersListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final bloc = context.read<FeedBloc>();
    if (bloc.state.sellersStatus == SellersListStatus.initial) {
      bloc.add(const FeedSellersListRequested());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_query.isNotEmpty) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      context.read<FeedBloc>().add(const FeedSellersListNextPageRequested());
    }
  }

  List<SellerModel> _filtered(List<SellerModel> sellers) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return sellers;
    return sellers.where((seller) {
      return seller.nickname.toLowerCase().contains(q) ||
          seller.username.toLowerCase().contains(q) ||
          seller.country.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: BlocConsumer<FeedBloc, FeedState>(
        listenWhen: (p, c) =>
            p.actionError != c.actionError && c.actionError != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        buildWhen: (p, c) =>
            p.sellersList != c.sellersList ||
            p.sellersStatus != c.sellersStatus ||
            p.followedSellerIds != c.followedSellerIds,
        builder: (context, state) {
          final sellers = _filtered(state.sellersList);
          final isInitialLoading =
              state.sellersStatus == SellersListStatus.loading &&
              state.sellersList.isEmpty;
          final isError =
              state.sellersStatus == SellersListStatus.error &&
              state.sellersList.isEmpty;

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<FeedBloc>().add(const FeedSellersListRequested()),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _RoomsHeader(
                    controller: _searchController,
                    totalRooms: state.sellersList.length,
                    visibleRooms: sellers.length,
                    onChanged: (value) => setState(() => _query = value.trim()),
                    onClear: _query.isEmpty
                        ? null
                        : () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                    onRefresh: () => context.read<FeedBloc>().add(
                      const FeedSellersListRequested(),
                    ),
                  ),
                ),
                if (isInitialLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (isError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(
                      onRetry: () => context.read<FeedBloc>().add(
                        const FeedSellersListRequested(),
                      ),
                    ),
                  )
                else if (sellers.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(hasQuery: _query.isNotEmpty),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: _FeaturedRoomsStrip(
                      sellers: sellers.take(6).toList(),
                      followedSellerIds: state.followedSellerIds,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final maxCardWidth = constraints.crossAxisExtent >= 700
                            ? 620.0
                            : null;
                        return SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            if (index.isOdd) {
                              return const SizedBox(height: 12);
                            }
                            final sellerIndex = index ~/ 2;
                            final seller = sellers[sellerIndex];
                            return Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: maxCardWidth ?? double.infinity,
                                ),
                                child: _RoomCard(
                                  seller: seller,
                                  isFollowing: state.followedSellerIds.contains(
                                    seller.id,
                                  ),
                                ),
                              ),
                            );
                          }, childCount: sellers.length * 2 - 1),
                        );
                      },
                    ),
                  ),
                  if (state.sellersStatus == SellersListStatus.loadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 24),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 78)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoomsHeader extends StatelessWidget {
  final TextEditingController controller;
  final int totalRooms;
  final int visibleRooms;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final VoidCallback onRefresh;

  const _RoomsHeader({
    required this.controller,
    required this.totalRooms,
    required this.visibleRooms,
    required this.onChanged,
    required this.onClear,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final textScale = _textScaleOf(context);
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(16, top + 8, 16, 16 + (textScale - 1) * 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const ShellBackButton(color: Colors.white),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الغرف',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'اكتشف الحسابات النشطة والمميزة',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                color: Colors.white,
                tooltip: 'تحديث',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeaderStat(
                icon: Icons.meeting_room_rounded,
                value: '$totalRooms',
                label: 'غرفة',
              ),
              const SizedBox(width: 8),
              _HeaderStat(
                icon: Icons.visibility_rounded,
                value: '$visibleRooms',
                label: 'معروضة',
                color: AppColors.orange,
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'ابحث باسم الغرفة أو الدولة',
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textHint,
              ),
              suffixIcon: onClear == null
                  ? null
                  : IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textSecondary,
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _HeaderStat({
    required this.icon,
    required this.value,
    required this.label,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              value,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedRoomsStrip extends StatelessWidget {
  final List<SellerModel> sellers;
  final Set<int> followedSellerIds;

  const _FeaturedRoomsStrip({
    required this.sellers,
    required this.followedSellerIds,
  });

  @override
  Widget build(BuildContext context) {
    if (sellers.isEmpty) return const SizedBox.shrink();
    final textScale = _textScaleOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth * 0.42).clamp(142.0, 188.0).toDouble();
        final stripHeight =
            150.0 + ((textScale - 1.0).clamp(0.0, 0.8).toDouble() * 54.0);
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: SizedBox(
            height: stripHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sellers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final seller = sellers[index];
                return _FeaturedRoomCard(
                  width: cardWidth,
                  seller: seller,
                  isFollowing: followedSellerIds.contains(seller.id),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _FeaturedRoomCard extends StatelessWidget {
  final double width;
  final SellerModel seller;
  final bool isFollowing;

  const _FeaturedRoomCard({
    required this.width,
    required this.seller,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = _textScaleOf(context);
    final avatarRadius = textScale > 1.25 ? 18.0 : 20.0;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openRoom(context, seller),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _RoomAvatar(seller: seller, radius: avatarRadius),
                const Spacer(),
                Icon(
                  isFollowing
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFollowing ? AppColors.orange : AppColors.textHint,
                  size: 19,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _displayName(seller),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              seller.country.isEmpty ? seller.username : seller.country,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            SizedBox(height: textScale > 1.25 ? 6 : 8),
            _RatingPill(rating: seller.avgRating),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final SellerModel seller;
  final bool isFollowing;

  const _RoomCard({required this.seller, required this.isFollowing});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final textScale = _textScaleOf(context);
    final compact = MediaQuery.of(context).size.width < 360 || textScale > 1.25;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openRoom(context, seller),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RoomAvatar(seller: seller, radius: compact ? 24 : 28),
                  SizedBox(width: compact ? 10 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _displayName(seller),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: compact ? 14.5 : 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Flexible(
                              child: _RatingPill(rating: seller.avgRating),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                seller.country.isEmpty
                                    ? seller.username
                                    : seller.country,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: compact ? 11 : 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (seller.description.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  seller.description.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _MiniStat(
                    icon: Icons.gavel_rounded,
                    value: '${seller.activeAuctionsCount}',
                    label: 'مزاد',
                    color: AppColors.orange,
                  ),
                  const SizedBox(width: 8),
                  _MiniStat(
                    icon: Icons.collections_bookmark_rounded,
                    value: '${seller.totalBirdsCount}',
                    label: 'عنصر',
                    color: const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  _MiniStat(
                    icon: Icons.reviews_rounded,
                    value: '${seller.ratingsCount}',
                    label: 'تقييم',
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: compact ? 44 : 40,
                      child: isFollowing
                          ? OutlinedButton.icon(
                              onPressed: () => context.read<FeedBloc>().add(
                                FeedUnfollowRequested(seller.id),
                              ),
                              icon: const Icon(
                                Icons.favorite_rounded,
                                size: 16,
                              ),
                              label: Text(l.followed),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.orange,
                                side: const BorderSide(color: AppColors.orange),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () => context.read<FeedBloc>().add(
                                FeedFollowRequested(seller.id),
                              ),
                              icon: const Icon(
                                Icons.person_add_alt_rounded,
                                size: 16,
                              ),
                              label: Text(l.follow),
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
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.pageBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomAvatar extends StatelessWidget {
  final SellerModel seller;
  final double radius;

  const _RoomAvatar({required this.seller, required this.radius});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = seller.avatarUrl?.trim();
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    return CircleAvatar(
      radius: radius + 2,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryLight,
        backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
        child: hasAvatar
            ? null
            : Text(
                _initial(seller),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: radius * 0.7,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;

  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    final compact = _textScaleOf(context) > 1.25;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.orange, size: 14),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: compact ? 10.5 : 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final compact = _textScaleOf(context) > 1.25;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 7 : 8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: compact ? 14 : 15),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                '$value $label',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: compact ? 10.5 : 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasQuery;

  const _EmptyState({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasQuery ? Icons.search_off_rounded : Icons.groups_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasQuery ? 'لا توجد نتائج مطابقة' : 'لا توجد غرف حالياً',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              hasQuery
                  ? 'جرّب البحث باسم آخر أو دولة مختلفة'
                  : 'اسحب للأسفل للتحديث والمحاولة مجدداً',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 52,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'تعذّر تحميل الغرف',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'تحقق من الاتصال وحاول مرة أخرى',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _displayName(SellerModel seller) {
  final nickname = seller.nickname.trim();
  if (nickname.isNotEmpty) return nickname;
  final username = seller.username.trim();
  return username.isEmpty ? 'غرفة' : username;
}

String _initial(SellerModel seller) {
  final name = _displayName(seller);
  return name[0];
}

void _openRoom(BuildContext context, SellerModel seller) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => BreederProfilePage(seller: seller)),
  );
}

double _textScaleOf(BuildContext context) {
  return MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.8).toDouble();
}
