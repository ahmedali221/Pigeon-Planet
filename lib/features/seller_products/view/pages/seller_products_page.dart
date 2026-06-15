import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../model/seller_product_model.dart';
import '../../viewmodel/seller_products_bloc.dart';
import '../widgets/seller_product_card.dart';
import 'seller_product_form_page.dart';

class SellerProductsPage extends StatelessWidget {
  const SellerProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<SellerProductsBloc>()..add(const SellerProductsStarted()),
      child: const _SellerProductsView(),
    );
  }
}

class _SellerProductsView extends StatelessWidget {
  const _SellerProductsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SellerProductsBloc, SellerProductsState>(
      listenWhen: (prev, curr) =>
          curr.mutationStatus != prev.mutationStatus &&
          (curr.mutationStatus == SellerMutationStatus.success ||
              curr.mutationStatus == SellerMutationStatus.failure),
      listener: (context, state) {
        if (state.mutationStatus == SellerMutationStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت العملية بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.mutationStatus == SellerMutationStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mutationError ?? 'حدث خطأ'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Column(
          children: [
            _Header(),
            _CategoryFilter(),
            Expanded(child: _Body()),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة منتج',
              style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () => _openForm(context, product: null),
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {SellerProductModel? product}) {
    final bloc = context.read<SellerProductsBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: SellerProductFormPage(product: product),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: topPadding + 12,
        bottom: 14,
        right: 16,
        left: 16,
      ),
      child: Row(
        // RTL: back arrow rightmost, title center, stats leftmost
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 20),
          ),
          const Expanded(
            child: Text(
              'منتجاتي',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          BlocBuilder<SellerProductsBloc, SellerProductsState>(
            buildWhen: (p, c) => p.products.length != c.products.length,
            builder: (_, state) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${state.products.length} منتج',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category filter chips ─────────────────────────────────────────────────────

class _CategoryFilter extends StatelessWidget {
  static const _chips = [
    (null, 'الكل'),
    ('supplies', 'مستلزمات'),
    ('accessories', 'إكسسوارات'),
    ('supplements', 'مكملات'),
    ('feeds', 'أعلاف'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellerProductsBloc, SellerProductsState>(
      buildWhen: (p, c) => p.selectedCategory != c.selectedCategory,
      builder: (context, state) => SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: _chips
              .map((chip) => _FilterChip(
                    label: chip.$2,
                    category: chip.$1,
                    selected: state.selectedCategory == chip.$1,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? category;
  final bool selected;

  const _FilterChip({
    required this.label,
    required this.category,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context
          .read<SellerProductsBloc>()
          .add(SellerProductCategoryFiltered(category)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsetsDirectional.only(end: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellerProductsBloc, SellerProductsState>(
      builder: (context, state) {
        if (state.status == SellerProductsStatus.loading ||
            state.status == SellerProductsStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == SellerProductsStatus.error) {
          return _ErrorState(message: state.errorMessage);
        }

        final products = state.filteredProducts;
        if (products.isEmpty) {
          return _EmptyState(hasFilter: state.selectedCategory != null);
        }

        return RefreshIndicator(
          onRefresh: () async => context
              .read<SellerProductsBloc>()
              .add(const SellerProductsRefreshRequested()),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            itemCount: products.length,
            itemBuilder: (context, i) => SellerProductCard(
              product: products[i],
              onEdit: () {
                final bloc = context.read<SellerProductsBloc>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: SellerProductFormPage(product: products[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ── Empty & Error states ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: AppColors.textHint.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            hasFilter ? 'لا توجد منتجات في هذه الفئة' : 'لم تضف أي منتجات بعد',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          if (!hasFilter)
            const Text(
              'اضغط + لإضافة منتجك الأول',
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? message;
  const _ErrorState({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            message ?? 'حدث خطأ في تحميل المنتجات',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context
                .read<SellerProductsBloc>()
                .add(const SellerProductsRefreshRequested()),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
