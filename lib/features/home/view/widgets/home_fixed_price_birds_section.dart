import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class HomeFixedPriceBirdsSection extends StatelessWidget {
  final List<Map<String, dynamic>> birds;

  const HomeFixedPriceBirdsSection({super.key, required this.birds});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.chevron_left_rounded,
                        color: AppColors.textSecondary, size: 20),
                    Text('الكل',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'طيور بسعر ثابت',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: birds.length,
            itemBuilder: (context, i) {
              final bird = birds[i];
              final hasDiscount = bird['discount'] != null;
              final hasOldPrice = bird['oldPrice'] != null;

              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                          child: SizedBox(
                            height: 110,
                            width: double.infinity,
                            child: Image.network(
                              'https://picsum.photos/seed/${i + 30}/200/150',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: Color(bird['color'] as int),
                                child: const Icon(Icons.flutter_dash,
                                    color: Colors.white54, size: 40),
                              ),
                            ),
                          ),
                        ),
                        if (hasDiscount)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'خصم ${bird['discount']}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Row(
                            children: [
                              _OverlayChip(
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: Colors.amber, size: 11),
                                    const SizedBox(width: 2),
                                    Text(bird['rating'] as String,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              _OverlayChip(
                                child: Row(
                                  children: [
                                    const Icon(Icons.visibility_outlined,
                                        color: Colors.white70, size: 10),
                                    const SizedBox(width: 2),
                                    Text(bird['views'] as String,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                      child: Text(
                        bird['name'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Text(
                            'ج.م ${bird['price']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          if (hasOldPrice) ...[
                            const SizedBox(width: 6),
                            Text(
                              bird['oldPrice'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          child: const Text('أضف للسلة',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OverlayChip extends StatelessWidget {
  final Widget child;
  const _OverlayChip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}
