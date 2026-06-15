import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class HomeSellerDemoSection extends StatelessWidget {
  const HomeSellerDemoSection({super.key});

  static const Color _accent = AppColors.primary;
  static const Color _accentDark = AppColors.primaryDark;
  static const Color _accentLight = AppColors.primaryLight;
  static const Color _accentMid = Color(0xFF43A047);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            children: const [
              Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'أدوات مقدم الخدمة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
            ],
          ),
        ),
        SizedBox(
          height: 316,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              SizedBox(width: 272, child: _MultiRoomCard()),
              SizedBox(width: 12),
              SizedBox(width: 272, child: _OwnershipRegistryCard()),
              SizedBox(width: 12),
              SizedBox(width: 272, child: _ReferralCard()),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Multi-Room Management Card
// ─────────────────────────────────────────────────────────────────────────────
class _MultiRoomCard extends StatelessWidget {
  const _MultiRoomCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [HomeSellerDemoSection._accentDark, HomeSellerDemoSection._accentMid],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: HomeSellerDemoSection._accent.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title + badge + description on the right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'إدارة الغرف المتعددة',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('NEW',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'إنشاء وإدارة عدة غرف مزادات',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // chevron on the left
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: const [
              _WhiteChip(icon: Icons.shopping_bag_rounded, label: '3 باقات مختلفة'),
              _WhiteChip(icon: Icons.bolt_rounded, label: 'تخصيص كامل'),
              _WhiteChip(icon: Icons.all_inclusive_rounded, label: 'غير محدود'),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Ownership Registry Card
// ─────────────────────────────────────────────────────────────────────────────
class _OwnershipRegistryCard extends StatelessWidget {
  const _OwnershipRegistryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // header — title rightmost, shield leftmost
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [HomeSellerDemoSection._accentDark, HomeSellerDemoSection._accentMid],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('سجل الملكية',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    Text('نظام محمي وغير قابل للتلاعب',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.shield_rounded,
                    color: Colors.white70, size: 22),
              ],
            ),
          ),

          // action tiles
          _RegistryTile(
            icon: Icons.description_rounded,
            title: 'عرض سجل الملكية',
            subtitle: 'سجل كامل لجميع عمليات النقل',
            color: HomeSellerDemoSection._accent,
            lightColor: HomeSellerDemoSection._accentLight,
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _RegistryTile(
            icon: Icons.swap_horiz_rounded,
            title: 'عملية نقل الملكية',
            subtitle: '3 مراحل: سداد ← تسليم ← تأكيد',
            color: HomeSellerDemoSection._accentMid,
            lightColor: HomeSellerDemoSection._accentLight,
            onTap: () {},
          ),

          // protection list
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HomeSellerDemoSection._accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.shield_rounded,
                        color: HomeSellerDemoSection._accent, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'حماية السجل:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const _ProtectionItem(label: 'غير قابل للتلاعب'),
                const _ProtectionItem(label: 'يظهر فقط للبائع والمشتري'),
                const _ProtectionItem(label: 'حذف تلقائي بعد 7 أيام'),
                const _ProtectionItem(label: 'حذف يدوي بعد شهر (للبائع)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Referral Program Card
// ─────────────────────────────────────────────────────────────────────────────
class _ReferralCard extends StatefulWidget {
  const _ReferralCard();

  @override
  State<_ReferralCard> createState() => _ReferralCardState();
}

class _ReferralCardState extends State<_ReferralCard> {
  bool _copied = false;

  void _copy() {
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2),
        () => mounted ? setState(() => _copied = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // header — title rightmost, icon leftmost
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [HomeSellerDemoSection._accentDark, HomeSellerDemoSection._accentMid],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('برنامج المكافآت',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    Text('ادعُ أصدقاءك واكسب',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add_rounded,
                      color: Colors.white, size: 18),
                ),
              ],
            ),
          ),

          // stats — 50/invite rightmost
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: const [
                Expanded(
                    child: _StatBox(
                        value: '50',
                        label: 'لكل دعوة',
                        valueColor: HomeSellerDemoSection._accent)),
                _VDivider(),
                Expanded(child: _StatBox(value: '0', label: 'أرباح')),
                _VDivider(),
                Expanded(child: _StatBox(value: '0', label: 'دعوات')),
              ],
            ),
          ),

          // referral code
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('كود الدعوة',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // code text rightmost
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Text(
                            'PIGEON123',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                      // copy button leftmost
                      GestureDetector(
                        onTap: _copy,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: _copied
                                ? HomeSellerDemoSection._accentLight
                                : AppColors.inputBg,
                            borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(10)),
                          ),
                          child: Icon(
                            _copied
                                ? Icons.check_rounded
                                : Icons.copy_rounded,
                            color: _copied
                                ? HomeSellerDemoSection._accent
                                : AppColors.textSecondary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // واتساب rightmost
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_rounded, size: 16),
                        label: const Text('واتساب'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // مشاركة leftmost
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: const Text('مشاركة'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: HomeSellerDemoSection._accent,
                          side: const BorderSide(
                              color: HomeSellerDemoSection._accent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _WhiteChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WhiteChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
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

class _RegistryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color lightColor;
  final VoidCallback onTap;

  const _RegistryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.lightColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Row(
          children: [
            // title + subtitle rightmost
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // icon leftmost
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProtectionItem extends StatelessWidget {
  final String label;

  const _ProtectionItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.check_box_rounded,
              color: HomeSellerDemoSection._accent, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _StatBox({
    required this.value,
    required this.label,
    this.valueColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: valueColor)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 36, width: 1, color: AppColors.divider);
  }
}
