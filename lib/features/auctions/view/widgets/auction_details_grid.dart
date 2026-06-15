import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class AuctionDetailsGrid extends StatelessWidget {
  final Map<String, dynamic> data;
  const AuctionDetailsGrid({super.key, required this.data});

  static String _staminaLabel(String v) => switch (v) {
        'excellent' => 'ممتاز',
        'verygood'  => 'جيد جداً',
        'good'      => 'جيد',
        _           => '—',
      };

  static String _genderLabel(String v) => switch (v) {
        'male'   => 'ذكر',
        'female' => 'أنثى',
        'young'  => 'صغير',
        _        => '—',
      };

  @override
  Widget build(BuildContext context) {
    final achievements = data['achievements'] as String? ?? '';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // row 1: age | location
          Row(
            children: [
              Expanded(
                child: AuctionDetailCell(
                  label: 'العمر',
                  value: data['age'] as String? ?? '—',
                  icon: Icons.cake_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AuctionDetailCell(
                  label: 'الموقع',
                  value: data['location'] as String? ?? '—',
                  icon: Icons.location_on_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // row 2: ring | gender
          Row(
            children: [
              Expanded(
                child: AuctionDetailCell(
                  label: 'رقم الحلقة',
                  value: data['ringNumber'] as String? ?? '—',
                  icon: Icons.tag_rounded,
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AuctionDetailCell(
                  label: 'الجنس',
                  value: _genderLabel(data['gender'] as String? ?? ''),
                  icon: Icons.pets_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // row 3: speed | stamina
          Row(
            children: [
              Expanded(
                child: AuctionDetailCell(
                  label: 'السرعة',
                  value: (data['flyingSpeed'] as double?) != null
                      ? '${(data['flyingSpeed'] as double).toStringAsFixed(1)} كم/س'
                      : '—',
                  icon: Icons.bolt_rounded,
                  iconColor: AppColors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AuctionDetailCell(
                  label: 'التحمل',
                  value: _staminaLabel(data['staminaAbility'] as String? ?? ''),
                  icon: Icons.favorite_rounded,
                  iconColor: AppColors.red,
                ),
              ),
            ],
          ),
          // row 4: achievements (full width, only if present)
          if (achievements.isNotEmpty) ...[
            const SizedBox(height: 10),
            AuctionDetailCell(
              label: 'الإنجازات',
              value: achievements,
              icon: Icons.emoji_events_rounded,
              iconColor: const Color(0xFFD4A017),
              fullWidth: true,
            ),
          ],
          const SizedBox(height: 10),
          // breeder row (full width)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.pageBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.blue,
                  child: Text(
                    (data['breeder'] as String? ?? '?').isNotEmpty
                        ? (data['breeder'] as String)[0]
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('المربي',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        data['breeder'] as String? ?? '—',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
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

class AuctionDetailCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final bool fullWidth;

  const AuctionDetailCell({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
