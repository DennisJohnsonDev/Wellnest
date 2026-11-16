import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_typography.dart';

class HudSegmented extends StatelessWidget {
  const HudSegmented({
    required this.items,
    required this.index,
    required this.onChanged,
    super.key,
  });

  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.deep.withValues(alpha: 0.75),
        border: Border.all(color: AppColors.hairline.withValues(alpha: 0.8)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth / items.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 420),
                curve: AppMotion.snap,
                left: w * index,
                top: 0,
                bottom: 0,
                width: w,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [AppColors.mint, AppColors.glow],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.glow.withValues(alpha: 0.35),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (i == index) return;
                          HapticFeedback.selectionClick();
                          onChanged(i);
                        },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: AppMotion.normal,
                            style: AppText.label.copyWith(
                              fontSize: 13,
                              color: i == index
                                  ? AppColors.night
                                  : AppColors.ivoryMuted,
                            ),
                            child: Text(items[i]),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class HudChip extends StatelessWidget {
  const HudChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected
              ? AppColors.glow.withValues(alpha: 0.16)
              : AppColors.deep.withValues(alpha: 0.6),
          border: Border.all(
            color: selected
                ? AppColors.glow.withValues(alpha: 0.7)
                : AppColors.hairline.withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected ? AppColors.mint : AppColors.ivoryFaint,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppText.label.copyWith(
                fontSize: 13,
                color: selected ? AppColors.ivory : AppColors.ivoryMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HudSearchField extends StatelessWidget {
  const HudSearchField({
    required this.hint,
    required this.onChanged,
    super.key,
  });

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.deep.withValues(alpha: 0.7),
        border: Border.all(color: AppColors.hairline.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.ivoryFaint,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              style: AppText.label.copyWith(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: AppText.body.copyWith(color: AppColors.ivoryFaint),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
