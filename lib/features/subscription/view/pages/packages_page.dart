import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/package_card.dart';

class PackagesPage extends StatefulWidget {
  const PackagesPage({super.key});

  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
              'اختر الباقة المناسبة لعملك',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Pro Plan ──────────────────────────────────────────────────
          PlanCard(
            index: 0,
            selectedIndex: _selectedIndex,
            onTap: () => setState(() => _selectedIndex = 0),
            name: 'Pro',
            price: '299',
            period: 'شهرياً',
            color: AppColors.primary,
            lightColor: AppColors.primaryLight,
            icon: Icons.workspace_premium_rounded,
            badge: 'الأكثر شعبية',
            features: [
              '50 مزاد شهرياً',
              '5 إبرازات مجانية',
              'شارة Pro مميزة',
              'دعم فني سريع',
              'تحليلات المبيعات',
            ],
          ),

          const SizedBox(height: 14),

          // ── Elite Plan ────────────────────────────────────────────────
          PlanCard(
            index: 1,
            selectedIndex: _selectedIndex,
            onTap: () => setState(() => _selectedIndex = 1),
            name: 'Elite',
            price: '599',
            period: 'شهرياً',
            color: AppColors.orange,
            lightColor: AppColors.orangeLight,
            icon: Icons.star_rounded,
            features: [
              'مزادات غير محدودة',
              'إبرازات غير محدودة',
              'دعم أولوية 24/7',
              'شارة Elite الذهبية',
              'تحليلات متقدمة',
              'عروض حصرية',
              'مدير حساب مخصص',
            ],
          ),

          const SizedBox(height: 14),

          // ── Basic (Commission) Plan ───────────────────────────────────
          PlanCard(
            index: 2,
            selectedIndex: _selectedIndex,
            onTap: () => setState(() => _selectedIndex = 2),
            name: 'Basic',
            subtitle: '(عمولة)',
            price: 'مجاناً',
            period: 'عمولة 5% فقط',
            color: AppColors.blue,
            lightColor: AppColors.blueLight,
            icon: Icons.bolt_rounded,
            features: [
              'مجاني للانضمام',
              'عمولة 5% على كل بيع',
              'وصول كامل للمنصة',
              'بطاقة هوية رقمية',
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
