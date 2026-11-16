import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'ecg_line.dart';

enum CoverMotif { pulse, rings, lattice, cells, columns, helix, waves }

class CoverArt extends StatelessWidget {
  const CoverArt({
    required this.motif,
    required this.seed,
    this.accent = AppColors.glow,
    this.child,
    super.key,
  });

  final CoverMotif motif;
  final int seed;
  final Color accent;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _CoverPainter(motif: motif, seed: seed, accent: accent),
        child: child,
      ),
    );
  }
}

class _CoverPainter extends CustomPainter {
  _CoverPainter({
    required this.motif,
    required this.seed,
    required this.accent,
  });

  final CoverMotif motif;
  final int seed;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(seed);
    final rect = Offset.zero & size;
    final hue = r.nextDouble();

    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(rect.topLeft, rect.bottomRight, [
          Color.lerp(const Color(0xFF14523D), const Color(0xFF0F4536), hue)!,
          const Color(0xFF082219),
        ]),
    );
    canvas.drawCircle(
      Offset(size.width * (0.6 + 0.3 * r.nextDouble()), size.height * 0.2),
      size.width * 0.7,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width * 0.75, size.height * 0.2),
          size.width * 0.7,
          [accent.withValues(alpha: 0.28), accent.withValues(alpha: 0)],
        ),
    );

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accent.withValues(alpha: 0.55);
    final faint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.ivory.withValues(alpha: 0.12);
    final gold = Paint()..color = AppColors.gold;

    switch (motif) {
      case CoverMotif.pulse:
        for (var k = 0; k < 4; k++) {
          final y = size.height * (0.3 + k * 0.17);
          final path = Path();
          for (var i = 0; i <= 120; i++) {
            final x = i / 120 * size.width;
            final v = ecgWave(i / 120 * 1.6 + k * 0.27 + hue);
            final py = y - v * size.height * 0.22 * (k == 1 ? 1 : 0.45);
            i == 0 ? path.moveTo(x, py) : path.lineTo(x, py);
          }
          canvas.drawPath(path, k == 1 ? (line..strokeWidth = 2) : faint);
        }
      case CoverMotif.rings:
        final c = Offset(size.width * 0.72, size.height * 0.45);
        for (var i = 1; i <= 7; i++) {
          canvas.drawCircle(c, i * size.height * 0.11, i.isEven ? faint : line);
        }
        canvas.drawCircle(c, 4, gold);
      case CoverMotif.lattice:
        final s = size.height * 0.16;
        final nodes = <Offset>[];
        for (var y = -1; y < 8; y++) {
          for (var x = -1; x < 12; x++) {
            final p = Offset(
              size.width * 0.35 + x * s * 0.87 + (y.isOdd ? s * 0.43 : 0),
              y * s * 0.75,
            );
            if (p.dx < size.width * 0.3) continue;
            nodes.add(p);
          }
        }
        for (final a in nodes) {
          for (final b in nodes) {
            final d = (a - b).distance;
            if (d > 0 && d < s * 0.9 && a.dx < b.dx) {
              canvas.drawLine(a, b, faint);
            }
          }
        }
        for (final p in nodes) {
          if (r.nextDouble() < 0.25) {
            canvas.drawCircle(
              p,
              2.4,
              r.nextDouble() < 0.3 ? gold : (Paint()..color = accent),
            );
          }
        }
      case CoverMotif.cells:
        for (var i = 0; i < 9; i++) {
          final c = Offset(
            size.width * (0.35 + r.nextDouble() * 0.65),
            size.height * r.nextDouble(),
          );
          final rad = size.height * (0.06 + r.nextDouble() * 0.12);
          canvas.drawCircle(c, rad, i.isEven ? line : faint);
          for (var k = 0; k < 10; k++) {
            final a = k / 10 * math.pi * 2;
            canvas.drawLine(
              c + Offset(math.cos(a), math.sin(a)) * rad,
              c + Offset(math.cos(a), math.sin(a)) * rad * 1.25,
              faint,
            );
          }
        }
      case CoverMotif.columns:
        for (var i = 0; i < 9; i++) {
          final x = size.width * (0.42 + i * 0.07);
          final h =
              size.height * (0.3 + 0.5 * math.sin(i * 0.7 + hue * 4).abs());
          canvas.drawLine(
            Offset(x, size.height),
            Offset(x, size.height - h),
            i == 4 ? (line..strokeWidth = 2) : faint,
          );
        }
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(size.width * 0.7, size.height * 0.95),
            width: size.width * 0.7,
            height: size.height * 1.2,
          ),
          math.pi,
          math.pi,
          false,
          line..strokeWidth = 1.2,
        );
      case CoverMotif.helix:
        final cx = size.width * 0.7;
        for (var i = 0; i < 40; i++) {
          final t = i / 40;
          final y = t * size.height;
          final a = t * math.pi * 4 + hue * 6;
          final dx = math.sin(a) * size.width * 0.16;
          final p1 = Offset(cx + dx, y);
          final p2 = Offset(cx - dx, y);
          if (i % 2 == 0) canvas.drawLine(p1, p2, faint);
          canvas.drawCircle(p1, 2.2, Paint()..color = accent);
          canvas.drawCircle(
            p2,
            2.2,
            i % 5 == 0
                ? gold
                : (Paint()..color = AppColors.ivory.withValues(alpha: 0.5)),
          );
        }
      case CoverMotif.waves:
        for (var k = 0; k < 9; k++) {
          final path = Path();
          for (var i = 0; i <= 60; i++) {
            final x = i / 60 * size.width;
            final y =
                size.height * (0.15 + k * 0.1) +
                math.sin(i / 60 * math.pi * 2 + k * 0.5 + hue * 5) *
                    size.height *
                    0.05;
            i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
          }
          canvas.drawPath(path, k == 3 ? line : faint);
        }
    }

    for (var i = 0; i < 6; i++) {
      final p = Offset(
        r.nextDouble() * size.width,
        r.nextDouble() * size.height,
      );
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(r.nextDouble() * math.pi);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 3.5, height: 2.4),
        Paint()
          ..color = AppColors.goldLight.withValues(
            alpha: 0.5 + r.nextDouble() * 0.4,
          ),
      );
      canvas.restore();
    }

    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          [const Color(0x00061C15), const Color(0xCC061C15)],
          const [0.45, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(_CoverPainter old) =>
      old.motif != motif || old.seed != seed || old.accent != accent;
}
