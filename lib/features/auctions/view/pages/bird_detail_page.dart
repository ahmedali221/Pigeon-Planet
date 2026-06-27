import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../../cart/view/pages/cart_page.dart';
import '../../../cart/viewmodel/cart_bloc.dart';
import '../../../pigeon_id/model/pigeon_model.dart';
import '../../../pigeon_id/model/pigeon_repository.dart';
import '../../../pigeon_id/view/pages/pigeon_id_form_page.dart';
import '../../../pigeon_id/viewmodel/pigeon_id_bloc.dart';
import '../../model/bird_summary_model.dart';
import '../widgets/auction_bird_info_section.dart';
import '../widgets/auction_description_section.dart';
import '../widgets/auction_details_grid.dart';
import '../widgets/auction_inquiries_section.dart';
import '../widgets/auction_media_section.dart';
import '../widgets/auction_pedigree_button.dart';
import '../widgets/auction_verification_row.dart';
import '../../../ratings/view/widgets/ratings_section.dart';

class BirdDetailPage extends StatefulWidget {
  final BirdSummaryModel bird;
  final String sellerNickname;
  final bool isOwner;

  const BirdDetailPage({
    super.key,
    required this.bird,
    required this.sellerNickname,
    this.isOwner = false,
  });

  @override
  State<BirdDetailPage> createState() => _BirdDetailPageState();
}

class _BirdDetailPageState extends State<BirdDetailPage> {
  int _currentImage = 0;
  bool _isFavorite = false;
  bool _isDeleting = false;

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

  Map<String, dynamic> _buildData(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bird = widget.bird;

    String age = l.unspecified;
    if (bird.birthday != null) {
      final years = DateTime.now().difference(bird.birthday!).inDays ~/ 365;
      age = years > 0 ? AppLocalizations.of(context).sna2(years) : l.lessThanAYear;
    }

    return {
      'name': bird.name.isNotEmpty ? bird.name : bird.ringNumber,
      'breed': bird.colour.isNotEmpty ? bird.colour : '—',
      'isLimited': false,
      'age': age,
      'location': l.notAvailable,
      'breeder': widget.sellerNickname.isNotEmpty ? widget.sellerNickname : '—',
      'hasCertifiedPedigree': true,
      'hasDNA': true,
      'hasHealthGuarantee': true,
      'originalPrice': _fmt(bird.price),
      'discountedPrice': _fmt(bird.price),
      'discountPercent': 0,
      'savings': '0',
      'liveViewers': 0,
      'todayRequests': 0,
      'rating': 0.0,
      'reviewCount': 0,
      'description': bird.description.isNotEmpty
          ? bird.description
          : l.noDescription,
      'seed': bird.id,
      'color': 0xFF3E7B52,
      'ringNumber': bird.ringNumber,
      'gender': bird.gender,
      'flyingSpeed': bird.flyingSpeed,
      'staminaAbility': bird.staminaAbility,
      'achievements': bird.achievements,
    };
  }

  PigeonModel _toPigeonModel() {
    final b = widget.bird;
    StaminaAbility stamina;
    switch (b.staminaAbility) {
      case 'excellent':
        stamina = StaminaAbility.excellent;
        break;
      case 'verygood':
        stamina = StaminaAbility.verygood;
        break;
      default:
        stamina = StaminaAbility.good;
    }
    return PigeonModel(
      id: b.id,
      ringNumber: b.ringNumber,
      name: b.name,
      breed: b.colour,
      gender: b.gender == 'female' ? PigeonGender.female : PigeonGender.male,
      photoPaths: b.imageUrls,
      videoPath: b.videoUrl,
      hatchDate: b.birthday,
      achievements: b.achievements,
      staminaAbility: stamina,
      price: b.price,
      description: b.description,
      flyingSpeed: b.flyingSpeed,
      isMarketListed: true,
    );
  }

