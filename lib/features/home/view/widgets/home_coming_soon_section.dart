import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class HomeComingSoonSection extends StatelessWidget {
  final List<Map<String, dynamic>> birds;

  const HomeComingSoonSection({super.key, required this.birds});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.chevron_left_rounded,
                        color: AppColors.primary, size: 20),
                    Text(
                      '← الكل',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'طيور قريباً',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              const Text('🔥', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Alert banner ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDD835)),
            ),
            child: const Text(
              'سوف تنزل المزاد قريباً - كن مستعداً!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF795548),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Cards list ─────────────────────────────────────────────────────
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: birds.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, i) => _ComingSoonCard(bird: birds[i]),
        ),
      ],
    );
  }
}

// ── Coming soon card ─────────────────────────────────────────────────────────
class _ComingSoonCard extends StatelessWidget {
  final Map<String, dynamic> bird;

  const _ComingSoonCard({required this.bird});

  @override
  Widget build(BuildContext context) {
    final isMale = bird['gender'] == 'male';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Image area ──────────────────────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(
                    'https://picsum.photos/seed/${bird['seed']}/400/220',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Color(bird['color'] as int),
                      child: const Icon(Icons.flutter_dash,
                          color: Colors.white54, size: 50),
                    ),
                  ),
                ),
              ),
              // views — top right
              Positioned(
                top: 10,
                right: 10,
                child: _OverlayChip(
                  child: Row(
                    children: [
                      Text(
                        bird['views'] as String,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                      ),
                      const SizedBox(width: 3),
                      const Text('👁', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
              // rating — below views
              Positioned(
                top: 40,
                right: 10,
                child: _OverlayChip(
                  child: Row(
                    children: [
                      Text(
                        bird['rating'] as String,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 12),
                    ],
                  ),
                ),
              ),
              // قريباً badge — top left
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'قريباً',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // countdown bar — bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                  color: AppColors.primary.withValues(alpha: 0.92),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CountdownUnit(
                          value: bird['seconds'] as String,
                          label: 'ثانية'),
                      _sep(),
                      _CountdownUnit(
                          value: bird['minutes'] as String,
                          label: 'دقيقة'),
                      _sep(),
                      _CountdownUnit(
                          value: bird['hours'] as String,
                          label: 'ساعة'),
                      _sep(),
                      _CountdownUnit(
                          value: bird['days'] as String,
                          label: 'يوم'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Details ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // name + gender + ring
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      bird['ring'] as String,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isMale ? Icons.male_rounded : Icons.female_rounded,
                      size: 18,
                      color: isMale
                          ? const Color(0xFF1565C0)
                          : const Color(0xFFC62828),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bird['name'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // breed
                Text(
                  bird['breed'] as String,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                // pedigree note
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        bird['pedigree'] as String,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('👤', style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 2),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.check_box_rounded,
                      color: AppColors.primary, size: 16),
                ),

                const Divider(height: 18, color: AppColors.divider),

                // expected price
                const Text(
                  'السعر المتوقع',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  'ج.م ${bird['expectedPrice']}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                // seller row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      bird['seller'] as String,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 16),
                  ],
                ),

                const SizedBox(height: 12),

                // notify button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_active_rounded,
                        size: 18),
                    label: const Text('أخبرني عند النزول',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sep() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Text(':',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      );
}

// ── Shared helpers ────────────────────────────────────────────────────────────
class _CountdownUnit extends StatelessWidget {
  final String value;
  final String label;

  const _CountdownUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 9)),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}
