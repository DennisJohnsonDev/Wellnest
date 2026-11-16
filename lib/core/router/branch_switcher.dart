import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

class BranchSwitcher extends StatefulWidget {
  const BranchSwitcher({
    required this.index,
    required this.children,
    super.key,
  });

  final int index;
  final List<Widget> children;

  @override
  State<BranchSwitcher> createState() => _BranchSwitcherState();
}

class _BranchSwitcherState extends State<BranchSwitcher>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    value: 1,
  );

  late int _previous = widget.index;

  @override
  void didUpdateWidget(BranchSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _previous = oldWidget.index;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = AppMotion.settle.transform(_controller.value);
        final animating = _controller.isAnimating;
        final forward = widget.index > _previous;

        return Stack(
          fit: StackFit.expand,
          children: [
            for (var i = 0; i < widget.children.length; i++)
              _branch(i, t, animating, forward),
          ],
        );
      },
    );
  }

  Widget _branch(int i, double t, bool animating, bool forward) {
    final current = i == widget.index;
    final leaving = animating && i == _previous && !current;
    final visible = current || leaving;
    final shift = forward ? 1.0 : -1.0;

    var opacity = 1.0;
    var dx = 0.0;
    var scale = 1.0;
    if (current && animating) {
      opacity = const Interval(0.15, 1).transform(t);
      dx = (1 - t) * 24 * shift;
      scale = 0.985 + 0.015 * t;
    } else if (leaving) {
      opacity = 1 - const Interval(0, 0.5).transform(t);
      dx = -t * 16 * shift;
      scale = 1 - 0.01 * t;
    }

    return Offstage(
      offstage: !visible,
      child: TickerMode(
        enabled: visible,
        child: IgnorePointer(
          ignoring: !current,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(dx, 0),
              child: Transform.scale(scale: scale, child: widget.children[i]),
            ),
          ),
        ),
      ),
    );
  }
}
