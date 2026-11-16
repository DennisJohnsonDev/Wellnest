import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class NavDestination {
  const NavDestination(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class GlassNavBar extends StatefulWidget {
  const GlassNavBar({
    required this.index,
    required this.destinations,
    required this.onSelect,
    super.key,
  });

  final int index;
  final List<NavDestination> destinations;
  final ValueChanged<int> onSelect;

  @override
  State<GlassNavBar> createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<GlassNavBar>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
    value: 1,
  );
  late int _from = widget.index;

  @override
  void didUpdateWidget(GlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _from = oldWidget.index;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(int i) {
    HapticFeedback.selectionClick();
    widget.onSelect(i);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, math.max(14, bottom - 8)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 30,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xD90F3A2B), Color(0xE6061C15)],
                ),
                border: Border.all(
                  color: AppColors.hairline.withValues(alpha: 0.9),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth =
                      constraints.maxWidth / widget.destinations.length;
                  return Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) => _indicator(itemWidth),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < widget.destinations.length; i++)
                            Expanded(
                              child: _NavItem(
                                destination: widget.destinations[i],
                                active: i == widget.index,
                                onTap: () => _select(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _indicator(double itemWidth) {
    final t = _controller.value;
    final forward = widget.index >= _from;
    final lead = Curves.easeOutCubic.transform(t);
    final trail = Curves.easeInOutCubic.transform(t);
    final from = _from.toDouble();
    final to = widget.index.toDouble();
    final leftT = forward ? trail : lead;
    final rightT = forward ? lead : trail;
    const inset = 7.0;
    final left = (from + (to - from) * leftT) * itemWidth + inset;
    final right = (from + (to - from) * rightT + 1) * itemWidth - inset;

    return Positioned(
      left: left,
      width: math.max(0, right - left),
      top: 7,
      bottom: 7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: RadialGradient(
            center: const Alignment(0, -1.2),
            radius: 1.4,
            colors: [
              AppColors.glow.withValues(alpha: 0.30),
              AppColors.glow.withValues(alpha: 0.06),
            ],
          ),
          border: Border.all(color: AppColors.glow.withValues(alpha: 0.35)),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: const Offset(0, -3.5),
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldLight, AppColors.gold],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.9),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.active,
    required this.onTap,
  });

  final NavDestination destination;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: destination.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: active ? 1.08 : 1,
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutBack,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  active ? destination.activeIcon : destination.icon,
                  key: ValueKey(active),
                  size: 23,
                  color: active ? AppColors.mint : AppColors.ivoryFaint,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: AppText.bodySmall.copyWith(
                fontSize: 10.5,
                height: 1,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: active ? AppColors.ivory : AppColors.ivoryFaint,
              ),
              child: Text(destination.label),
            ),
          ],
        ),
      ),
    );
  }
}
