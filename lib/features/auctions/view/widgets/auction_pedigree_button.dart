import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class AuctionPedigreeButton extends StatelessWidget {
  const AuctionPedigreeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.description_rounded, size: 18),
          label: const Text('عرض شهادة النسب الكاملة',
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
