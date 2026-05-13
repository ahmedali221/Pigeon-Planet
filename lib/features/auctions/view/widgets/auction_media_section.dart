import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class AuctionMediaSection extends StatelessWidget {
  final int currentImage;
  final bool isFavorite;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onFavorite;
  final int imageCount;
  final int seed;

  const AuctionMediaSection({
    super.key,
    required this.currentImage,
    required this.isFavorite,
    required this.onPageChanged,
    required this.onFavorite,
    required this.imageCount,
    required this.seed,
  });

  static const _thumbnailLabels = [
    'صورة الطير',
    'فيديو الطير',
    'الأب',
    'الأم',
    'الإضافية',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Main image
          Stack(
            children: [
              SizedBox(
                height: 260,
                width: double.infinity,
                child: Image.network(
                  'https://picsum.photos/seed/$seed/400/300',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.primaryLight,
                    child: const Icon(Icons.flutter_dash,
                        color: AppColors.primary, size: 60),
                  ),
                ),
              ),
              // views — top right (start in RTL)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('0 مشاهدة',
                          style:
                              TextStyle(color: Colors.white, fontSize: 11)),
                      SizedBox(width: 4),
                      Icon(Icons.visibility_outlined,
                          color: Colors.white70, size: 13),
                    ],
                  ),
                ),
              ),
              // share + favorite — top left (end in RTL)
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    AuctionCircleBtn(icon: Icons.share_rounded, onTap: () {}),
                    const SizedBox(width: 8),
                    AuctionCircleBtn(
                      icon: isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      iconColor: isFavorite ? AppColors.red : null,
                      onTap: onFavorite,
                    ),
                  ],
                ),
              ),
              // page indicator — bottom left (end in RTL)
              Positioned(
                bottom: 10,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$imageCount / ${currentImage + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // watermark — bottom center
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'PIGEON PLANET',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Thumbnail strip
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _thumbnailLabels.length,
              itemBuilder: (context, i) {
                final isSelected = i == currentImage;
                final isVideo = i == 1;
                return GestureDetector(
                  onTap: () => onPageChanged(i),
                  child: Container(
                    width: 52,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            'https://picsum.photos/seed/${seed + i}/80/80',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                Container(color: AppColors.primaryLight),
                          ),
                          if (isVideo)
                            Container(
                              color: Colors.black.withValues(alpha: 0.4),
                              child: const Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 22),
                            ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2),
                              color:
                                  Colors.black.withValues(alpha: 0.55),
                              child: Text(
                                _thumbnailLabels[i],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 7),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AuctionCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const AuctionCircleBtn(
      {super.key, required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon,
            color: iconColor ?? AppColors.textSecondary, size: 18),
      ),
    );
  }
}
