import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class AuctionReviewsSection extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final List<Map<String, dynamic>> reviews;

  const AuctionReviewsSection({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 4),
                  Text('($reviewCount)',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary)),
                ],
              ),
              const Text('تجارب المربين',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
            ],
          ),

          const SizedBox(height: 12),

          ...reviews.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AuctionReviewCard(review: r),
              )),

          // show all button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('عرض جميع التقييمات ($reviewCount)',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class AuctionReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  const AuctionReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final stars = review['rating'] as int;
    final badges = review['badges'] as List<dynamic>;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar + name + time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        Color(review['avatarColor'] as int),
                    child: Text(
                      review['initial'] as String,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${review['name']} - ${review['role']}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < stars
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(review['time'] as String,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint)),
            ],
          ),

          const SizedBox(height: 8),

          // review text
          Text(review['text'] as String,
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5)),

          const SizedBox(height: 8),

          // badges
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 6,
            children: badges.map((b) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_rounded,
                      color: AppColors.primary, size: 12),
                  const SizedBox(width: 3),
                  Text(b as String,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
