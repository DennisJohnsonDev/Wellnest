import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MatrixBackdrop extends StatefulWidget {
  const MatrixBackdrop({
    this.focus = const Alignment(0, -0.75),
    this.intensity = 1,
    this.animate = true,
    super.key,
  });

  final Alignment focus;
  final double intensity;
  final bool animate;

  @override
  State<MatrixBackdrop> createState() => _MatrixBackdropState();
}

class _MatrixBackdropState extends State<MatrixBackdrop>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context) || !widget.animate;
    if (still) {
      _controller.stop();
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
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: widget.focus,
                radius: 1.3,
                colors: const [
                  Color(0xFF0B3226),
                  Color(0xFF061C15),
                  AppColors.night,
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          RepaintBoundary(
            child: CustomPaint(
              painter: _HexGridPainter(
                focus: widget.focus,
                intensity: widget.intensity,
              ),
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _AmbientPainter(
                  t: _controller.value,
                  intensity: widget.intensity,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HexGridPainter extends CustomPainter {
  _HexGridPainter({required this.focus, required this.intensity});

  final Alignment focus;
  final double intensity;

  static const _radius = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = focus.alongSize(size);
    final reach = size.longestSide * 0.85;
    final w = math.sqrt(3) * _radius;
    final h = _radius * 1.5;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    final node = Paint();
    final random = math.Random(42);

    for (var row = -1; row * h < size.height + _radius; row++) {
      for (var col = -1; col * w < size.width + w; col++) {
        final c = Offset(col * w + (row.isOdd ? w / 2 : 0), row * h);
        final d = (c - center).distance / reach;
        final fade = math.pow((1 - d).clamp(0.0, 1.0), 1.8).toDouble();
        if (fade < 0.02) continue;

        final path = Path();
        for (var i = 0; i < 6; i++) {
          final a = math.pi / 180 * (60 * i - 30);
          final p = c + Offset(math.cos(a), math.sin(a)) * (_radius - 1.5);
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        path.close();
        line.color = AppColors.glow.withValues(alpha: 0.075 * fade * intensity);
        canvas.drawPath(path, line);

        if (random.nextDouble() < 0.045) {
          final a = math.pi / 180 * (60 * random.nextInt(6) - 30);
          final p = c + Offset(math.cos(a), math.sin(a)) * (_radius - 1.5);
          final gold = random.nextDouble() < 0.25;
          node.color = (gold ? AppColors.gold : AppColors.glow).withValues(
            alpha: 0.55 * fade * intensity,
          );
          canvas.drawCircle(p, gold ? 1.4 : 1.1, node);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_HexGridPainter old) =>
      old.focus != focus || old.intensity != intensity;
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({required this.t, required this.intensity});

  final double t;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final a = t * math.pi * 2;

    void orb(Offset c, double r, Color color, double alpha) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = ui.Gradient.radial(c, r, [
            color.withValues(alpha: alpha * intensity),
            color.withValues(alpha: 0),
          ]),
      );
    }

    orb(
      Offset(
        size.width * (0.2 + 0.12 * math.sin(a)),
        size.height * (0.18 + 0.05 * math.cos(a)),
      ),
      size.width * 0.75,
      AppColors.emerald,
      0.16,
    );
    orb(
      Offset(
        size.width * (0.85 + 0.08 * math.cos(a * 2)),
        size.height * (0.62 + 0.06 * math.sin(a)),
      ),
      size.width * 0.6,
      AppColors.emeraldDeep,
      0.22,
    );
    orb(
      Offset(
        size.width * (0.5 + 0.2 * math.sin(a + 1.2)),
        size.height * (0.95 + 0.03 * math.cos(a)),
      ),
      size.width * 0.5,
      AppColors.gold,
      0.05,
    );

    final sweep = (t * 2) % 1;
    final y = -80 + sweep * (size.height + 160);
    final band = Rect.fromLTWH(0, y - 60, size.width, 120);
    canvas.drawRect(
      band,
      Paint()
        ..shader = ui.Gradient.linear(
          band.topCenter,
          band.bottomCenter,
          [
            AppColors.glow.withValues(alpha: 0),
            AppColors.glow.withValues(alpha: 0.035 * intensity),
            AppColors.glow.withValues(alpha: 0),
          ],
          const [0, 0.5, 1],
        ),
    );
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, y),
          Offset(size.width, y),
          [
            AppColors.glow.withValues(alpha: 0),
            AppColors.glow.withValues(alpha: 0.12 * intensity),
            AppColors.glow.withValues(alpha: 0),
          ],
          const [0, 0.5, 1],
        )
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(_AmbientPainter old) =>
      old.t != t || old.intensity != intensity;
}
