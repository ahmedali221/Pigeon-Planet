import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class HomeTopBar extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onAvatarTap;
  final String? avatarUrl;

  const HomeTopBar({
    super.key,
    this.onMenuPressed,
    this.onAvatarTap,
    this.avatarUrl,
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
          // Logo (center)
          const Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🕊️', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PIGEON',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'PLANET',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Hamburger — opens drawer (leftmost in RTL)
          IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: 26,
            ),
            onPressed: onMenuPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
