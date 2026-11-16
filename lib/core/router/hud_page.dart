import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import 'edge_swipe.dart';

class HudPage<T> extends Page<T> {
  const HudPage({required this.child, super.key});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => _HudRoute<T>(this);
}

class _HudRoute<T> extends PageRoute<T> with EdgeSwipePop<T> {
  _HudRoute(HudPage<T> page) : super(settings: page);

  final _pageKey = GlobalKey();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 680);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 460);

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => (settings as HudPage<T>).child;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return EdgeSwipeBack(
      route: this,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => _HudTransition(
          value: animation.value,
          interactive: popGestureInProgress,
          reversing: animation.status == AnimationStatus.reverse,
          child: child!,
        ),
        child: KeyedSubtree(key: _pageKey, child: child),
      ),
    );
  }
}

class _HudTransition extends StatelessWidget {
  const _HudTransition({
    required this.value,
    required this.interactive,
    required this.reversing,
    required this.child,
  });

  final double value;
  final bool interactive;
  final bool reversing;
  final Widget child;

  static const _feather = 0.14;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    if (value >= 1) return child;

    final dim = ColoredBox(
      color: AppColors.night.withValues(alpha: 0.72 * value),
    );

    if (interactive || reversing) {
      final t = interactive ? value : AppMotion.easeInOut.transform(value);
      return Stack(
        children: [
          Positioned.fill(child: IgnorePointer(child: dim)),
          Transform.translate(
            offset: Offset(
              interactive ? (1 - t) * size.width : 0,
              interactive ? 0 : (1 - t) * 48,
            ),
            child: Opacity(opacity: interactive ? 1 : t, child: child),
          ),
        ],
      );
    }

    final t = AppMotion.emphasized.transform(value);
    final reveal = -_feather + t * (1 + _feather * 2);
    final scanY = reveal.clamp(0.0, 1.0) * size.height;
    final scanOpacity = (1 - const Interval(0.7, 1).transform(value));

    return Stack(
      children: [
        Positioned.fill(child: IgnorePointer(child: dim)),
        Transform.translate(
          offset: Offset(0, (1 - t) * 28),
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [Colors.white, Colors.white, Colors.transparent],
              stops: [
                0,
                reveal.clamp(0.0, 1.0),
                (reveal + _feather).clamp(0.0, 1.0),
              ],
            ).createShader(bounds),
            child: child,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: scanY - 1,
          child: IgnorePointer(
            child: Opacity(
              opacity: scanOpacity,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x002FE0A0),
                      AppColors.glow,
                      AppColors.mint,
                      AppColors.glow,
                      Color(0x002FE0A0),
                    ],
                    stops: [0, 0.2, 0.5, 0.8, 1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glow.withValues(alpha: 0.6),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
