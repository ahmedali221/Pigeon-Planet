import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../viewmodel/market_bloc.dart';
import '../widgets/market_category_tile.dart';
import 'products_page.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MarketBloc>()..add(const MarketStarted()),
      child: const _MarketView(),
    );
  }
}

class _MarketView extends StatelessWidget {
  const _MarketView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          // ── Green header ──────────────────────────────────────────────────
          _MarketHeader(),

          // ── Search bar ────────────────────────────────────────────────────
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
                  hintText: 'ابحث عن فئة أو منتج...',
                  hintStyle:
                      TextStyle(color: AppColors.textHint, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.textHint, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (q) =>
                    context.read<MarketBloc>().add(MarketSearchChanged(q)),
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<MarketBloc, MarketState>(
              builder: (context, state) {
                if (state.status == MarketStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = state.searchQuery.isEmpty
                    ? state.categories
                    : state.categories
                        .where((c) =>
                            c.name.contains(state.searchQuery))
                        .toList();

                return ListView(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  children: [
                    // ── Stats bar ─────────────────────────────────────────
                    _StatsBar(totalProducts: state.allProducts.length),
                    const SizedBox(height: 12),

                    // ── Quality banner ────────────────────────────────────
                    _QualityBanner(),
                    const SizedBox(height: 16),

                    // ── Categories ────────────────────────────────────────
                    ...categories.map(
                      (cat) => MarketCategoryTile(
                        category: cat,
                        onTap: () {
                          context
                              .read<MarketBloc>()
                              .add(MarketCategorySelected(cat));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<MarketBloc>(),
                                child: const ProductsPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Green header ──────────────────────────────────────────────────────────────
class _MarketHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
          top: topPadding + 12, bottom: 14, left: 16, right: 16),
      child: Row(
        children: [
          BlocBuilder<MarketBloc, MarketState>(
            buildWhen: (p, c) => p.cartCount != c.cartCount,
            builder: (context, state) => Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined,
                    color: Colors.white, size: 26),
                if (state.cartCount > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                          color: AppColors.orange, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          '${state.cartCount}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Expanded(
            child: Text(
              'المتجر',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

// ── Stats bar ─────────────────────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  final int totalProducts;
  const _StatsBar({required this.totalProducts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // free delivery
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text('🚚', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 4),
                  Text('مجاني',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  Text('توصيل للمنزل',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.primary)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // product count
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('📦', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text('$totalProducts',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const Text('منتج متاح',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quality banner ────────────────────────────────────────────────────────────
class _QualityBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.verified_rounded,
                  color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جميع المنتجات عالية الجودة',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                SizedBox(height: 2),
                Text(
                  'منتجات أصلية معتمدة لصحة حمامك',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
