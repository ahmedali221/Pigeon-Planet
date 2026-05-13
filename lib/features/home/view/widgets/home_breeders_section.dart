import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class HomeBreedersSection extends StatelessWidget {
  final List<Map<String, dynamic>> breeders;

  const HomeBreedersSection({super.key, required this.breeders});

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
                'مربيون قد تعرفهم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.people_rounded, color: AppColors.purple, size: 20),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: breeders.length,
            itemBuilder: (context, i) {
              final b = breeders[i];
              final isFollowing = b['isFollowing'] as bool;
              final hasNew = b['hasNew'] as bool;

              return Container(
                width: 150,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(12),
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
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: NetworkImage(
                              'https://picsum.photos/seed/${i + 20}/80/80'),
                          onBackgroundImageError: (_, _) {},
                        ),
                        if (hasNew)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('مزاد جديد',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 8)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      b['name'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      b['note'] as String,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${b['followers']} متابع',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textHint)),
                        const Text(' • ',
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 10)),
                        Text('${b['auctions']} مزاد',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textHint)),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isFollowing
                              ? AppColors.textSecondary
                              : AppColors.primary,
                          side: BorderSide(
                              color: isFollowing
                                  ? AppColors.border
                                  : AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          isFollowing ? '✓ متابعة' : 'متابعة',
                          style: const TextStyle(fontSize: 11),
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
