import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../model/auction_model.dart';
import '../../viewmodel/auctions_bloc.dart';
import '../widgets/auction_float_btn.dart';
import '../widgets/auction_media_section.dart';
import '../widgets/auction_bird_info_section.dart';
import '../widgets/auction_verification_row.dart';
import '../widgets/auction_details_grid.dart';
import '../widgets/auction_description_section.dart';
import '../widgets/auction_pedigree_button.dart';
import '../widgets/auction_price_section.dart';
import '../widgets/auction_inquiries_section.dart';
import '../widgets/auction_reviews_section.dart';

class AuctionDetailPage extends StatelessWidget {
  final int auctionId;
  const AuctionDetailPage({super.key, required this.auctionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AuctionsBloc>()..add(AuctionDetailRequested(auctionId)),
      child: const _AuctionDetailView(),
    );
  }
}

class _AuctionDetailView extends StatefulWidget {
  const _AuctionDetailView();

  @override
  State<_AuctionDetailView> createState() => _AuctionDetailViewState();
}

class _AuctionDetailViewState extends State<_AuctionDetailView> {
  int _currentImage = 0;
  bool _isFavorite = false;

  Map<String, dynamic> _buildData(AuctionModel auction) {
    final item =
        auction.items.isNotEmpty ? auction.items.first : null;
    final bird = item?.bird;

    final startingPrice = item?.startingPrice ?? 0.0;
    final currentPrice = item?.currentPrice ?? 0.0;
    // Savings = how much above starting price the bidding has gone
    final savings = currentPrice > startingPrice ? currentPrice - startingPrice : 0.0;
    final discountPercent = startingPrice > 0
        ? ((savings / startingPrice) * 100).round()
        : 0;

    String age = 'غير محدد';
    if (bird?.birthday != null) {
      final years =
          DateTime.now().difference(bird!.birthday!).inDays ~/ 365;
      age = '$years سنة';
    }

    return {
      'name': bird?.name.isNotEmpty == true
          ? bird!.name
          : auction.title,
      'breed': bird?.colour.isNotEmpty == true ? bird!.colour : '—',
      'isLimited': auction.isActive && !auction.isEnded,
      'imageCount': 1,
      'age': age,
      'location': 'غير متاح',
      'breeder': auction.sellerNickname.isNotEmpty
          ? auction.sellerNickname
          : '—',
      'hasCertifiedPedigree': false,
      'hasDNA': false,
      'hasHealthGuarantee': false,
      'originalPrice': _fmt(startingPrice),
      'discountedPrice': _fmt(currentPrice),
      'discountPercent': discountPercent,
      'savings': _fmt(savings),
      'liveViewers': 0,
      'todayRequests': 0,
      'rating': 0.0,
      'reviewCount': 0,
      'description': auction.description.isNotEmpty
          ? auction.description
          : 'لا يوجد وصف.',
      'seed': auction.id,
      'color': 0xFF3E7B52,
    };
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

  void _showBidDialog(BuildContext context, AuctionModel auction) {
    if (auction.items.isEmpty) return;
    final item = auction.items.first;
    final minBid = item.currentPrice + auction.minBidIncrement;
    final ctrl =
        TextEditingController(text: minBid.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('تقديم مزايدة',
            textAlign: TextAlign.start),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الحد الأدنى: ج.م ${_fmt(minBid)}',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'مبلغ المزايدة (ج.م)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          BlocBuilder<AuctionsBloc, AuctionsState>(
            builder: (blocCtx, state) => ElevatedButton(
              onPressed: state.isBidding
                  ? null
                  : () {
                      final amount =
                          double.tryParse(ctrl.text.trim()) ?? 0;
                      if (amount < minBid) return;
                      blocCtx.read<AuctionsBloc>().add(
                            AuctionBidPlaced(
                                itemId: item.id, amount: amount),
                          );
                      Navigator.pop(dialogCtx);
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: state.isBidding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white),
                    )
                  : const Text('زايد',
                      style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'تفاصيل المزاد',
          style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: BlocConsumer<AuctionsBloc, AuctionsState>(
        listenWhen: (p, c) => p.isBidding && !c.isBidding,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تمت المزايدة بنجاح'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == AuctionsStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state.status == AuctionsStatus.error) {
            return Center(
              child: Text(
                state.errorMessage ?? 'حدث خطأ',
                style:
                    const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            );
          }
          if (state.selectedAuction == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final auction = state.selectedAuction!;
          final d = _buildData(auction);

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
                      imageCount: d['imageCount'] as int,
                      seed: d['seed'] as int,
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
                    AuctionPriceSection(data: d),
                    const SizedBox(height: 12),
                    const AuctionInquiriesSection(),
                    const SizedBox(height: 16),
                    AuctionReviewsSection(
                      rating: d['rating'] as double,
                      reviewCount: d['reviewCount'] as int,
                      reviews: const [],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),

              // Floating side buttons
              Positioned(
                top: 16,
                left: 0,
                child: Column(
                  children: [
                    AuctionFloatBtn(
                      icon: Icons.gavel_rounded,
                      badge: '${state.bids.length}',
                      color: AppColors.primary,
                      onTap: () => _showBidDialog(context, auction),
                    ),
                    const SizedBox(height: 8),
                    AuctionFloatBtn(
                      icon: Icons.chat_bubble_rounded,
                      label: 'NEW',
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
