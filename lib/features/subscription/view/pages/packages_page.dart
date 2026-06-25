import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/file_source_sheet.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../model/subscription_package_model.dart';
import '../../viewmodel/packages_bloc.dart';
import '../../viewmodel/packages_event.dart';
import '../../viewmodel/packages_state.dart';
import '../widgets/package_card.dart';

import '../../../../l10n/app_localizations.dart';
class PackagesPage extends StatelessWidget {
  PackagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PackagesBloc(datasource: sl())
        ..add(PackagesLoadRequested()),
      child: _PackagesView(),
    );
  }
}

class _PackagesView extends StatefulWidget {
  _PackagesView();

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
        badge: AppLocalizations.of(context).alakthrShabya,
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
    if (days == 30) return AppLocalizations.of(context).shhr2;
    if (days == 60) return AppLocalizations.of(context).shhran;
    if (days % 30 == 0) return AppLocalizations.of(context).ashhr(days ~/ 30);
    return AppLocalizations.of(context).ywm3(days);
  }

  List<String> _features(PackageModel p) {
    final lines = <String>[];
    if (p.description.isNotEmpty) {
      for (final line in p.description.split(RegExp(r'[\r\n]+'))) {
        final t = line.trim();
        if (t.isNotEmpty) lines.add(t);
      }
    }
    lines.add(AppLocalizations.of(context).nqtaIjmalya(p.points));
    lines.add(AppLocalizations.of(context).auction11(p.auctionCost));
    lines.add(AppLocalizations.of(context).nshrMntjNqtaLklMntj(p.productCost));
    lines.add(AppLocalizations.of(context).salhaLmda(_periodStr(p.activationPeriodDays)));
    return lines;
  }

  Future<void> _showProofSheet(
    BuildContext context,
    PackagesBloc bloc,
    int packageId,
  ) async {
    PlatformFile? pickedFile;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ProofPickerSheet(
        packageId: packageId,
        onConfirm: (file) {
          pickedFile = file;
          Navigator.of(context).pop();
        },
      ),
    );
    if (!context.mounted) return;
    bloc.add(PackageRequestSubmitted(packageId, proofFile: pickedFile));
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 14)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 4),
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
            AppLocalizations.of(context).no29,
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
          appBar: PPWAppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0.5,
            titleWidget: Column(
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
                icon: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
                onPressed: state.status == PackagesStatus.loading
                    ? null
                    : () => bloc.add(PackagesLoadRequested()),
              ),
            ],
          ),
          body: switch (state.status) {
            PackagesStatus.loading || PackagesStatus.initial =>
              Center(child: CircularProgressIndicator()),
            PackagesStatus.error => _ErrorView(
                message: state.errorMessage ?? AppLocalizations.of(context).errorOccurred8,
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
      return Center(
        child: Text(
          'لا توجد باقات متاحة حالياً',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Active package banners (one per active package — multiple now allowed)
        if (state.activePackages.isNotEmpty) ...[
          for (final active in state.activePackages) ...[
            _ActivePackageBanner(active: active, periodStr: _periodStr),
            SizedBox(height: 12),
          ],
          SizedBox(height: 8),
          Text(
            'الباقات المتاحة',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
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
          SizedBox(height: 16),
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
                  ? () => _showProofSheet(context, bloc, pkg.id)
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

  _PendingPackageBanner({
    required this.pending,
    required this.cancelling,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final hasProof = pending.paymentProofUrl != null &&
        pending.paymentProofUrl!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  color: AppColors.orange,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلب اشتراك معلق',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      pending.packageName.isNotEmpty
                          ? pending.packageName
                          : AppLocalizations.of(context).bantzarTfaylAlmshrf,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              cancelling
                  ? SizedBox(
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              color: AppColors.error.withValues(alpha: 0.4)),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).cancel,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: hasProof
                  ? AppColors.success.withValues(alpha: 0.08)
                  : AppColors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasProof
                    ? AppColors.success.withValues(alpha: 0.4)
                    : AppColors.orange.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasProof
                      ? Icons.check_circle_rounded
                      : Icons.upload_file_rounded,
                  color: hasProof ? AppColors.success : AppColors.orange,
                  size: 14,
                ),
                SizedBox(width: 6),
                Text(
                  hasProof ? AppLocalizations.of(context).tmIrfaqIthbatAldfa : AppLocalizations.of(context).lmYrfqIthbatAldfa,
                  style: TextStyle(
                    fontSize: 11,
                    color: hasProof ? AppColors.success : AppColors.orange,
                    fontWeight: FontWeight.w500,
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

// ── Active package banner ─────────────────────────────────────────────────────

class _ActivePackageBanner extends StatelessWidget {
  final ActiveSellerPackageModel active;
  final String Function(int) periodStr;

  _ActivePackageBanner({
    required this.active,
    required this.periodStr,
  });

  String _formatDate(DateTime dt, AppLocalizations l10n) {
    final months = [
      l10n.ynayr, l10n.fbrayr, l10n.mars, l10n.abryl, l10n.mayw, l10n.ywnyw,
      l10n.ywlyw, l10n.aghsts, l10n.sbtmbr, l10n.aktwbr, l10n.nwfmbr, l10n.dysmbr,
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = active.package.points;
    final remaining = active.remainingPoints;
    final progress = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;
    final isLow = progress < 0.25;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.verified_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'باقتك الحالية: ${active.package.name}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),

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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
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
          SizedBox(height: 12),

          // Cost chips + expiry
          Row(
            children: [
              _Chip(
                icon: Icons.gavel_rounded,
                label: l10n.auction12(active.auctionCost),
              ),
              SizedBox(width: 8),
              _Chip(
                icon: Icons.inventory_2_rounded,
                label: l10n.mntjNqta(active.productCost),
              ),
              Spacer(),
              if (active.expiresAt != null)
                Text(
                  'تنتهي ${_formatDate(active.expiresAt!, l10n)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
            ],
          ),

          // Low-points warning
          if (isLow) ...[
            SizedBox(height: 10),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.orange.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
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

  _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Proof picker bottom sheet ─────────────────────────────────────────────────

class _ProofPickerSheet extends StatefulWidget {
  final int packageId;
  final void Function(PlatformFile? file) onConfirm;

  _ProofPickerSheet({required this.packageId, required this.onConfirm});

  @override
  State<_ProofPickerSheet> createState() => _ProofPickerSheetState();
}

class _ProofPickerSheetState extends State<_ProofPickerSheet> {
  PlatformFile? _file;

  Future<void> _pick() async {
    final file = await FileSourceSheet.show(
      context,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (file != null) setState(() => _file = file);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
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
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'إثبات الدفع',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'يمكنك إرفاق صورة أو ملف إثبات الدفع ليتمكن المشرف من مراجعته',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _pick,
            icon: Icon(Icons.attach_file_rounded, size: 18),
            label: Text(
              _file == null ? AppLocalizations.of(context).akhtrMlf : _file!.name,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size(double.infinity, 46),
            ),
          ),
          if (_file != null) ...[
            SizedBox(height: 6),
            Text(
              '${(_file!.size / 1024).toStringAsFixed(1)} KB',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => widget.onConfirm(_file),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'تأكيد الطلب',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 56, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: 18),
              label: Text(AppLocalizations.of(context).retry),
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
