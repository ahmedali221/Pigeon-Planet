import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../auctions/model/bird_summary_model.dart';

import '../../../../l10n/app_localizations.dart';
class HomeFixedPriceBirdsSection extends StatelessWidget {
  final List<BirdSummaryModel> birds;
  final void Function(BirdSummaryModel)? onBirdTap;

  HomeFixedPriceBirdsSection({
    super.key,
    required this.birds,
    this.onBirdTap,
  });

  static String _fmt(double v) {
    if (v == 0) return '0';
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(',');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'طيور بسعر ثابت',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context).all,
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                    Icon(Icons.chevron_left_rounded,
                        color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12),

        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: birds.length,
            itemBuilder: (context, i) {
              final bird = birds[i];

              return GestureDetector(
                onTap: onBirdTap != null ? () => onBirdTap!(bird) : null,
                child: Container(
                  width: 160,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(14),
                            ),
                            child: SizedBox(
                              height: 110,
                              width: double.infinity,
                              child: bird.thumbnailUrl != null
                                  ? Image.network(
                                      bird.thumbnailUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _placeholder(bird),
                                    )
                                  : _placeholder(bird),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Row(
                              children: [
                                if (bird.gender.isNotEmpty)
                                  _OverlayChip(
                                    child: Text(
                                      bird.gender == 'male'
                                          ? AppLocalizations.of(context).male
                                          : bird.gender == 'female'
                                              ? AppLocalizations.of(context).female
                                              : AppLocalizations.of(context).genderYoung,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                if (bird.flyingSpeed != null) ...[
                                  SizedBox(width: 4),
                                  _OverlayChip(
                                    child: Row(
                                      children: [
                                        Icon(Icons.bolt_rounded,
                                            color: Colors.amber, size: 10),
                                        SizedBox(width: 2),
                                        Text(
                                          '${bird.flyingSpeed!.toStringAsFixed(0)} كم',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 8, 10, 0),
                        child: Text(
                          bird.name.isNotEmpty ? bird.name : bird.ringNumber,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (bird.colour.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 2, 10, 0),
                          child: Text(
                            bird.colour,
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'ج.م ${_fmt(bird.price)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: SizedBox(
                          width: double.infinity,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: onBirdTap != null
                                ? () => onBirdTap!(bird)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            child: Text(AppLocalizations.of(context).viewDetails,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _placeholder(BirdSummaryModel bird) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.15),
      child: Center(
        child: Icon(Icons.flutter_dash, color: AppColors.primary, size: 40),
      ),
    );
  }
}

class _OverlayChip extends StatelessWidget {
  final Widget child;
  _OverlayChip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}