  void _confirmDelete(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l.deleteBirdTitle),
        content: Text(l.deleteBirdConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _deleteBird(context);
            },
            child: Text(l.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBird(BuildContext context) async {
    final l = AppLocalizations.of(context);
    setState(() => _isDeleting = true);
    final result = await sl<PigeonRepository>().deleteBird(widget.bird.id);
    if (!mounted) return;
    setState(() => _isDeleting = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: AppColors.error,
        ),
      ),
      (_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.birdDeletedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  void _openEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<PigeonIdBloc>(),
          child: PigeonIdFormPage(initialPigeon: _toPigeonModel()),
        ),
      ),
    );
  }

  bool _hasCartBloc(BuildContext context) {
    try {
      context.read<CartBloc>();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (!_hasCartBloc(context)) {
      return BlocProvider.value(
        value: sl<CartBloc>(),
        child: BirdDetailPage(
          bird: widget.bird,
          sellerNickname: widget.sellerNickname,
          isOwner: widget.isOwner,
        ),
      );
    }

    final d = _buildData(context);
    final authState = context.read<AuthBloc>().state;
    final canRate =
        authState is AuthSuccess && authState.user.isCustomer && !widget.isOwner;

    return Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: PPWAppBar(
          title: l.pigeonDetails,
          actions: widget.isOwner
              ? [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    tooltip: l.edit,
                    onPressed: () => _openEdit(context),
                  ),
                  IconButton(
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete_rounded, color: Colors.white),
                    tooltip: l.delete,
                    onPressed: _isDeleting
                        ? null
                        : () => _confirmDelete(context),
                  ),
                ]
              : null,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuctionMediaSection(
                currentImage: _currentImage,
                isFavorite: _isFavorite,
                onPageChanged: (i) => setState(() => _currentImage = i),
                onFavorite: () => setState(() => _isFavorite = !_isFavorite),
                imageUrls: widget.bird.imageUrls,
                videoUrl: widget.bird.videoUrl,
              ),
              AuctionBirdInfoSection(data: d),
              const SizedBox(height: 8),
              AuctionVerificationRow(data: d),
              const SizedBox(height: 8),
              AuctionDetailsGrid(data: d),
              const SizedBox(height: 12),
              AuctionDescriptionSection(text: d['description'] as String),
              const SizedBox(height: 12),
              AuctionPedigreeButton(
                birdId: widget.bird.id,
                isOwner: widget.isOwner,
              ),
              const SizedBox(height: 12),
              _BirdPriceSection(
                data: d,
                assetId: widget.bird.id,
                isOwner: widget.isOwner,
                isMarketListed: widget.bird.isMarketListed,
              ),
              const SizedBox(height: 12),
              const AuctionInquiriesSection(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: RatingsSection(
                    targetType: RatingTargetType.asset,
                    targetId: widget.bird.id,
                    canRate: canRate,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
    );
  }
}

// ── Price section (buy now — no bidding) ─────────────────────────────────────
class _BirdPriceSection extends StatefulWidget {
  final Map<String, dynamic> data;
  final int assetId;
  final bool isOwner;
  final bool isMarketListed;

  const _BirdPriceSection({
    required this.data,
    required this.assetId,
    required this.isOwner,
    required this.isMarketListed,
  });

  @override
  State<_BirdPriceSection> createState() => _BirdPriceSectionState();
}

class _BirdPriceSectionState extends State<_BirdPriceSection> {
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocListener<CartBloc, CartState>(
      listenWhen: (prev, curr) =>
          _isAddingToCart &&
          ((curr.status == CartStatus.loaded &&
                  prev.status == CartStatus.mutating) ||
              (curr.status == CartStatus.error &&
                  prev.status == CartStatus.mutating)),
      listener: (context, state) {
        if (!_isAddingToCart) return;
        setState(() => _isAddingToCart = false);
        if (state.status == CartStatus.loaded) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CartBloc>(),
                child: const CartPage(),
              ),
            ),
          );
        } else if (state.status == CartStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? l.errorOccurred),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.5)),
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
                        Text(
                          l.specialPrice,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.data['discountedPrice']} ج.م',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              l.savingsAmount(widget.data['savings']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l.discountPercent(widget.data['discountPercent']),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 20, color: AppColors.divider),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('👥', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              l.liveViewersCount(widget.data['liveViewers']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              l.todayRequestsCount(widget.data['todayRequests']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: BlocBuilder<CartBloc, CartState>(
                    buildWhen: (p, c) => p.status != c.status,
                    builder: (context, cartState) {
                      final isBusy = _isAddingToCart ||
                          cartState.status == CartStatus.mutating;
                      return ElevatedButton(
                        onPressed: widget.isOwner || isBusy || !widget.isMarketListed
                            ? null
                            : () {
                                setState(() => _isAddingToCart = true);
                                context.read<CartBloc>().add(
                                  CartItemAdded(widget.assetId, 1),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.textHint,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.isOwner
                                    ? l.thisBirdIsYours
                                    : l.buyNowLimitedOffer,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      l.freeDelivery,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Text(
                      '|',
                      style: TextStyle(color: AppColors.border, fontSize: 11),
                    ),
                    Text(
                      l.cashOnDelivery,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
