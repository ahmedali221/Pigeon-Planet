import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../model/subscription_package_model.dart';
import '../../viewmodel/packages_bloc.dart';
import '../../viewmodel/packages_event.dart';
import '../../viewmodel/packages_state.dart';
import '../widgets/package_card.dart';

class PackagesPage extends StatelessWidget {
  const PackagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PackagesBloc(datasource: sl())
        ..add(PackagesLoadRequested()),
      child: const _PackagesView(),
    );
  }
}

class _PackagesView extends StatefulWidget {
  const _PackagesView();

  @override
  State<_PackagesView> createState() => _PackagesViewState();
}

class _PackagesViewState extends State<_PackagesView> {
  int _selectedIndex = 0;

  ({IconData icon, Color color, Color light, String? badge}) _style(
    PackageModel p,
  ) {
    if (p.points <= 75) {
      return (
        icon: Icons.bolt_rounded,
        color: AppColors.blue,
        light: AppColors.blueLight,
        badge: null,
      );
    }
    if (p.points <= 200) {
      return (
        icon: Icons.workspace_premium_rounded,
        color: AppColors.primary,
        light: AppColors.primaryLight,
        badge: 'الأكثر شعبية',
      );
    }
    if (p.points <= 600) {
      return (
        icon: Icons.star_rounded,
        color: AppColors.orange,
        light: AppColors.orangeLight,
        badge: null,
      );
    }
    return (
      icon: Icons.emoji_events_rounded,
      color: AppColors.purple,
      light: AppColors.purpleLight,
      badge: null,
    );
  }

  String _priceStr(PackageModel p) {
    final n = double.tryParse(p.price);
    if (n == null) return p.price;
    return n == n.roundToDouble() ? n.toInt().toString() : n.toStringAsFixed(2);
  }

  String _periodStr(int days) {
    if (days == 30) return 'شهر';
    if (days == 60) return 'شهران';
    if (days % 30 == 0) return '${days ~/ 30} أشهر';
    return '$days يوم';
  }

