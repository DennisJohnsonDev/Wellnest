import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

class ProgressRing extends StatefulWidget {
  const ProgressRing({
    required this.value,
    this.size = 132,
    this.stroke = 9,
    this.colors = const [AppColors.emerald, AppColors.glow, AppColors.mint],
    this.child,
    this.ticks = true,
    this.orbit = true,
    this.delay = Duration.zero,
    super.key,
  });

  final double value;
  final double size;
  final double stroke;
  final List<Color> colors;
  final Widget? child;
  final bool ticks;
  final bool orbit;
  final Duration delay;

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with TickerProviderStateMixin {
  late final _fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );
  late Animation<double> _value = _tween(0, widget.value);

  Animation<double> _tween(double from, double to) => Tween(
    begin: from,
    end: to,
  ).animate(CurvedAnimation(parent: _fill, curve: AppMotion.settle));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _fill.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still) {
      _fill.value = 1;
      _spin.stop();
    } else if (widget.orbit && !_spin.isAnimating) {
      _spin.repeat();
    }
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = _tween(_value.value, widget.value);
      _fill.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fill.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_fill, _spin]),
              builder: (context, _) => CustomPaint(
                size: Size.square(widget.size),
                painter: _RingPainter(
                  value: _value.value,
                  spin: _spin.value,
                  stroke: widget.stroke,
                  colors: widget.colors,
                  ticks: widget.ticks,
                  orbit: widget.orbit,
                ),
              ),
            ),
          ),
          ?widget.child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.spin,
    required this.stroke,
    required this.colors,
    required this.ticks,
    required this.orbit,
  });

  final double value;
  final double spin;
  final double stroke;
  final List<Color> colors;
  final bool ticks;
  final bool orbit;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final outer = size.width / 2;
    final r = outer - (ticks ? 14 : 2) - stroke / 2;
    const start = -math.pi / 2;
    final sweep = math.pi * 2 * value.clamp(0.0, 1.0);

    if (orbit) {
      final orbitPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.ivoryGhost;
      final rr = outer - 1;
      for (var i = 0; i < 3; i++) {
        final a = spin * math.pi * 2 + i * math.pi * 2 / 3;
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: rr),
          a,
          math.pi * 0.42,
          false,
          orbitPaint,
        );
      }
      final dot =
          c +
          Offset(math.cos(spin * math.pi * 2), math.sin(spin * math.pi * 2)) *
              rr;
      canvas.drawCircle(dot, 2, Paint()..color = AppColors.gold);
    }

    if (ticks) {
      final tickPaint = Paint()..strokeCap = StrokeCap.round;
      const count = 60;
      for (var i = 0; i < count; i++) {
        final t = i / count;
        final a = start + t * math.pi * 2;
        final lit = t <= value;
        final major = i % 5 == 0;
        final r1 = outer - 6;
        final r2 = r1 - (major ? 5 : 3);
        tickPaint
          ..strokeWidth = major ? 1.4 : 1
          ..color = lit
              ? colors.last.withValues(alpha: major ? 0.9 : 0.55)
              : AppColors.ivoryGhost;
        canvas.drawLine(
          c + Offset(math.cos(a), math.sin(a)) * r1,
          c + Offset(math.cos(a), math.sin(a)) * r2,
          tickPaint,
        );
      }
    }

    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0x14F6F1E4),
    );

    if (sweep <= 0.001) return;

    final shader = ui.Gradient.sweep(
      c,
      colors,
      [for (var i = 0; i < colors.length; i++) i / (colors.length - 1)],
      TileMode.clamp,
      start,
      start + math.max(sweep, 0.01),
    );

    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 1.8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..color = colors.last.withValues(alpha: 0.28),
    );
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );

    final head =
        c + Offset(math.cos(start + sweep), math.sin(start + sweep)) * r;
    canvas.drawCircle(
      head,
      stroke * 0.9,
      Paint()
        ..color = colors.last.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(head, stroke * 0.32, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.spin != spin || old.colors != colors;
}

class CountUp extends StatelessWidget {
  const CountUp({
    required this.value,
    required this.style,
    this.decimals = 0,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1400),
    super.key,
  });

  final double value;
  final TextStyle style;
  final int decimals;
  final String prefix;
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : duration,
      curve: AppMotion.settle,
      builder: (context, v, _) =>
          Text('$prefix${v.toStringAsFixed(decimals)}$suffix', style: style),
    );
  }
}
