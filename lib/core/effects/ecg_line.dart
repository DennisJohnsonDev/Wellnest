import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class EcgLine extends StatefulWidget {
  const EcgLine({
    this.height = 44,
    this.color = AppColors.glow,
    this.period = const Duration(milliseconds: 2600),
    this.beats = 2.4,
    super.key,
  });

  final double height;
  final Color color;
  final Duration period;
  final double beats;

  @override
  State<EcgLine> createState() => _EcgLineState();
}

class _EcgLineState extends State<EcgLine> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 0.82;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _EcgPainter(
              head: _controller.value,
              color: widget.color,
              beats: widget.beats,
            ),
          ),
        ),
      ),
    );
  }
}

double ecgWave(double x) {
  final p = x - x.floorToDouble();
  double bump(double c, double w, double h) =>
      h * math.exp(-math.pow((p - c) / w, 2));
  return bump(0.18, 0.035, 0.12) -
      bump(0.34, 0.012, 0.16) +
      bump(0.37, 0.014, 1.0) -
      bump(0.405, 0.014, 0.32) +
      bump(0.62, 0.06, 0.24);
}

class _EcgPainter extends CustomPainter {
  _EcgPainter({required this.head, required this.color, required this.beats});

  final double head;
  final Color color;
  final double beats;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height * 0.62;
    final amp = size.height * 0.56;
    const steps = 220;
    final headX = head * size.width;
    final trail = size.width * 0.72;

    final path = Path();
    for (var i = 0; i <= steps; i++) {
      final x = i / steps * size.width;
      final y = mid - ecgWave(i / steps * beats) * amp;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.12),
    );

    final start = headX - trail;
    final shader = ui.Gradient.linear(Offset(start, 0), Offset(headX, 0), [
      color.withValues(alpha: 0),
      color.withValues(alpha: 0.95),
    ]);

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(math.max(0, start), 0, headX, size.height));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..shader = shader,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round
        ..shader = shader,
    );
    canvas.restore();

    if (start < 0) {
      canvas.save();
      canvas.clipRect(
        Rect.fromLTRB(size.width + start, 0, size.width, size.height),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..shader = ui.Gradient.linear(
            Offset(size.width + start, 0),
            Offset(size.width, 0),
            [
              color.withValues(alpha: 0),
              color.withValues(alpha: 0.95 * (-start / trail) * 0.4),
            ],
          ),
      );
      canvas.restore();
    }

    final hy = mid - ecgWave(head * beats) * amp;
    canvas.drawCircle(
      Offset(headX, hy),
      6,
      Paint()
        ..color = color.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(Offset(headX, hy), 2.2, Paint()..color = AppColors.mint);
  }

  @override
  bool shouldRepaint(_EcgPainter old) => old.head != head || old.color != color;
}
