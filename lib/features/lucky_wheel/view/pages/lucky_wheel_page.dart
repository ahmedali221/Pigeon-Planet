import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../../../core/di/injection.dart';
import '../../model/wheel_prize_model.dart';
import '../../viewmodel/lucky_wheel_bloc.dart';
import '../widgets/spin_result_sheet.dart';
import '../widgets/wheel_painter.dart';

import '../../../../l10n/app_localizations.dart';
class LuckyWheelPage extends StatelessWidget {
  final bool isSeller;

  LuckyWheelPage({super.key, required this.isSeller});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LuckyWheelBloc>()
        ..add(LuckyWheelLoadRequested(isSeller: isSeller)),
      child: _LuckyWheelView(isSeller: isSeller),
    );
  }
}

// ── Animated view (StatefulWidget for spin animation) ─────────────────────────

class _LuckyWheelView extends StatefulWidget {
  final bool isSeller;

  _LuckyWheelView({required this.isSeller});

  @override
  State<_LuckyWheelView> createState() => _LuckyWheelViewState();
}

class _LuckyWheelViewState extends State<_LuckyWheelView>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double> _rotation = AlwaysStoppedAnimation(0.0);
  double _currentAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 4500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Computes the forward rotation (clockwise) needed to land [winnerIdx]
  /// at the top pointer, adds 5 full spins, then animates.
  void _startSpin(int winnerIdx, int n) {
    if (n == 0) return;
    final sliceAngle = 2 * pi / n;
    // Amount to rotate (from wheel-at-rest) so winner center aligns with pointer:
    //   (n - winnerIdx - 0.5) * sliceAngle
    final targetNormalized = ((n - winnerIdx - 0.5) * sliceAngle) % (2 * pi);
    final currentNormalized = _currentAngle % (2 * pi);

    // Shortest forward (clockwise) arc from current to target
    double diff = (targetNormalized - currentNormalized + 2 * pi) % (2 * pi);
    if (diff < 0.05) diff += 2 * pi; // ensure we always spin forward

    final finalAngle = _currentAngle + 5 * 2 * pi + diff;

    _rotation = Tween<double>(begin: _currentAngle, end: finalAngle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _currentAngle = finalAngle;

    _controller.reset();
    _controller.forward().whenComplete(() {
      if (!mounted) return;
      final bloc = context.read<LuckyWheelBloc>();
      final spinResult = bloc.state.spinResult;
      if (spinResult != null) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          isDismissible: false,
          enableDrag: false,
          builder: (_) => SpinResultSheet(
            result: spinResult,
            onCollect: () {
              if (!mounted) return;
              bloc.add(const LuckyWheelReadyForNextSpin());
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LuckyWheelBloc, LuckyWheelState>(
      listenWhen: (prev, curr) =>
          prev.winnerIndex != curr.winnerIndex &&
          curr.status == LuckyWheelStatus.spinning,
      listener: (_, state) {
        if (state.winnerIndex != null) {
          _startSpin(state.winnerIndex!, state.prizes.length);
        }
      },
      child: BlocBuilder<LuckyWheelBloc, LuckyWheelState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            appBar: PPWAppBar(
              titleWidget: Text(
                AppLocalizations.of(context).luckyWheelTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, LuckyWheelState state) {
    if (state.status == LuckyWheelStatus.initial ||
        state.status == LuckyWheelStatus.loading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state.status == LuckyWheelStatus.error) {
      return _ErrorView(
        message: state.errorMessage ?? AppLocalizations.of(context).loading4,
        onRetry: () => context
            .read<LuckyWheelBloc>()
            .add(LuckyWheelLoadRequested(isSeller: widget.isSeller)),
      );
    }

    final isSpinning = state.status == LuckyWheelStatus.spinning;
    final remainingAttempts = state.current?.remainingAttempts ?? 0;
    final hasPrizes = state.prizes.isNotEmpty;
    // hasSpun is reset to false after the user collects from the result sheet,
    // so canSpin re-evaluates purely on remaining attempts.
    final canSpin =
        !state.hasSpun && !isSpinning && remainingAttempts > 0 && hasPrizes;

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Info header ───────────────────────────────────────────────────
          _WheelInfoHeader(
            isSeller: widget.isSeller,
            remainingAttempts: remainingAttempts,
            hasPrizes: hasPrizes,
          ),

          SizedBox(height: 12),

          _AttemptsStatusCard(
            remainingAttempts: remainingAttempts,
            hasPrizes: hasPrizes,
          ),

          SizedBox(height: 24),

          // ── Wheel + pointer ───────────────────────────────────────────────
          _WheelWithPointer(
            prizes: state.prizes,
            rotation: _rotation,
          ),

          SizedBox(height: 28),

          // ── Spin button ───────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: _SpinButton(
              hasSpun: state.hasSpun,
              isSpinning: isSpinning,
              canSpin: canSpin,
              remainingAttempts: remainingAttempts,
              hasPrizes: hasPrizes,
              onSpin: () => context
                  .read<LuckyWheelBloc>()
                  .add(LuckyWheelSpinRequested()),
            ),
          ),

          SizedBox(height: 28),

          // ── Prize slots legend ────────────────────────────────────────────
          _PrizeLegend(prizes: state.prizes),

          SizedBox(height: 48),
        ],
      ),
    );
  }
}

// ── Info header ───────────────────────────────────────────────────────────────

class _WheelInfoHeader extends StatelessWidget {
  final bool isSeller;
  final int remainingAttempts;
  final bool hasPrizes;

  const _WheelInfoHeader({
    required this.isSeller,
    required this.remainingAttempts,
    required this.hasPrizes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎰 دورتك متاحة!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  isSeller
                      ? AppLocalizations.of(context).auction8
                      : AppLocalizations.of(context).auction9,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('🎡', style: TextStyle(fontSize: 24)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wheel + pointer composite ─────────────────────────────────────────────────

class _AttemptsStatusCard extends StatelessWidget {
  final int remainingAttempts;
  final bool hasPrizes;

  const _AttemptsStatusCard({
    required this.remainingAttempts,
    required this.hasPrizes,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hint = !hasPrizes
        ? l.noPrizesConfiguredHint
        : remainingAttempts > 0
            ? l.canSpinNowHint
            : l.earnAttemptsHint;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$remainingAttempts',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.availableAttemptsTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelWithPointer extends StatelessWidget {
  final List<WheelPrizeModel> prizes;
  final Animation<double> rotation;

  const _WheelWithPointer({
    required this.prizes,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    if (prizes.isEmpty) {
      return Container(
        width: 296,
        height: 296,
        margin: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.casino_outlined,
              color: AppColors.textSecondary,
              size: 42,
            ),
            SizedBox(height: 10),
            Text(
              'No prizes',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 42),
              child: Text(
                'Add active Lucky Wheel prizes to show wheel items.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Outer glow ring
        Container(
          width: 316,
          height: 316,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
        ),

        // Wheel (rotates)
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: AnimatedBuilder(
            animation: rotation,
            builder: (_, child) => Transform.rotate(
              angle: rotation.value,
              child: child,
            ),
            child: SizedBox(
              width: 296,
              height: 296,
              child: CustomPaint(painter: WheelPainter(prizes: prizes)),
            ),
          ),
        ),

        // Fixed pointer arrow at top
        _WheelPointer(),
      ],
    );
  }
}

// ── Pointer triangle ──────────────────────────────────────────────────────────

class _WheelPointer extends StatelessWidget {
  const _WheelPointer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(6),
          bottom: Radius.circular(3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.arrow_drop_down_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

// ── Spin button ───────────────────────────────────────────────────────────────

class _SpinButton extends StatelessWidget {
  final bool hasSpun;
  final bool isSpinning;
  final bool canSpin;
  final int remainingAttempts;
  final bool hasPrizes;
  final VoidCallback onSpin;

  const _SpinButton({
    required this.hasSpun,
    required this.isSpinning,
    required this.canSpin,
    required this.remainingAttempts,
    required this.hasPrizes,
    required this.onSpin,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final enabled = canSpin;
    final label = isSpinning
        ? l.spinningLabel
        : !hasPrizes
            ? l.noPrizesLabel
            : remainingAttempts <= 0
                ? l.noAttemptsLabel
                : l.spinNowLabel;

    return GestureDetector(
      onTap: enabled ? onSpin : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                )
              : null,
          color: enabled ? null : AppColors.border,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Prize legend ──────────────────────────────────────────────────────────────

class _PrizeLegend extends StatelessWidget {
  final List<WheelPrizeModel> prizes;

  const _PrizeLegend({required this.prizes});

  @override
  Widget build(BuildContext context) {
    if (prizes.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(
                Icons.casino_outlined,
                color: AppColors.textSecondary,
                size: 34,
              ),
              SizedBox(height: 10),
              Text(
                'No wheel prizes yet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'The server returned an empty prizes list. Add active Lucky Wheel prizes in the backend/admin panel, then refresh this page.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalWeight =
        prizes.where((p) => p.isEnabled).fold(0, (s, p) => s + p.weight);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              AppLocalizations.of(context).availablePrizes,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...prizes.map((prize) {
            final pct = totalWeight > 0 && prize.isEnabled
                ? (prize.weight / totalWeight * 100).toStringAsFixed(1)
                : '0.0';
            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: _PrizeRow(prize: prize, pct: pct),
            );
          }),
        ],
      ),
    );
  }
}

class _PrizeRow extends StatelessWidget {
  final WheelPrizeModel prize;
  final String pct;

  const _PrizeRow({required this.prize, required this.pct});

  @override
  Widget build(BuildContext context) {
    final active = prize.isEnabled;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? prize.color.withValues(alpha: 0.2)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Color dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? prize.color : Colors.grey.shade300,
            ),
          ),
          SizedBox(width: 10),
          // Emoji
          Text(
            prize.emoji,
            style: TextStyle(
              fontSize: 18,
              color: active ? null : Colors.grey,
            ),
          ),
          SizedBox(width: 10),
          // Label
          Expanded(
            child: Text(
              prize.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.textPrimary : AppColors.textHint,
              ),
            ),
          ),
          // Probability bar + percentage
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: active ? prize.color : AppColors.textHint,
                    fontFamily: 'monospace',
                  ),
                ),
                SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: active && pct != '0.0'
                        ? double.parse(pct) / 100
                        : 0,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      active ? prize.color : Colors.grey.shade300,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(AppLocalizations.of(context).retry,
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
