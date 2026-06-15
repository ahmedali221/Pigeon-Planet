import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../cart/viewmodel/cart_bloc.dart';
import '../../viewmodel/market_bloc.dart';
import '../widgets/market_product_card.dart';
import 'product_detail_page.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

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
            const SnackBar(
              content: Text('تمت الإضافة إلى السلة'),
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
                title: state.selectedCategory?.name ?? 'المنتجات',
              ),
            ),

            // ── Search bar ───────────────────────────────────────────────────
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  textAlign: TextAlign.start,
                  decoration: const InputDecoration(
                    hintText: 'ابحث في المنتجات...',
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

            // ── Products count ───────────────────────────────────────────────
            BlocBuilder<MarketBloc, MarketState>(
              buildWhen: (p, c) =>
                  p.filteredProducts.length != c.filteredProducts.length,
              builder: (context, state) => Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Text(
                      '${state.filteredProducts.length} منتج',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 1),

            // ── Grid ─────────────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<MarketBloc, MarketState>(
                buildWhen: (p, c) => p.filteredProducts != c.filteredProducts,
                builder: (context, state) {
                  final products = state.filteredProducts;

                  if (products.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد منتجات',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                                child: const ProductDetailPage(),
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

// ── Header ────────────────────────────────────────────────────────────────────
class _ProductsHeader extends StatelessWidget {
  final String title;
  const _ProductsHeader({required this.title});

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
          const SizedBox(width: 36),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
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
