import 'package:flutter/material.dart';

import '../effects/foil.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_typography.dart';
import 'pressable.dart';

enum _Tone { glow, gold, ghost }

class HudButton extends StatelessWidget {
  const HudButton.glow({
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
    this.expand = true,
    super.key,
  }) : _tone = _Tone.glow;

  const HudButton.gold({
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
    this.expand = true,
    super.key,
  }) : _tone = _Tone.gold;

  const HudButton.ghost({
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
    this.expand = true,
    super.key,
  }) : _tone = _Tone.ghost;

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final _Tone _tone;

  @override
  Widget build(BuildContext context) {
    final foreground = _tone == _Tone.ghost ? AppColors.ivory : AppColors.night;

    final decoration = switch (_tone) {
      _Tone.glow => BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mint, AppColors.glow, AppColors.emerald],
          stops: [0, 0.45, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withValues(alpha: 0.38),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      _Tone.gold => BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF0BC),
            Color(0xFFE2BC5C),
            Color(0xFFC99A2E),
            Color(0xFFA27A22),
          ],
          stops: [0, 0.35, 0.7, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.32),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      _Tone.ghost => BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.ivoryGhost.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.hairline),
      ),
    };

    final content = AnimatedSwitcher(
      duration: AppMotion.normal,
      switchInCurve: AppMotion.easeOut,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.85, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: loading
          ? SizedBox.square(
              key: const ValueKey('loading'),
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foreground,
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppText.button.copyWith(color: foreground)),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 18, color: foreground),
                ],
              ],
            ),
    );

    Widget body = Container(
      height: 56,
      width: expand ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      alignment: Alignment.center,
      decoration: decoration,
      child: content,
    );

    if (_tone != _Tone.ghost) {
      body = ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Sheen(
          color: Colors.white.withValues(
            alpha: _tone == _Tone.gold ? 0.38 : 0.32,
          ),
          child: body,
        ),
      );
      body = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: decoration.boxShadow,
        ),
        child: body,
      );
    }

    return Opacity(
      opacity: onTap == null && !loading ? 0.45 : 1,
      child: Pressable(
        onTap: loading ? null : onTap,
        scale: 0.965,
        child: body,
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    required this.icon,
    this.onTap,
    this.badge = false,
    this.size = 44,
    this.color = AppColors.ivory,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool badge;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.raised.withValues(alpha: 0.55),
          border: Border.all(color: AppColors.hairline.withValues(alpha: 0.8)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: size * 0.45, color: color),
            if (badge)
              Positioned(
                top: size * 0.24,
                right: size * 0.26,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.7),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
