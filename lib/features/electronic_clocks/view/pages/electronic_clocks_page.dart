import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../model/electronic_clock_model.dart';
import '../../viewmodel/clocks_bloc.dart';
import '../widgets/clock_card.dart';
import 'clock_detail_page.dart';

class ElectronicClocksPage extends StatelessWidget {
  const ElectronicClocksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClocksBloc>()..add(ClocksListLoaded()),
      child: const _ClocksView(),
    );
  }
}

class _ClocksView extends StatefulWidget {
  const _ClocksView();

  @override
  State<_ClocksView> createState() => _ClocksViewState();
}

class _ClocksViewState extends State<_ClocksView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          _ClocksHeader(
            onFilterInStock: (val) => context.read<ClocksBloc>().add(
                  ClocksListLoaded(
                    search: _searchController.text,
                    inStockOnly: val,
                  ),
                ),
          ),
          _SearchBar(
            controller: _searchController,
            onChanged: (q) =>
                context.read<ClocksBloc>().add(ClocksSearchChanged(q)),
          ),
          BlocBuilder<ClocksBloc, ClocksState>(
            buildWhen: (p, c) =>
                p.listStatus != c.listStatus || p.clocks != c.clocks,
            builder: (context, state) {
              if (state.listStatus == ClocksListStatus.loading) {
                return Expanded(
                  child: _StatsRow(count: 0, loading: true),
                );
              }
              return _StatsRow(
                count: state.clocks.length,
                loading: false,
              );
            },
          ),
          Expanded(
            child: BlocBuilder<ClocksBloc, ClocksState>(
              buildWhen: (p, c) =>
                  p.listStatus != c.listStatus || p.clocks != c.clocks,
              builder: (context, state) {
                if (state.listStatus == ClocksListStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.listStatus == ClocksListStatus.error) {
                  return _ErrorView(
                    message: state.errorMessage ?? 'حدث خطأ',
                    onRetry: () =>
                        context.read<ClocksBloc>().add(ClocksListLoaded()),
                  );
                }
                if (state.clocks.isEmpty) {
                  return const _EmptyView();
                }
                return _ClockGrid(clocks: state.clocks);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grid ──────────────────────────────────────────────────────────────────────

class _ClockGrid extends StatelessWidget {
  final List<ElectronicClockModel> clocks;

  const _ClockGrid({required this.clocks});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.73,
      ),
      itemCount: clocks.length,
      itemBuilder: (context, index) {
        final clock = clocks[index];
        return ClockCard(
          clock: clock,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClockDetailPage(clockId: clock.id),
            ),
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ClocksHeader extends StatefulWidget {
  final ValueChanged<bool> onFilterInStock;

  const _ClocksHeader({required this.onFilterInStock});

  @override
  State<_ClocksHeader> createState() => _ClocksHeaderState();
}

class _ClocksHeaderState extends State<_ClocksHeader> {
  bool _inStockOnly = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 14,
        right: 20,
        left: 20,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _inStockOnly = !_inStockOnly);
              widget.onFilterInStock(_inStockOnly);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _inStockOnly
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'المتاح فقط',
                style: TextStyle(
                  color: _inStockOnly
                      ? AppColors.primary
                      : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'الساعة الإلكترونية',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.timer_rounded, color: Colors.white, size: 22),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: AppColors.textHint, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: 'ابحث عن ساعة...',
                  hintStyle: TextStyle(
                      color: AppColors.textHint, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int count;
  final bool loading;

  const _StatsRow({required this.count, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Text(
            loading ? 'جارٍ التحميل…' : '$count ساعة',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.inventory_2_outlined,
            size: 15,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

// ── States ────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_off_rounded,
              size: 56, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            'لا توجد ساعات متاحة',
            style:
                TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
