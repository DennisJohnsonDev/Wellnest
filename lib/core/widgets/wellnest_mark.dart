import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class WellnestLogo extends StatelessWidget {
  const WellnestLogo({this.size = 40, super.key});

  final double size;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/brand/logo.svg', width: size, height: size);
}

class Wordmark extends StatelessWidget {
  const Wordmark({this.size = 22, this.color = AppColors.ivory, super.key});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    'Wellnest',
    style: AppText.title.copyWith(
      fontSize: size,
      color: color,
      letterSpacing: -size * 0.02,
      fontWeight: FontWeight.w500,
    ),
  );
}

class WellnestMark extends StatelessWidget {
  const WellnestMark({
    this.size = 120,
    this.trace = 1,
    this.flake = 1,
    this.pulse,
    this.glow = 0,
    super.key,
  });

  final double size;
  final double trace;
  final double flake;
  final double? pulse;
  final double glow;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size.square(size),
      painter: MarkPainter(
        trace: trace,
        flake: flake,
        pulse: pulse,
        glow: glow,
      ),
    ),
  );
}

class MarkPainter extends CustomPainter {
  MarkPainter({this.trace = 1, this.flake = 1, this.pulse, this.glow = 0});

  final double trace;
  final double flake;
  final double? pulse;
  final double glow;

  static const artboard = 512.0;
  static const stroke = 30.0;
  static const flakeCenter = Offset(257, 90);

  static final Path line = Path()
    ..moveTo(86.26, 164)
    ..lineTo(171.13, 330)
    ..lineTo(256, 218)
    ..lineTo(340.87, 330)
    ..lineTo(425.74, 164)
    ..lineTo(425.74, 326)
    ..quadraticBezierTo(425.74, 360, 396.3, 377)
    ..lineTo(285.44, 441)
    ..quadraticBezierTo(256, 458, 226.56, 441)
    ..lineTo(115.7, 377)
    ..quadraticBezierTo(86.26, 360, 86.26, 326)
    ..close();

  static final ui.PathMetric _metric = line.computeMetrics().first;

  static final Path _leafLight = Path()
    ..moveTo(253, 52)
    ..lineTo(264, 128)
    ..lineTo(227, 96)
    ..close();

  static final Path _leafDeep = Path()
    ..moveTo(253, 52)
    ..lineTo(287, 88)
    ..lineTo(264, 128)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / artboard);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = ui.Gradient.linear(
        const Offset(86, 164),
        const Offset(426, 458),
        const [Color(0xFFFBF7EC), Color(0xFFE4DCC6)],
      );

    final drawn = trace >= 1
        ? line
        : _metric.extractPath(0, _metric.length * trace.clamp(0, 1));

    if (glow > 0) {
      canvas.drawPath(
        drawn,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke * 1.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.glow.withValues(alpha: 0.45 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 26 * glow + 4),
      );
    }

    if (trace > 0) canvas.drawPath(drawn, strokePaint);

    final pulse = this.pulse;
    if (pulse != null && pulse > 0 && pulse < 1) _paintPulse(canvas, pulse);

    if (flake > 0) _paintFlake(canvas);

    canvas.restore();
  }

  void _paintPulse(Canvas canvas, double pulse) {
    final length = _metric.length;
    final head = length * pulse;
    final tail = length * 0.22;
    final start = (head - tail).clamp(0.0, length);
    final segment = _metric.extractPath(start, head);
    final from = _metric.getTangentForOffset(start)!.position;
    final to = _metric.getTangentForOffset(head)!.position;
    final fade =
        (pulse < 0.08 ? pulse / 0.08 : 1.0) *
        (pulse > 0.92 ? (1 - pulse) / 0.08 : 1.0);

    canvas.drawPath(
      segment,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22)
        ..shader = ui.Gradient.linear(from, to, [
          AppColors.glow.withValues(alpha: 0),
          AppColors.glow.withValues(alpha: 0.85 * fade),
        ]),
    );
    canvas.drawPath(
      segment,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 0.55
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = ui.Gradient.linear(from, to, [
          AppColors.mint.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.95 * fade),
        ]),
    );
  }

  void _paintFlake(Canvas canvas) {
    final t = flake.clamp(0.0, 1.0);
    canvas.save();
    canvas.translate(flakeCenter.dx, flakeCenter.dy);
    canvas.scale(t);
    canvas.translate(-flakeCenter.dx, -flakeCenter.dy);

    if (glow > 0) {
      canvas.drawCircle(
        flakeCenter,
        46,
        Paint()
          ..color = AppColors.gold.withValues(alpha: 0.5 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
      );
    }

    canvas.drawPath(
      _leafLight,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(227, 52),
          const Offset(264, 128),
          const [Color(0xFFFFF0BC), Color(0xFFD9B048)],
        ),
    );
    canvas.drawPath(
      _leafDeep,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(253, 52),
          const Offset(287, 128),
          const [Color(0xFFC99A2E), Color(0xFF8A6516)],
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(MarkPainter old) =>
      old.trace != trace ||
      old.flake != flake ||
      old.pulse != pulse ||
      old.glow != glow;
}
