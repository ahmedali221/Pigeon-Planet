import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/seller_home_summary.dart';

class HomeSellerNotificationsSection extends StatelessWidget {
  final SellerHomeSummary? summary;

  const HomeSellerNotificationsSection({super.key, this.summary});

  @override
  Widget build(BuildContext context) {
    final items = summary?.notifications ?? const <SellerHomeNotification>[];
    final newCount = summary?.notificationsNewCount ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications_rounded,
                      color: AppColors.textPrimary, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'إشعارات مهمة',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (newCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$newCount جديدة',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'لا إشعارات حديثة',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        if (i > 0) const _Divider(),
                        _NotifItem(
                          dot: _dotForKind(items[i].kind),
                          title: items[i].title,
                          time: items[i].timeHint,
                          isNew: items[i].isNew,
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static Color _dotForKind(String kind) {
    switch (kind) {
      case 'order':
        return AppColors.red;
      case 'sold':
        return AppColors.success;
      case 'bid':
      default:
        return AppColors.orange;
    }
  }
}

class _NotifItem extends StatelessWidget {
  final Color dot;
  final String title;
  final String time;
  final bool isNew;

  const _NotifItem({
    required this.dot,
    required this.title,
    required this.time,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 9,
            height: 9,
            decoration:
                BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isNew ? FontWeight.bold : FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ),
          if (isNew)
            Container(
              margin: const EdgeInsetsDirectional.only(start: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'جديد',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1, thickness: 1, color: AppColors.divider, indent: 33);
  }
}
