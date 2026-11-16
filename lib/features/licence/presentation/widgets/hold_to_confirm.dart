import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';

class HoldToConfirm extends StatefulWidget {
  const HoldToConfirm({
    required this.label,
    required this.onConfirmed,
    super.key,
  });

  final String label;
  final Future<void> Function() onConfirmed;

  @override
  State<HoldToConfirm> createState() => _HoldToConfirmState();
}

class _HoldToConfirmState extends State<HoldToConfirm>
    with SingleTickerProviderStateMixin {
  late final _hold = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
    reverseDuration: const Duration(milliseconds: 420),
  );
  int _step = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _hold
      ..addListener(_tick)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _confirm();
      });
  }

  void _tick() {
    final step = (_hold.value * 5).floor();
    if (step > _step && _hold.status == AnimationStatus.forward) {
      HapticFeedback.selectionClick();
    }
    _step = step;
  }

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.heavyImpact();
    await widget.onConfirmed();
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!_busy) _hold.forward();
      },
      onTapUp: (_) {
        if (!_busy && !_hold.isCompleted) _hold.reverse();
      },
      onTapCancel: () {
        if (!_busy && !_hold.isCompleted) _hold.reverse();
      },
      child: AnimatedBuilder(
        animation: _hold,
        builder: (context, _) {
          final t = _hold.value;
          final holding = t > 0 && !_busy;
          return Transform.scale(
            scale: 1 - 0.03 * (holding ? 1 : 0),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: AppColors.deep,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.5 + 0.5 * t),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.12 + 0.3 * t),
                    blurRadius: 18 + 18 * t,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: _busy ? 1 : AppMotion.easeOut.transform(t),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFA27A22),
                              AppColors.gold,
                              AppColors.goldLight,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: AppColors.night,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fingerprint_rounded,
                                  size: 22,
                                  color: t > 0.45
                                      ? AppColors.night
                                      : AppColors.gold,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  holding ? 'Keep holding…' : widget.label,
                                  style: AppText.button.copyWith(
                                    color: t > 0.45
                                        ? AppColors.night
                                        : AppColors.goldLight,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
