import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/auction_item_model.dart';
import '../../model/auction_model.dart';
import '../../viewmodel/auctions_bloc.dart';
import '../widgets/auction_bids_section.dart';
import '../widgets/auction_bird_info_section.dart';
import '../widgets/auction_description_section.dart';
import '../widgets/auction_details_grid.dart';
import '../widgets/auction_float_btn.dart';
import '../widgets/auction_media_section.dart';
import '../widgets/auction_pedigree_button.dart';
import '../widgets/auction_reviews_section.dart';
import '../widgets/auction_verification_row.dart';

class AuctionItemDetailPage extends StatefulWidget {
  final AuctionModel auction;
  final AuctionItemModel item;

  const AuctionItemDetailPage({
    super.key,
    required this.auction,
    required this.item,
  });

  @override
  State<AuctionItemDetailPage> createState() => _AuctionItemDetailPageState();
}

class _AuctionItemDetailPageState extends State<AuctionItemDetailPage> {
  int _currentImage = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    context.read<AuctionsBloc>().add(AuctionItemDetailRequested(
          itemId: widget.item.id,
          birdId: widget.item.bird.id,
        ));
  }

  String _fmt(double v) {
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

  Map<String, dynamic> _buildData() {
    final bird = widget.item.bird;
    final startingPrice = widget.item.startingPrice;
    final currentPrice = widget.item.currentPrice;
    final savings =
        currentPrice > startingPrice ? currentPrice - startingPrice : 0.0;
    final discountPercent = startingPrice > 0
        ? ((savings / startingPrice) * 100).round()
        : 0;

    String age = 'غير محدد';
    if (bird.birthday != null) {
      final years =
          DateTime.now().difference(bird.birthday!).inDays ~/ 365;
      age = years > 0 ? '$years سنة' : 'أقل من سنة';
    }

    return {
      'name': bird.name.isNotEmpty ? bird.name : widget.auction.title,
      'breed': bird.colour.isNotEmpty ? bird.colour : '—',
      'isLimited': widget.auction.isActive && !widget.auction.isEnded,
      'age': age,
      'location': 'غير متاح',
      'breeder': widget.auction.sellerNickname.isNotEmpty
          ? widget.auction.sellerNickname
          : '—',
      'hasCertifiedPedigree': true,
      'hasDNA': true,
      'hasHealthGuarantee': true,
      'originalPrice': _fmt(startingPrice),
      'discountedPrice': _fmt(currentPrice),
      'discountPercent': discountPercent,
      'savings': _fmt(savings),
      'liveViewers': 0,
      'todayRequests': 0,
      'description': widget.auction.description.isNotEmpty
          ? widget.auction.description
          : 'لا يوجد وصف.',
      'ringNumber': bird.ringNumber,
      'gender': bird.gender,
      'flyingSpeed': bird.flyingSpeed,
      'staminaAbility': bird.staminaAbility,
      'achievements': bird.achievements,
    };
  }

  void _showBidDialog(BuildContext context) {
    final minBid =
        widget.item.currentPrice + widget.auction.minBidIncrement;
    final bloc = context.read<AuctionsBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => BlocProvider.value(
        value: bloc,
        child: _BidSheet(
          item: widget.item,
          auction: widget.auction,
          minBid: minBid,
          fmtFn: _fmt,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _buildData();
    final canBid = widget.auction.isActive && !widget.auction.isOwner;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          d['name'] as String,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: BlocConsumer<AuctionsBloc, AuctionsState>(
        listenWhen: (p, c) => p.isBidding && !c.isBidding,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('تمت المزايدة بنجاح'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuctionMediaSection(
                      currentImage: _currentImage,
                      isFavorite: _isFavorite,
                      onPageChanged: (i) =>
                          setState(() => _currentImage = i),
                      onFavorite: () =>
                          setState(() => _isFavorite = !_isFavorite),
                      imageUrls: widget.item.bird.imageUrls,
                      videoUrl: widget.item.bird.videoUrl,
                    ),
                    AuctionBirdInfoSection(data: d),
                    const SizedBox(height: 8),
                    AuctionVerificationRow(data: d),
                    const SizedBox(height: 8),
                    AuctionDetailsGrid(data: d),
                    const SizedBox(height: 12),
                    AuctionDescriptionSection(
                        text: d['description'] as String),
                    const SizedBox(height: 12),
                    const AuctionPedigreeButton(),
                    const SizedBox(height: 12),
                    _ItemBidCard(
                      item: widget.item,
                      auction: widget.auction,
                      fmtFn: _fmt,
                      onBid: canBid
                          ? () => _showBidDialog(context)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    if (state.isItemLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      )
                    else ...[
                      AuctionBidsSection(bids: state.itemBids),
                      const SizedBox(height: 16),
                      AuctionReviewsSection(reviews: state.itemReviews),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),

              // Floating bid button
              if (canBid)
                Positioned(
                  top: 16,
                  left: 0,
                  child: AuctionFloatBtn(
                    icon: Icons.gavel_rounded,
                    badge: '${state.itemBids.length}',
                    color: AppColors.primary,
                    onTap: () => _showBidDialog(context),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Current bid / price card ──────────────────────────────────────────────────
class _ItemBidCard extends StatelessWidget {
  final AuctionItemModel item;
  final AuctionModel auction;
  final String Function(double) fmtFn;
  final VoidCallback? onBid;

  const _ItemBidCard({
    required this.item,
    required this.auction,
    required this.fmtFn,
    this.onBid,
  });

  @override
  Widget build(BuildContext context) {
    final minBid = item.currentPrice + auction.minBidIncrement;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('سعر البداية',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        '${fmtFn(item.startingPrice)} ج.م',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textHint,
                            decoration: TextDecoration.lineThrough),
                      ),
                      Text(
                        '${fmtFn(item.currentPrice)} ج.م',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                      Text(
                        'الحد الأدنى للمزايدة: ${fmtFn(minBid)} ج.م',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  _StatusBadge(item: item, auction: auction),
                ],
              ),
            ),
            const Divider(height: 20, color: AppColors.divider),
            if (onBid != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: onBid,
                    icon: const Icon(Icons.gavel_rounded,
                        color: Colors.white, size: 18),
                    label: const Text('زايد الآن',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Text(
                  auction.isOwner
                      ? 'هذا مزادك — لا يمكنك المزايدة'
                      : auction.isEnded
                          ? 'انتهى المزاد'
                          : 'المزاد لم يبدأ بعد',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AuctionItemModel item;
  final AuctionModel auction;
  const _StatusBadge({required this.item, required this.auction});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    if (item.status == 'sold') {
      color = AppColors.orange;
      label = 'مُباع';
    } else if (item.status == 'unsold' || item.status == 'cancelled') {
      color = AppColors.textSecondary;
      label = 'غير مُباع';
    } else if (auction.isActive) {
      color = AppColors.primary;
      label = 'نشط';
    } else if (auction.isEnded) {
      color = AppColors.textSecondary;
      label = 'منتهي';
    } else {
      color = AppColors.blue;
      label = 'قادم';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

// ── Bid bottom sheet (identical logic to AuctionDetailPage's sheet) ───────────
class _BidSheet extends StatefulWidget {
  final AuctionItemModel item;
  final AuctionModel auction;
  final double minBid;
  final String Function(double) fmtFn;

  const _BidSheet({
    required this.item,
    required this.auction,
    required this.minBid,
    required this.fmtFn,
  });

  @override
  State<_BidSheet> createState() => _BidSheetState();
}

class _BidSheetState extends State<_BidSheet> {
  late final TextEditingController _ctrl;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _ctrl =
        TextEditingController(text: widget.minBid.toStringAsFixed(0));
    _ctrl.addListener(_validate);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _validate() {
    final v = double.tryParse(_ctrl.text.trim());
    setState(() {
      if (v == null) {
        _validationError = 'أدخل رقمًا صحيحًا';
      } else if (v < widget.minBid) {
        _validationError =
            'الحد الأدنى ${widget.fmtFn(widget.minBid)} ج.م';
      } else {
        _validationError = null;
      }
    });
  }

  void _setAmount(double amount) {
    _ctrl.text = amount.toStringAsFixed(0);
    _ctrl.selection =
        TextSelection.collapsed(offset: _ctrl.text.length);
    _validate();
  }

  void _submit(BuildContext ctx) {
    final amount = double.tryParse(_ctrl.text.trim()) ?? 0;
    if (amount < widget.minBid) return;
    ctx.read<AuctionsBloc>().add(
          AuctionBidPlaced(itemId: widget.item.id, amount: amount),
        );
    Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context) {
    final inc = widget.auction.minBidIncrement;
    final chips = [
      ('الحد الأدنى', widget.minBid),
      ('+${widget.fmtFn(inc * 2)}', widget.minBid + inc),
      ('+${widget.fmtFn(inc * 5)}', widget.minBid + inc * 4),
      ('+${widget.fmtFn(inc * 10)}', widget.minBid + inc * 9),
    ];

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.gavel_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('تقديم مزايدة',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      Text(
                        widget.item.bird.name.isNotEmpty
                            ? widget.item.bird.name
                            : widget.auction.title,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    color: AppColors.pageBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border)),
                child: Row(
                  children: [
                    _PricePill(
                      label: 'السعر الحالي',
                      value:
                          '${widget.fmtFn(widget.item.currentPrice)} ج.م',
                      valueColor: AppColors.textPrimary,
                    ),
                    Container(
                        width: 1,
                        height: 32,
                        color: AppColors.divider,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16)),
                    _PricePill(
                      label: 'الحد الأدنى',
                      value: '${widget.fmtFn(widget.minBid)} ج.م',
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                itemCount: chips.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final (label, amount) = chips[i];
                  final current =
                      double.tryParse(_ctrl.text.trim()) ?? -1;
                  final selected =
                      (current - amount).abs() < 0.01;
                  return GestureDetector(
                    onTap: () => _setAmount(amount),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(label,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppColors.primary)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  prefixText: 'ج.م  ',
                  prefixStyle: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500),
                  hintText: '0',
                  errorText: _validationError,
                  filled: true,
                  fillColor: AppColors.pageBackground,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.error, width: 1.5)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.error, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<AuctionsBloc, AuctionsState>(
                builder: (blocCtx, state) => Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          side: const BorderSide(
                              color: AppColors.border),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                        ),
                        child: const Text('إلغاء',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: ElevatedButton(
                        onPressed: (state.isBidding ||
                                _validationError != null)
                            ? null
                            : () => _submit(blocCtx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary
                              .withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: state.isBidding
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.gavel_rounded,
                                      color: Colors.white,
                                      size: 18),
                                  SizedBox(width: 8),
                                  Text('زايد الآن',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.bold)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _PricePill(
      {required this.label,
      required this.value,
      required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: valueColor)),
        ],
      ),
    );
  }
}
