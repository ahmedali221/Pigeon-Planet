import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../viewmodel/referrals_bloc.dart';

class ReferralsPage extends StatefulWidget {
  ReferralsPage({super.key});

  @override
  State<ReferralsPage> createState() => _ReferralsPageState();
}

class _ReferralsPageState extends State<ReferralsPage> {
  final _redeemCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ReferralsBloc>().add(ReferralsCodeRequested());
  }

  @override
  void dispose() {
    _redeemCtrl.dispose();
    super.dispose();
  }

  void _redeem() {
    final code = _redeemCtrl.text.trim();
    if (code.isEmpty) return;
    context.read<ReferralsBloc>().add(ReferralsRedeemRequested(code));
    _redeemCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReferralsBloc, ReferralsState>(
      listenWhen: (p, c) =>
          c.redeemSuccess != p.redeemSuccess ||
          (c.errorMessage != p.errorMessage && c.errorMessage != null),
      listener: (context, state) {
        if (state.redeemSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم استخدام كود الإحالة بنجاح! 🎉'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: Text(
              'برنامج الإحالة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _MyCodeCard(state: state),
              SizedBox(height: 16),
              _RedeemCard(
                controller: _redeemCtrl,
                isRedeeming: state.status == ReferralsStatus.redeeming,
                onRedeem: _redeem,
              ),
              SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _MyCodeCard extends StatelessWidget {
  final ReferralsState state;

  _MyCodeCard({required this.state});

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.redeem_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'كود الإحالة الخاص بك',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            'شارك هذا الكود مع أصدقائك وأرباح مكافآت عند تسجيلهم',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          SizedBox(height: 16),
          if (state.status == ReferralsStatus.loading)
            Center(child: CircularProgressIndicator(color: AppColors.primary))
          else if (state.myCode != null) ...[
            _CodeDisplay(code: state.myCode!.code),
            if (state.myCode!.shareUrl != null) ...[
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: state.myCode!.shareUrl!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم نسخ رابط المشاركة'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: Icon(Icons.share_rounded, size: 16),
                  label: Text('نسخ رابط المشاركة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
            if (state.myCode!.expiresAt != null) ...[
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 14, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text(
                    'ينتهي: ${_formatDate(state.myCode!.expiresAt!)}',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ] else if (state.status == ReferralsStatus.error)
            Text(
              state.errorMessage ?? 'فشل في تحميل الكود',
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
        ],
      ),
    );
  }
}

class _CodeDisplay extends StatelessWidget {
  final String code;

  _CodeDisplay({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              code,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 3,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy_rounded, color: AppColors.primary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم نسخ الكود'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RedeemCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isRedeeming;
  final VoidCallback onRedeem;

  _RedeemCard({
    required this.controller,
    required this.isRedeeming,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.redeem_rounded, color: AppColors.orange),
              SizedBox(width: 8),
              Text(
                'استخدام كود إحالة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            'أدخل كود إحالة صديق للحصول على مكافأة',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          SizedBox(height: 16),
          TextField(
            controller: controller,
            enabled: !isRedeeming,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'أدخل الكود هنا...',
              filled: true,
              fillColor: AppColors.pageBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isRedeeming ? null : onRedeem,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isRedeeming
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('استخدام الكود', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
