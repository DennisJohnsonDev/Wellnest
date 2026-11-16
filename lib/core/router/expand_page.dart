import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import 'edge_swipe.dart';

class ExpandPage<T> extends Page<T> {
  const ExpandPage({
    required this.origin,
    required this.from,
    required this.child,
    this.radius = AppRadius.lg,
    super.key,
  });

  final Rect origin;
  final Widget from;
  final Widget child;
  final double radius;

  @override
  Route<T> createRoute(BuildContext context) => _ExpandRoute<T>(this);
}

class _ExpandRoute<T> extends PageRoute<T> with EdgeSwipePop<T> {
  _ExpandRoute(ExpandPage<T> page) : super(settings: page);

  ExpandPage<T> get _page => settings as ExpandPage<T>;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 560);

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
  ) => _page.child;

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
        builder: (context, child) =>
            _ExpandTransition(route: this, child: child!),
        child: child,
      ),
    );
  }
}

class _ExpandTransition extends StatelessWidget {
  const _ExpandTransition({required this.route, required this.child});

  final _ExpandRoute<dynamic> route;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final page = route._page;
    final origin = page.origin;

    final value = route.animation!.value;
    final t = route.popGestureInProgress
        ? value
        : AppMotion.emphasized.transform(value);
    final settled = value == 1 && !route.popGestureInProgress;

    final rect = Rect.lerp(origin, Offset.zero & size, t)!;
    final radius = BorderRadius.circular(lerpDouble(page.radius, 0, t)!);
    final lift = math.sin(math.pi * t);
    final fromOpacity = 1 - const Interval(0, 0.3).transform(t);
    final pageOpacity = const Interval(0.15, 0.55).transform(t);

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(
              color: AppColors.night.withValues(alpha: 0.6 * value),
            ),
          ),
        ),
        Positioned.fromRect(
          rect: rect,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: lift > 0
                  ? [
                      BoxShadow(
                        color: AppColors.glow.withValues(alpha: 0.18 * lift),
                        blurRadius: 40 * lift,
                        offset: Offset(0, 14 * lift),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: radius,
              clipBehavior: settled ? Clip.none : Clip.antiAlias,
              child: ColoredBox(
                color: Color.lerp(
                  AppColors.surface,
                  AppColors.night,
                  pageOpacity,
                )!,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _ScaledToWidth(
                        size: size,
                        child: Opacity(opacity: pageOpacity, child: child),
                      ),
                    ),
                    if (fromOpacity > 0)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ExcludeSemantics(
                            child: _ScaledToWidth(
                              size: origin.size,
                              child: Opacity(
                                opacity: fromOpacity,
                                child: page.from,
                              ),
                            ),
                          ),
                        ),
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

class _ScaledToWidth extends StatelessWidget {
  const _ScaledToWidth({required this.size, required this.child});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      alignment: Alignment.topCenter,
      child: SizedBox.fromSize(size: size, child: child),
    );
  }
}
