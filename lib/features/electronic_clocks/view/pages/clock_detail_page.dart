import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../model/electronic_clock_model.dart';
import '../../viewmodel/clocks_bloc.dart';

class ClockDetailPage extends StatelessWidget {
  final int clockId;

  const ClockDetailPage({super.key, required this.clockId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClocksBloc>()..add(ClockDetailRequested(clockId)),
      child: const _DetailBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody();

  void _showOrderSheet(BuildContext context, ElectronicClockModel clock) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ClocksBloc>(),
        child: _OrderSheet(
          clock: clock,
          onOrderPlaced: (orderId) => _showPaymentSheet(context, orderId),
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, int orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ClocksBloc>(),
        child: _PaymentProofSheet(
          orderId: orderId,
          onDone: () {
            context.read<ClocksBloc>().add(ClocksOrderReset());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إرسال إثبات الدفع، سيتم المراجعة قريباً'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClocksBloc, ClocksState>(
      buildWhen: (p, c) =>
          p.detailStatus != c.detailStatus ||
          p.selectedClock != c.selectedClock,
      builder: (context, state) {
        if (state.detailStatus == ClockDetailStatus.loading ||
            state.detailStatus == ClockDetailStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.detailStatus == ClockDetailStatus.error) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(state.errorMessage ?? 'حدث خطأ',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('رجوع'),
                  ),
                ],
              ),
            ),
          );
        }

        final clock = state.selectedClock!;
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ClockImageSection(clock: clock),
                      const SizedBox(height: 12),
                      _InfoCard(clock: clock),
                      const SizedBox(height: 12),
                      if (clock.agent != null) _AgentCard(agent: clock.agent!),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _BottomBar(
                clock: clock,
                onOrder: () => _showOrderSheet(context, clock),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Image section ─────────────────────────────────────────────────────────────

class _ClockImageSection extends StatelessWidget {
  final ElectronicClockModel clock;
  const _ClockImageSection({required this.clock});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final imageUrl = clock.firstImageUrl;
    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl != null
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : Container(
                  color: AppColors.primaryLight,
                  child: const Center(
                    child: Icon(
                      Icons.timer_rounded,
                      color: AppColors.primary,
                      size: 80,
                    ),
                  ),
                ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.35],
                colors: [Colors.black38, Colors.transparent],
              ),
            ),
          ),
          Positioned(
            top: topPad + 8,
            right: 8,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black26,
                shape: const CircleBorder(),
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                clock.brand,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: clock.inStock ? AppColors.success : AppColors.textHint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    clock.inStock
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    clock.inStock ? 'متاح' : 'نفذ المخزون',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final ElectronicClockModel clock;
  const _InfoCard({required this.clock});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (clock.reviewCount > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          clock.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 16),
                      ],
                    ),
                    Text(
                      '${clock.reviewCount} تقييم',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textHint),
                    ),
                  ],
                ),
              if (clock.reviewCount > 0) const SizedBox(width: 12),
              Expanded(
                child: Text(
                  clock.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (clock.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 14),
            const Text(
              'الوصف',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              clock.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ],
          if (clock.features.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 14),
            const Text(
              'المميزات',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ...clock.features.map((f) => _FeatureRow(label: f)),
          ],
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  const _FeatureRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Agent card ────────────────────────────────────────────────────────────────

class _AgentCard extends StatelessWidget {
  final ClockAgentModel agent;
  const _AgentCard({required this.agent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 8),
                Text(
                  'الوكيل المعتمد',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: agent.photoUrl != null
                      ? NetworkImage(agent.photoUrl!)
                      : null,
                  child: agent.photoUrl == null
                      ? const Icon(Icons.person_rounded,
                          color: AppColors.primary, size: 30)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 13, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(
                            agent.governorate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        agent.phoneNumber,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final ElectronicClockModel clock;
  final VoidCallback onOrder;
  const _BottomBar({required this.clock, required this.onOrder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: clock.inStock ? onOrder : null,
              icon: const Icon(Icons.shopping_cart_rounded, size: 18),
              label: Text(
                clock.inStock ? 'اطلب الآن' : 'نفذ المخزون',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.textHint,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('السعر',
                  style: TextStyle(fontSize: 11, color: AppColors.textHint)),
              Text(
                '${clock.price.toStringAsFixed(0)} ج.م',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Order bottom sheet ────────────────────────────────────────────────────────

class _OrderSheet extends StatefulWidget {
  final ElectronicClockModel clock;
  final void Function(int orderId) onOrderPlaced;

  const _OrderSheet({required this.clock, required this.onOrderPlaced});

  @override
  State<_OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends State<_OrderSheet> {
  int _quantity = 1;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double get _total => widget.clock.price * _quantity;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClocksBloc, ClocksState>(
      listenWhen: (p, c) => p.orderStatus != c.orderStatus,
      listener: (context, state) {
        if (state.orderStatus == ClockOrderStatus.placed) {
          Navigator.of(context).pop();
          widget.onOrderPlaced(state.currentOrder!.id);
        } else if (state.orderStatus == ClockOrderStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'حدث خطأ أثناء الطلب'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<ClocksBloc>().add(ClocksOrderReset());
        }
      },
      buildWhen: (p, c) => p.orderStatus != c.orderStatus,
      builder: (context, state) {
        final isLoading = state.orderStatus == ClockOrderStatus.placing;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.clock.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.clock.price.toStringAsFixed(0)} ج.م / قطعة',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // quantity row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الإجمالي',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textHint)),
                        Text(
                          '${_total.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('الكمية',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  _QuantityPicker(
                    value: _quantity,
                    onDecrement: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    onIncrement: _quantity < 20
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // note field
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'ملاحظة (اختياري)',
                  hintStyle: const TextStyle(
                      color: AppColors.textHint, fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<ClocksBloc>().add(ClockOrderStarted(
                                clockId: widget.clock.id,
                                quantity: _quantity,
                                note: _noteController.text.trim(),
                              ));
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('تأكيد الطلب',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuantityPicker extends StatelessWidget {
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _QuantityPicker({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyButton(icon: Icons.remove, onPressed: onDecrement),
        const SizedBox(width: 4),
        SizedBox(
          width: 36,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        _QtyButton(icon: Icons.add, onPressed: onIncrement),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QtyButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

// ── Payment proof bottom sheet ────────────────────────────────────────────────

class _PaymentProofSheet extends StatefulWidget {
  final int orderId;
  final VoidCallback onDone;

  const _PaymentProofSheet({required this.orderId, required this.onDone});

  @override
  State<_PaymentProofSheet> createState() => _PaymentProofSheetState();
}

class _PaymentProofSheetState extends State<_PaymentProofSheet> {
  final _urlController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClocksBloc, ClocksState>(
      listenWhen: (p, c) => p.orderStatus != c.orderStatus,
      listener: (context, state) {
        if (state.orderStatus == ClockOrderStatus.paid) {
          Navigator.of(context).pop();
          widget.onDone();
        } else if (state.orderStatus == ClockOrderStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'حدث خطأ'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<ClocksBloc>().add(ClocksOrderReset());
        }
      },
      buildWhen: (p, c) => p.orderStatus != c.orderStatus,
      builder: (context, state) {
        final isLoading = state.orderStatus == ClockOrderStatus.paying;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'إثبات الدفع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'أرسل المبلغ وأرفق رابط صورة إثبات الدفع (Cloudinary أو أي رابط صورة)',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'رابط صورة الإيصال...',
                  hintStyle: const TextStyle(
                      color: AppColors.textHint, fontSize: 13),
                  prefixIcon: const Icon(Icons.link_rounded,
                      color: AppColors.textHint, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'ملاحظة للإدارة (اختياري)',
                  hintStyle: const TextStyle(
                      color: AppColors.textHint, fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final url = _urlController.text.trim();
                          if (url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('الرجاء إدخال رابط الإيصال'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          context.read<ClocksBloc>().add(ClockPaymentSubmitted(
                                orderId: widget.orderId,
                                proofUrl: url,
                                note: _noteController.text.trim(),
                              ));
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('إرسال إثبات الدفع',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