  List<String> _features(PackageModel p) {
    final lines = <String>[];
    if (p.description.isNotEmpty) {
      for (final line in p.description.split(RegExp(r'[\r\n]+'))) {
        final t = line.trim();
        if (t.isNotEmpty) lines.add(t);
      }
    }
    lines.add('${p.points} نقطة إجمالية');
    lines.add('إنشاء مزاد: ${p.auctionCost} نقطة لكل مزاد');
    lines.add('نشر منتج: ${p.productCost} نقطة لكل منتج');
    lines.add('صالحة لمدة ${_periodStr(p.activationPeriodDays)}');
    return lines;
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 14)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PackagesBloc, PackagesState>(
      listenWhen: (prev, curr) =>
          (curr.requestSuccess && !prev.requestSuccess) ||
          (curr.requestError != null &&
              curr.requestError != prev.requestError) ||
          (curr.cancelError != null &&
              curr.cancelError != prev.cancelError),
      listener: (context, state) {
        if (state.requestSuccess) {
          _showSnackBar(
            context,
            'تم تقديم طلب الاشتراك بنجاح\nسيتم تفعيل الباقة من قِبَل المشرف قريباً',
            AppColors.success,
          );
        } else if (state.requestError != null) {
          _showSnackBar(context, state.requestError!, AppColors.error);
        } else if (state.cancelError != null) {
          _showSnackBar(context, state.cancelError!, AppColors.error);
        }
      },
      builder: (context, state) {
        final bloc = context.read<PackagesBloc>();
        final isRequesting = state.status == PackagesStatus.requesting;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            automaticallyImplyLeading: false,
            title: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اختر باقتك',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'اشترك لتتمكن من إنشاء المزادات',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
                onPressed: state.status == PackagesStatus.loading
                    ? null
                    : () => bloc.add(PackagesLoadRequested()),
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: switch (state.status) {
            PackagesStatus.loading || PackagesStatus.initial =>
              const Center(child: CircularProgressIndicator()),
            PackagesStatus.error => _ErrorView(
                message: state.errorMessage ?? 'حدث خطأ غير متوقع',
                onRetry: () => bloc.add(PackagesLoadRequested()),
              ),
            _ => _buildLoaded(context, state, bloc, isRequesting),
          },
        );
      },
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    PackagesState state,
    PackagesBloc bloc,
    bool isRequesting,
  ) {
    if (state.packages.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد باقات متاحة حالياً',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Active package banner
        if (state.activePackage != null) ...[
          _ActivePackageBanner(
            active: state.activePackage!,
            periodStr: _periodStr,
          ),
          const SizedBox(height: 20),
          const Text(
            'الباقات المتاحة',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Pending package card
        if (state.pendingPackage != null) ...[
          _PendingPackageBanner(
            pending: state.pendingPackage!,
            cancelling: state.cancelling,
            onCancel: () => bloc.add(
              PackageCancelRequested(state.pendingPackage!.id),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Package cards
        ...state.packages.asMap().entries.map((entry) {
          final i = entry.key;
          final pkg = entry.value;
          final s = _style(pkg);
          return Padding(
            padding: EdgeInsets.only(
              bottom: i < state.packages.length - 1 ? 14 : 0,
            ),
            child: PlanCard(
              index: i,
              selectedIndex: _selectedIndex,
              onTap: () => setState(() => _selectedIndex = i),
              name: pkg.name,
              price: _priceStr(pkg),
              period: _periodStr(pkg.activationPeriodDays),
              color: s.color,
              lightColor: s.light,
              icon: s.icon,
              badge: s.badge,
              features: _features(pkg),
              isLoading: isRequesting,
              onSubscribe: _selectedIndex == i
                  ? () => bloc.add(PackageRequestSubmitted(pkg.id))
                  : null,
            ),
          );
        }),
      ],
    );
  }
}

// ── Pending package banner ────────────────────────────────────────────────────

class _PendingPackageBanner extends StatelessWidget {
  final PendingSellerPackageModel pending;
  final bool cancelling;
  final VoidCallback onCancel;

  const _PendingPackageBanner({
    required this.pending,
    required this.cancelling,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: AppColors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'طلب اشتراك معلق',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pending.packageName.isNotEmpty
                      ? pending.packageName
                      : 'بانتظار تفعيل المشرف',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          cancelling
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.orange,
                  ),
                )
              : TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Active package banner ─────────────────────────────────────────────────────

class _ActivePackageBanner extends StatelessWidget {
  final ActiveSellerPackageModel active;
  final String Function(int) periodStr;

  const _ActivePackageBanner({
    required this.active,
    required this.periodStr,
  });

  String _formatDate(DateTime dt) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final total = active.package.points;
    final remaining = active.remainingPoints;
    final progress = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;
    final isLow = progress < 0.25;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'باقتك الحالية: ${active.package.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Points progress label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'النقاط المتبقية',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
              Text(
                '$remaining / $total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation<Color>(
                isLow ? AppColors.orange : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Cost chips + expiry
          Row(
            children: [
              _Chip(
                icon: Icons.gavel_rounded,
                label: 'مزاد: ${active.auctionCost} نقطة',
              ),
              const SizedBox(width: 8),
              _Chip(
                icon: Icons.inventory_2_rounded,
                label: 'منتج: ${active.productCost} نقطة',
              ),
              const Spacer(),
              if (active.expiresAt != null)
                Text(
                  'تنتهي ${_formatDate(active.expiresAt!)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
            ],
          ),

          // Low-points warning
          if (isLow) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.orange.withValues(alpha: 0.5),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppColors.orange, size: 15),
                  SizedBox(width: 6),
                  Text(
                    'نقاطك على وشك النفاد، جدد اشتراكك قريباً',
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 56, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
