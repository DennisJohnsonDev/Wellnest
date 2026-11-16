import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

mixin EdgeSwipePop<T> on PageRoute<T> {
  void startPopGesture() => navigator!.didStartUserGesture();

  void updatePopGesture(double delta) => controller!.value -= delta;

  void endPopGesture(double velocity) {
    final controller = this.controller!;
    final pops = velocity.abs() >= 1 ? velocity > 0 : controller.value < 0.5;

    if (pops) {
      navigator!.pop();
      if (controller.isAnimating) {
        controller.animateBack(
          0,
          duration: reverseTransitionDuration * controller.value,
          curve: AppMotion.easeOut,
        );
      }
    } else {
      controller.animateTo(
        1,
        duration: transitionDuration * (1 - controller.value),
        curve: AppMotion.easeOut,
      );
    }

    if (!controller.isAnimating) return navigator!.didStopUserGesture();
    late final AnimationStatusListener onSettled;
    onSettled = (_) {
      navigator?.didStopUserGesture();
      controller.removeStatusListener(onSettled);
    };
    controller.addStatusListener(onSettled);
  }
}

class EdgeSwipeBack extends StatefulWidget {
  const EdgeSwipeBack({required this.route, required this.child, super.key});

  final EdgeSwipePop<dynamic> route;
  final Widget child;

  @override
  State<EdgeSwipeBack> createState() => _EdgeSwipeBackState();
}

class _EdgeSwipeBackState extends State<EdgeSwipeBack> {
  static const _edgeWidth = 22.0;

  bool _dragging = false;

  void _start(DragStartDetails details) {
    _dragging = widget.route.popGestureEnabled;
    if (_dragging) widget.route.startPopGesture();
  }

  void _update(DragUpdateDetails details) {
    if (!_dragging) return;
    widget.route.updatePopGesture(details.primaryDelta! / context.size!.width);
  }

  void _end(double velocity) {
    if (!_dragging) return;
    _dragging = false;
    widget.route.endPopGesture(velocity / context.size!.width);
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform != TargetPlatform.iOS) return widget.child;

    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: _edgeWidth + MediaQuery.paddingOf(context).left,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _start,
            onHorizontalDragUpdate: _update,
            onHorizontalDragEnd: (details) =>
                _end(details.velocity.pixelsPerSecond.dx),
            onHorizontalDragCancel: () => _end(0),
          ),
        ),
      ],
    );
  }
}
