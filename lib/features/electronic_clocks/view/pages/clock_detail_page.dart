import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../model/electronic_clock_model.dart';

class ClockDetailPage extends StatelessWidget {
  final ElectronicClockModel clock;

  const ClockDetailPage({super.key, required this.clock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ClockImageSection(clock: clock),
                  const SizedBox(height: 12),
                  _InfoCard(clock: clock),
                  const SizedBox(height: 12),
                  _AgentCard(agent: clock.agent),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _BottomBar(clock: clock),
        ],
      ),
    );
  }
}

// ── Image section with overlaid back button ──────────────────────────────────

class _ClockImageSection extends StatelessWidget {
  final ElectronicClockModel clock;
  const _ClockImageSection({required this.clock});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // image / placeholder
          clock.imageUrl != null
              ? Image.network(clock.imageUrl!, fit: BoxFit.cover)
              : Container(
                  color: AppColors.primaryLight,
                  child: const Center(
                    child: Icon(
                      Icons.timer_rounded,
                      color: AppColors.primary,
                      size: 80,
                    ),
                  ),
                ),
          // gradient overlay for button visibility
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.35],
                colors: [Colors.black38, Colors.transparent],
              ),
            ),
          ),
          // back button — right side (RTL start)
          Positioned(
            top: topPad + 8,
            right: 8,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black26,
                shape: const CircleBorder(),
              ),
            ),
          ),
          // brand badge — bottom start (right in RTL)
          Positioned(
            bottom: 14,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                clock.brand,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          // stock status — bottom end (left in RTL)
          Positioned(
            bottom: 14,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: clock.inStock ? AppColors.success : AppColors.textHint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    clock.inStock ? Icons.check_circle_outline : Icons.cancel_outlined,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    clock.inStock ? 'متاح' : 'نفذ المخزون',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main info card ───────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final ElectronicClockModel clock;
  const _InfoCard({required this.clock});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // name + rating row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // rating — end (left in RTL)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        clock.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ],
                  ),
                  Text(
                    '${clock.reviewCount} تقييم',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // name — start (right in RTL)
              Expanded(
                child: Text(
                  clock.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),

          // description
          const Text(
            'الوصف',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            clock.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),

          if (clock.features.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 14),
            const Text(
              'المميزات',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ...clock.features.map((f) => _FeatureRow(label: f)),
          ],
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  const _FeatureRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // check icon — start (right in RTL)
          const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ── Agent card ───────────────────────────────────────────────────────────────

class _AgentCard extends StatelessWidget {
  final ClockAgentModel agent;
  const _AgentCard({required this.agent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // section header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Text(
                  'الوكيل المعتمد',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ),
          ),

          // agent info row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                // call button — end (left in RTL)
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_rounded, size: 16),
                  label: const Text('اتصال'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),

                const SizedBox(width: 12),

                // info — middle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Text(
                            agent.governorate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: AppColors.textHint,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        agent.phoneNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // avatar — start (right in RTL)
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: agent.photoUrl != null
                      ? NetworkImage(agent.photoUrl!)
                      : null,
                  child: agent.photoUrl == null
                      ? const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 30,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final ElectronicClockModel clock;
  const _BottomBar({required this.clock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // order button — end (left in RTL)
          Expanded(
            child: FilledButton.icon(
              onPressed: clock.inStock
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('سيتم التواصل مع الوكيل'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      )
                  : null,
              icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
              label: const Text(
                'تواصل مع الوكيل',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // price — start (right in RTL)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'السعر',
                style: TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
              Text(
                '${clock.price.toStringAsFixed(0)} ج.م',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
