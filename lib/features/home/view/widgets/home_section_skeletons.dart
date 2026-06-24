import 'package:flutter/material.dart';

// ── Shimmer engine ────────────────────────────────────────────────────────────
// One AnimationController per _Shimmer instance drives all _Box children inside
// it via InheritedWidget propagation — no extra tickers needed per box.

class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
    _color = ColorTween(
      begin: const Color(0xFFE2E2E2),
      end: const Color(0xFFF0F0F0),
    ).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (_, child) => _ShimmerScope(color: _color.value!, child: child!),
      child: widget.child,
    );
  }
}

class _ShimmerScope extends InheritedWidget {
  final Color color;
  const _ShimmerScope({required this.color, required super.child});

  static Color of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerScope>()?.color ??
      const Color(0xFFE2E2E2);

  @override
  bool updateShouldNotify(_ShimmerScope old) => color != old.color;
}

// A rectangle that reads its fill color from the nearest _ShimmerScope.
class _Box extends StatelessWidget {
  final double? width;
  final double? height; // null = expand to parent constraints
  final BorderRadius borderRadius;

  const _Box({
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: _ShimmerScope.of(context),
        borderRadius: borderRadius,
      ),
    );
  }
}

// ── Public skeleton widgets ───────────────────────────────────────────────────

/// Skeleton for the announcements hero banner carousel.
class HomeHeroBannerSkeleton extends StatelessWidget {
  const HomeHeroBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _Shimmer(
        child: _Box(height: 148, borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

/// Skeleton for HomeSellerMetricsSection (gradient header + listings card + tools tile).
class HomeSellerMetricsSkeleton extends StatelessWidget {
  const HomeSellerMetricsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: _Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Box(height: 100, borderRadius: BorderRadius.circular(16)),
            const SizedBox(height: 12),
            _Box(
              height: 54,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            const SizedBox(height: 1),
            _Box(height: 54, borderRadius: BorderRadius.zero),
            const SizedBox(height: 1),
            _Box(
              height: 54,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            const SizedBox(height: 10),
            _Box(height: 60, borderRadius: BorderRadius.circular(12)),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for HomeBreedersSection (horizontal scroll of seller cards).
class HomeBreedersSkeleton extends StatelessWidget {
  const HomeBreedersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                _Box(width: 32, height: 32, borderRadius: BorderRadius.all(Radius.circular(8))),
                SizedBox(width: 8),
                _Box(width: 140, height: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 4,
              itemBuilder: (_, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _Box(
                  width: 160,
                  height: 220,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for HomeActiveAuctionsSection (2-column grid).
class HomeActiveAuctionsSkeleton extends StatelessWidget {
  const HomeActiveAuctionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                _Box(width: 130, height: 18),
                Spacer(),
                _Box(width: 40, height: 14),
              ],
            ),
            const SizedBox(height: 10),
            _Box(height: 40, borderRadius: BorderRadius.all(Radius.circular(10))),
            const SizedBox(height: 10),
            // Two rows of two cards
            for (int row = 0; row < 2; row++) ...[
              Row(
                children: [
                  Expanded(
                    child: _Box(height: 200, borderRadius: BorderRadius.all(Radius.circular(14))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Box(height: 200, borderRadius: BorderRadius.all(Radius.circular(14))),
                  ),
                ],
              ),
              if (row == 0) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton for HomeComingSoonSection.
class HomeComingSoonSkeleton extends StatelessWidget {
  const HomeComingSoonSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                _Box(width: 130, height: 18),
                Spacer(),
                _Box(width: 40, height: 14),
              ],
            ),
            const SizedBox(height: 10),
            _Box(height: 80, borderRadius: BorderRadius.all(Radius.circular(12))),
            const SizedBox(height: 8),
            _Box(height: 80, borderRadius: BorderRadius.all(Radius.circular(12))),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for HomeAuctionsSection (ending-soon list).
class HomeEndingSoonSkeleton extends StatelessWidget {
  const HomeEndingSoonSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                _Box(width: 130, height: 18),
                Spacer(),
                _Box(width: 40, height: 14),
              ],
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < 3; i++) ...[
              _Box(height: 90, borderRadius: BorderRadius.all(Radius.circular(14))),
              if (i < 2) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
