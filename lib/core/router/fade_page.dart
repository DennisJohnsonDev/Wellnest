import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

class FadePage<T> extends Page<T> {
  const FadePage({
    required this.child,
    this.duration = const Duration(milliseconds: 620),
    super.key,
  });

  final Widget child;
  final Duration duration;

  @override
  Route<T> createRoute(BuildContext context) => _FadeRoute<T>(this);
}

class _FadeRoute<T> extends PageRoute<T> {
  _FadeRoute(FadePage<T> page) : super(settings: page);

  FadePage<T> get _page => settings as FadePage<T>;

  @override
  Duration get transitionDuration => _page.duration;

  @override
  Duration get reverseTransitionDuration => AppMotion.slow;

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
    return FadeTransition(
      opacity: animation.drive(CurveTween(curve: AppMotion.easeOut)),
      child: ScaleTransition(
        scale: animation.drive(
          Tween(
            begin: 1.04,
            end: 1.0,
          ).chain(CurveTween(curve: AppMotion.settle)),
        ),
        child: child,
      ),
    );
  }
}
