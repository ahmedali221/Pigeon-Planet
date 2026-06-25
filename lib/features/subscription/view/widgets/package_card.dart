import 'package:flutter/material.dart';
import 'package:pigeon_planet/core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class PlanCard extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;
  final String name;
  final String? subtitle;
  final String price;
  final String period;
  final Color color;
  final Color lightColor;
  final IconData icon;
  final String? badge;
  final List<String> features;
  final VoidCallback? onSubscribe;
  final bool isLoading;

  const PlanCard({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    required this.name,
    this.subtitle,
    required this.price,
    required this.period,
    required this.color,
    required this.lightColor,
    required this.icon,
    this.badge,
    required this.features,
    this.onSubscribe,
    this.isLoading = false,
  });

  bool get _isSelected => selectedIndex == index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isSelected ? color : AppColors.border,
            width: _isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Badge + Checkmark Row ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _isSelected
                      ? Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        )
                      : Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                        ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                ],
              ),
            ),

            // ── Icon + Name + Price ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                subtitle!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(context).jM5,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: price,
                                style: TextStyle(
                                  fontSize: 26,
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: ' / $period',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: AppColors.border),

            // ── Feature List ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: color,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // ── Subscribe Button ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: (isLoading || onSubscribe == null) ? null : onSubscribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSelected ? color : Colors.white,
                    foregroundColor: _isSelected ? Colors.white : color,
                    disabledBackgroundColor: _isSelected ? color.withValues(alpha: 0.6) : Colors.white,
                    side: BorderSide(color: color, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading && _isSelected
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _isSelected ? Colors.white : color,
                          ),
                        )
                      : Text(
                          _isSelected ? AppLocalizations.of(context).subscribe : AppLocalizations.of(context).packageLabel3,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
