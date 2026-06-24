import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../cart/viewmodel/cart_bloc.dart';
import '../../viewmodel/market_bloc.dart';
import '../widgets/market_product_card.dart';
import 'product_detail_page.dart';

import '../../../../l10n/app_localizations.dart';
class ProductsPage extends StatelessWidget {
  ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listenWhen: (prev, curr) =>
          (curr.status == CartStatus.loaded &&
              prev.status == CartStatus.mutating) ||
          (curr.status == CartStatus.error &&
              prev.status == CartStatus.mutating),
      listener: (context, state) {
        if (state.status == CartStatus.loaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).addedToCart),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.status == CartStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'حدث خطأ'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────────
            BlocBuilder<MarketBloc, MarketState>(
              buildWhen: (p, c) => p.selectedCategory != c.selectedCategory,
              builder: (context, state) => _ProductsHeader(
                title: state.selectedCategory?.name ?? AppLocalizations.of(context).products,
              ),
            ),

            // ── Search bar ───────────────────────────────────────────────────
            Container(
              color: AppColors.primary,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).productSearchHint,
                    hintStyle: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (q) =>
                      context.read<MarketBloc>().add(MarketSearchChanged(q)),
                ),
              ),
            ),

            // ── Products count + sort ────────────────────────────────────────
            BlocBuilder<MarketBloc, MarketState>(
              buildWhen: (p, c) =>
                  p.filteredProducts.length != c.filteredProducts.length ||
                  p.activeOrdering != c.activeOrdering,
              builder: (context, state) => Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Text(
                      '${state.filteredProducts.length} منتج',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Spacer(),
                    _SortButton(activeOrdering: state.activeOrdering),
                  ],
                ),
              ),
            ),

            SizedBox(height: 1),

            // ── Grid ─────────────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<MarketBloc, MarketState>(
                buildWhen: (p, c) => p.filteredProducts != c.filteredProducts,
                builder: (context, state) {
                  final products = state.filteredProducts;

                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context).noProducts,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(12),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, i) => MarketProductCard(
                      product: products[i],
                      onTap: () {
                        context.read<MarketBloc>().add(
                          MarketProductOpened(products[i]),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<MarketBloc>(),
                              child: BlocProvider.value(
                                value: context.read<CartBloc>(),
                                child: ProductDetailPage(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sort button ───────────────────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  final String? activeOrdering;
  _SortButton({this.activeOrdering});

  static final _options = [
    (label: 'الأحدث', value: null),
    (label: 'السعر: الأقل أولاً', value: 'price'),
    (label: 'السعر: الأعلى أولاً', value: '-price'),
  ];

  String get _activeLabel {
    for (final o in _options) {
      if (o.value == activeOrdering) return o.label;
    }
    return 'ترتيب';
  }

  @override
  Widget build(BuildContext context) {
    final isActive = activeOrdering != null;
    return PopupMenuButton<String?>(
      onSelected: (v) =>
          context.read<MarketBloc>().add(MarketSortChanged(v)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => _options
          .map(
            (o) => PopupMenuItem<String?>(
              value: o.value,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      o.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: o.value == activeOrdering
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: o.value == activeOrdering
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (o.value == activeOrdering)
                    Icon(Icons.check_rounded,
                        color: AppColors.primary, size: 16),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLight : AppColors.inputBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              size: 15,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(width: 4),
            Text(
              _activeLabel,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _ProductsHeader extends StatelessWidget {
  final String title;
  _ProductsHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: topPadding + 12,
        bottom: 14,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          // cart icon placeholder
          SizedBox(width: 36),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
