import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../../home/model/seller_model.dart';
import '../../../seller_products/model/seller_product_model.dart';
import '../../../seller_products/viewmodel/seller_products_bloc.dart';
import '../../viewmodel/transfers_bloc.dart';

class CreateTransferPage extends StatelessWidget {
  final SellerProductModel product;

  const CreateTransferPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TransfersBloc>(),
      child: _CreateTransferView(product: product),
    );
  }
}

class _CreateTransferView extends StatefulWidget {
  final SellerProductModel product;
  const _CreateTransferView({required this.product});

  @override
  State<_CreateTransferView> createState() => _CreateTransferViewState();
}

class _CreateTransferViewState extends State<_CreateTransferView> {
  final _searchController = TextEditingController();
  final _noteController = TextEditingController();
  SellerModel? _selected;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _noteController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<TransfersBloc>().add(TransferSellerSearchRequested(value));
    });
  }

  void _selectSeller(SellerModel seller) {
    setState(() {
      _selected = seller;
      _searchController.clear();
    });
    context
        .read<TransfersBloc>()
        .add(const TransferSellerSearchRequested(''));
    FocusScope.of(context).unfocus();
  }

  void _clearSelection() {
    setState(() => _selected = null);
  }

  void _confirm() {
    if (_selected == null) return;
    context.read<TransfersBloc>().add(TransferCreateRequested(
          assetId: widget.product.id,
          toProfileId: _selected!.id,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransfersBloc, TransfersState>(
      listenWhen: (prev, curr) =>
          curr.created != prev.created || curr.createError != prev.createError,
      listener: (context, state) {
        if (state.created) {
          // Refresh the seller products list
          if (context.mounted) {
            try {
              context
                  .read<SellerProductsBloc>()
                  .add(SellerProductsRefreshRequested());
            } catch (_) {}
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم نقل الملكية بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else if (state.createError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.createError!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: PPWAppBar(title: 'نقل الملكية'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BirdInfoCard(product: widget.product),
              const SizedBox(height: 16),
              _SellerSearchSection(
                searchController: _searchController,
                selected: _selected,
                onSearchChanged: _onSearchChanged,
                onSelect: _selectSeller,
                onClearSelection: _clearSelection,
              ),
              const SizedBox(height: 16),
              _NoteField(controller: _noteController),
              const SizedBox(height: 24),
              _ConfirmButton(
                enabled: _selected != null,
                onConfirm: _confirm,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bird info card ─────────────────────────────────────────────────────────────

class _BirdInfoCard extends StatelessWidget {
  final SellerProductModel product;
  const _BirdInfoCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: product.thumbnailUrl != null
                  ? Image.network(
                      product.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الطير المراد نقله',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'طير',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.primaryLight,
        child: const Icon(
          Icons.flutter_dash_rounded,
          color: AppColors.primary,
          size: 26,
        ),
      );
}

// ── Seller search section ──────────────────────────────────────────────────────

class _SellerSearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final SellerModel? selected;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<SellerModel> onSelect;
  final VoidCallback onClearSelection;

  const _SellerSearchSection({
    required this.searchController,
    required this.selected,
    required this.onSearchChanged,
    required this.onSelect,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المستلم',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          if (selected != null)
            _SelectedSellerChip(seller: selected!, onClear: onClearSelection)
          else ...[
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ابحث باسم البائع أو رقم الهاتف',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                ),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textHint, size: 20),
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
            BlocBuilder<TransfersBloc, TransfersState>(
              buildWhen: (p, c) =>
                  p.sellerSearchResults != c.sellerSearchResults ||
                  p.isSearching != c.isSearching,
              builder: (context, state) {
                if (state.isSearching) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                        child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )),
                  );
                }
                if (state.sellerSearchResults.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: state.sellerSearchResults
                      .map((s) => _SellerResultTile(
                            seller: s,
                            onTap: () => onSelect(s),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _SelectedSellerChip extends StatelessWidget {
  final SellerModel seller;
  final VoidCallback onClear;
  const _SelectedSellerChip({required this.seller, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              seller.nickname.isNotEmpty ? seller.nickname : seller.username,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close_rounded,
                color: AppColors.primary, size: 18),
          ),
        ],
      ),
    );
  }
}

class _SellerResultTile extends StatelessWidget {
  final SellerModel seller;
  final VoidCallback onTap;
  const _SellerResultTile({required this.seller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: seller.avatarUrl != null
                  ? NetworkImage(seller.avatarUrl!)
                  : null,
              child: seller.avatarUrl == null
                  ? const Icon(Icons.person_rounded,
                      color: AppColors.primary, size: 18)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                seller.nickname.isNotEmpty
                    ? seller.nickname
                    : seller.username,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_left_rounded,
                color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Note field ─────────────────────────────────────────────────────────────────

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  const _NoteField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملاحظة (اختياري)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'أضف ملاحظة للنقل...',
              hintStyle:
                  const TextStyle(fontSize: 13, color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confirm button ─────────────────────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onConfirm;
  const _ConfirmButton({required this.enabled, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransfersBloc, TransfersState>(
      buildWhen: (p, c) => p.isCreating != c.isCreating,
      builder: (context, state) {
        return SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: (enabled && !state.isCreating) ? onConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.border,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: state.isCreating
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'تأكيد نقل الملكية',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
