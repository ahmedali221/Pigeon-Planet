import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../model/asset_rating_model.dart';

class AuctionReviewsSection extends StatelessWidget {
  final List<AssetRatingModel> reviews;

  const AuctionReviewsSection({
    super.key,
    required this.reviews,
  });

  double get _avgRating {
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<int>(0, (sum, r) => sum + r.stars);
    return total / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final avg = _avgRating;
    final count = reviews.length;
    final preview = reviews.take(3).toList();

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
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    avg > 0 ? avg.toStringAsFixed(1) : '—',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 4),
                  Text('($count)',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
              const Text('تجارب المشترين',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
            ],
          ),

          if (reviews.isEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Icon(Icons.rate_review_outlined,
                      color: AppColors.textHint, size: 36),
                  SizedBox(height: 8),
                  Text('لا توجد تقييمات بعد',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            ...preview.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReviewCard(review: e.value, index: e.key),
                )),
            if (count > 3)
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
                  child: Text('عرض جميع التقييمات ($count)',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final AssetRatingModel review;
  final int index;

  const _ReviewCard({required this.review, required this.index});

  static const _avatarColors = [
    AppColors.primary,
    AppColors.orange,
    AppColors.blue,
    AppColors.purple,
  ];

  String get _roleLabel =>
      review.ownerType == 'Customer' ? 'مشتري' : 'مستخدم';

  String get _initial => review.ownerType == 'Customer' ? 'م' : 'م';

  Color get _avatarColor => _avatarColors[index % _avatarColors.length];

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 30) {
      return '${(diff.inDays / 30).floor()} شهر';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} يوم';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} ساعة';
    }
    return 'الآن';
  }

  @override
  Widget build(BuildContext context) {
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
          // avatar + role + time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _avatarColor,
                    child: Text(
                      _initial,
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
                        _roleLabel,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < review.stars
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
              Text(_formatDate(review.created),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint)),
            ],
          ),

          if (review.commentText != null && review.commentText!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.commentText!,
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}
