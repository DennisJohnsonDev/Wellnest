import 'package:flutter/widgets.dart';

import '../theme/app_motion.dart';

class Entrance extends StatefulWidget {
  const Entrance({
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    this.rise = 22,
    super.key,
  });

  final Widget child;
  final int index;
  final Duration delay;
  final double rise;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> {
  static const _duration = Duration(milliseconds: 620);
  static const _step = Duration(milliseconds: 60);
  static const _maxStagger = 8;
  static const _shrink = 0.03;

  late final bool _animates =
      !MediaQuery.disableAnimationsOf(context) &&
      EntranceScope._isFresh(context);

  @override
  Widget build(BuildContext context) {
    final lead = widget.delay + _step * widget.index.clamp(0, _maxStagger);
    final total = _duration + lead;
    final start = lead.inMilliseconds / total.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _animates ? 0 : 1, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: AppMotion.settle),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * widget.rise),
          child: Transform.scale(scale: 1 - (1 - t) * _shrink, child: child),
        ),
      ),
      child: widget.child,
    );
  }
}

class EntranceScope extends StatefulWidget {
  const EntranceScope({required this.child, super.key});

  final Widget child;

  static const _window = Duration(milliseconds: 800);

  static bool _isFresh(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<_EntranceScopeData>();
    return scope == null ||
        DateTime.now().difference(scope.mountedAt) < _window;
  }

  @override
  State<EntranceScope> createState() => _EntranceScopeState();
}

class _EntranceScopeState extends State<EntranceScope> {
  final _mountedAt = DateTime.now();

  @override
  Widget build(BuildContext context) =>
      _EntranceScopeData(mountedAt: _mountedAt, child: widget.child);
}

class _EntranceScopeData extends InheritedWidget {
  const _EntranceScopeData({required this.mountedAt, required super.child});

  final DateTime mountedAt;

  @override
  bool updateShouldNotify(_EntranceScopeData oldWidget) => false;
}
