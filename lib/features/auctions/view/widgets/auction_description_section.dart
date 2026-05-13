import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class AuctionDescriptionSection extends StatelessWidget {
  final String text;
  const AuctionDescriptionSection({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الوصف',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(text,
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6)),
        ],
      ),
    );
  }
}
