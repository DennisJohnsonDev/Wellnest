import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'pressable.dart';

class HudTag extends StatelessWidget {
  const HudTag(
    this.label, {
    this.color = AppColors.glow,
    this.icon,
    this.mono = false,
    this.filled = false,
    super.key,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool mono;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final style = mono
        ? AppText.hud.copyWith(
            color: filled ? AppColors.night : color,
            fontSize: 9.5,
          )
        : AppText.bodySmall.copyWith(
            color: filled ? AppColors.night : color,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
            height: 1.1,
          );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: filled ? 0 : 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: filled ? AppColors.night : color),
            const SizedBox(width: 4),
          ],
          Text(mono ? label.toUpperCase() : label, style: style),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    this.eyebrow,
    this.action,
    this.onAction,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(eyebrow!.toUpperCase(), style: AppText.hud),
                  const SizedBox(height: 6),
                ],
                Text(title, style: AppText.title.copyWith(fontSize: 19)),
              ],
            ),
          ),
          if (action != null)
            Pressable(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 2),
                child: Row(
                  children: [
                    Text(
                      action!,
                      style: AppText.label.copyWith(
                        color: AppColors.glow,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: AppColors.glow,
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

class HudProgressBar extends StatelessWidget {
  const HudProgressBar({
    required this.value,
    this.height = 4,
    this.color = AppColors.glow,
    super.key,
  });

  final double value;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1100),
      curve: AppMotion.settle,
      builder: (context, v, _) => LayoutBuilder(
        builder: (context, constraints) => Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.ivoryGhost,
            borderRadius: BorderRadius.circular(height),
          ),
          alignment: Alignment.centerLeft,
          child: Container(
            width: constraints.maxWidth * v,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height),
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.6), color],
              ),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HexAvatar extends StatelessWidget {
  const HexAvatar({required this.initials, this.size = 44, super.key});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _HexPainter(),
        child: Center(
          child: Text(
            initials,
            style: AppText.titleSmall.copyWith(
              fontSize: size * 0.32,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    Path hex(double radius) {
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final a = math.pi / 180 * (60 * i - 90);
        final p = c + Offset(math.cos(a), math.sin(a)) * radius;
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      return path..close();
    }

    canvas.drawPath(
      hex(r - 1),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16503B), Color(0xFF0A2A1F)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      hex(r - 1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0BC), Color(0xFFC99A2E), Color(0xFF7A5B16)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_HexPainter old) => false;
}

class HudDivider extends StatelessWidget {
  const HudDivider({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0x002FE0A0), Color(0x402FE0A0), Color(0x002FE0A0)],
      ),
    ),
  );
}
