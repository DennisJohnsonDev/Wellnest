import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class HudPanel extends StatelessWidget {
  const HudPanel({
    required this.child,
    this.label,
    this.trailing,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.lg,
    this.accent = AppColors.glow,
    this.glow = false,
    this.brackets = true,
    super.key,
  });

  final Widget child;
  final String? label;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color accent;
  final bool glow;
  final bool brackets;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: AppColors.panel,
        border: Border.all(color: AppColors.hairline.withValues(alpha: 0.75)),
        boxShadow: [
          if (glow)
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 36,
              offset: const Offset(0, 12),
            ),
          const BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: brackets
            ? _CornerPainter(radius: radius, color: accent)
            : null,
        child: Padding(
          padding: padding,
          child: label == null
              ? child
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HudLabel(label!, color: accent, trailing: trailing),
                    const SizedBox(height: AppSpacing.md),
                    child,
                  ],
                ),
        ),
      ),
    );
  }
}

class HudLabel extends StatelessWidget {
  const HudLabel(
    this.text, {
    this.color = AppColors.glow,
    this.trailing,
    super.key,
  });

  final String text;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: AppText.hud.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(radius, size.shortestSide / 2);
    const arm = 10.0;
    const inset = 0.5;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.55);

    final w = size.width - inset;
    final h = size.height - inset;

    void corner(Offset center, double start, Offset a, Offset b) {
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: r - inset),
          start,
          math.pi / 2,
          false,
        )
        ..lineTo(b.dx, b.dy);
      canvas.drawPath(path, paint);
    }

    corner(
      Offset(r, r),
      math.pi,
      Offset(inset, r + arm),
      Offset(r + arm, inset),
    );
    corner(
      Offset(size.width - r, r),
      -math.pi / 2,
      Offset(size.width - r - arm, inset),
      Offset(w, r + arm),
    );
    corner(
      Offset(size.width - r, size.height - r),
      0,
      Offset(w, size.height - r - arm),
      Offset(size.width - r - arm, h),
    );
    corner(
      Offset(r, size.height - r),
      math.pi / 2,
      Offset(r + arm, h),
      Offset(inset, size.height - r - arm),
    );
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.radius != radius || old.color != color;
}
