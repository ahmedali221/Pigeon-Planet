import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/shell_scaffold.dart';

class HomeTopBar extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onCartPressed;
  final String? avatarUrl;
  final int unreadCount;
  final bool showCart;

  const HomeTopBar({
    super.key,
    this.onMenuPressed,
    this.onAvatarTap,
    this.onNotificationsPressed,
    this.onCartPressed,
    this.avatarUrl,
    this.unreadCount = 0,
    this.showCart = false,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedAvatarUrl = avatarUrl?.trim();
    final hasAvatarUrl =
        normalizedAvatarUrl != null && normalizedAvatarUrl.isNotEmpty;

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Profile avatar (rightmost in RTL)
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54, width: 1.5),
              ),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white24,
                backgroundImage: hasAvatarUrl
                    ? NetworkImage(normalizedAvatarUrl)
                    : null,
                child: hasAvatarUrl
                    ? null
                    : const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ),
          ShellBackButton(color: Colors.white),
          // Logo (center)
          Expanded(
            child: Center(
              child: SizedBox(
                height: 34,
                child: SvgPicture.asset(
                  'assets/brand/logo.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Cart (customers only)
          if (showCart) ...[
            IconButton(
              icon: const Icon(Icons.shopping_cart_rounded,
                  color: Colors.white, size: 24),
              onPressed: onCartPressed,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
          ],
          // Notifications
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_rounded,
                    color: Colors.white, size: 24),
                onPressed: onNotificationsPressed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -4,
                  child: _NotificationBadge(count: unreadCount),
                ),
            ],
          ),
          const SizedBox(width: 4),
          // Hamburger — opens drawer (leftmost in RTL)
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
            onPressed: onMenuPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  final int count;

  const _NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
