import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

import '../../../../l10n/app_localizations.dart';
class HomeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: AppLocalizations.of(context).alryysya),
      _NavItem(icon: Icons.gavel_rounded, label: AppLocalizations.of(context).auction7),
      _NavItem(icon: Icons.storefront_rounded, label: AppLocalizations.of(context).almtjr),
      _NavItem(icon: Icons.meeting_room_rounded, label: AppLocalizations.of(context).rooms),
      _NavItem(icon: Icons.emoji_events_rounded, label: AppLocalizations.of(context).alntayj),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final active = i == currentIndex;
              final color =
                  active ? AppColors.primary : AppColors.textSecondary;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        height: 3,
                        width: active ? 28 : 0,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(3),
                            bottomRight: Radius.circular(3),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Icon(item.icon, size: 22, color: color),
                      SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              active ? FontWeight.bold : FontWeight.normal,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}
