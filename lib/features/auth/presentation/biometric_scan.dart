import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_typography.dart';

Future<bool> showBiometricScan(BuildContext context) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 420),
    pageBuilder: (context, animation, secondary) => const _BiometricScan(),
    transitionBuilder: (context, animation, secondary, child) {
      final t = AppMotion.easeOut.transform(animation.value);
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18 * t, sigmaY: 18 * t),
        child: ColoredBox(
          color: AppColors.night.withValues(alpha: 0.72 * t),
          child: Opacity(
            opacity: t,
            child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
          ),
        ),
      );
    },
  );
  return result ?? false;
}

class _BiometricScan extends StatefulWidget {
  const _BiometricScan();

  @override
  State<_BiometricScan> createState() => _BiometricScanState();
}

class _BiometricScanState extends State<_BiometricScan>
    with TickerProviderStateMixin {
  late final _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2100),
  );
  late final _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);
  late final _done = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  int _ticks = 0;

  @override
  void initState() {
    super.initState();
    _scan.addListener(_haptics);
    _run();
  }

  void _haptics() {
    final step = (_scan.value * 6).floor();
    if (step > _ticks) {
      _ticks = step;
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _run() async {
    await Future<void>.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;
    await _scan.forward();
    if (!mounted) return;
    _sweep.stop();
    HapticFeedback.mediumImpact();
    await _done.forward();
    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _scan.dispose();
    _sweep.dispose();
    _done.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_scan, _sweep, _done]),
          builder: (context, _) {
            final done = AppMotion.overshoot.transform(_done.value);
            final status = _done.value > 0
                ? 'Identity verified'
                : _scan.value > 0
                ? 'Scanning…'
                : 'Hold steady';
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: 250,
                  child: CustomPaint(
                    painter: _ScannerPainter(
                      progress: AppMotion.easeInOut.transform(_scan.value),
                      sweep: _sweep.value,
                      done: _done.value,
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: done,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.glow,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.glow.withValues(alpha: 0.6),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 36,
                            color: AppColors.night,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                AnimatedSwitcher(
                  duration: AppMotion.normal,
                  child: Text(
                    status,
                    key: ValueKey(status),
                    style: AppText.title,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _done.value > 0
                      ? 'WELCOME BACK, DR. MARIAM'
                      : 'BIOMETRIC  ·  ${(_scan.value * 100).round().toString().padLeft(3, '0')}%',
                  style: AppText.hud.copyWith(
                    color: _done.value > 0 ? AppColors.gold : AppColors.glow,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScannerPainter extends CustomPainter {
  _ScannerPainter({
    required this.progress,
    required this.sweep,
    required this.done,
  });

  final double progress;
  final double sweep;
  final double done;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final settle = AppMotion.snap.transform(math.min(1, progress * 3));
    final half = 104 - 14 * settle;
    final frame = Rect.fromCenter(center: c, width: half * 2, height: half * 2);
    final color = Color.lerp(AppColors.glow, AppColors.gold, done)!;

    final bracket = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color;
    const arm = 30.0;
    const r = 18.0;
    for (final (corner, dx, dy) in [
      (frame.topLeft, 1.0, 1.0),
      (frame.topRight, -1.0, 1.0),
      (frame.bottomRight, -1.0, -1.0),
      (frame.bottomLeft, 1.0, -1.0),
    ]) {
      final path = Path()
        ..moveTo(corner.dx, corner.dy + dy * arm)
        ..lineTo(corner.dx, corner.dy + dy * r)
        ..quadraticBezierTo(corner.dx, corner.dy, corner.dx + dx * r, corner.dy)
        ..lineTo(corner.dx + dx * arm, corner.dy);
      canvas.drawPath(path, bracket);
    }

    final face = Rect.fromCenter(
      center: c.translate(0, 4),
      width: half * 1.15,
      height: half * 1.45,
    );
    final scanY = face.top + face.height * sweep;
    final dot = Paint();
    const rows = 13;
    const cols = 11;
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final p = Offset(
          face.left + face.width * (x + 0.5) / cols,
          face.top + face.height * (y + 0.5) / rows,
        );
        final nx = (p.dx - face.center.dx) / (face.width / 2);
        final ny = (p.dy - face.center.dy) / (face.height / 2);
        if (nx * nx + ny * ny > 1) continue;
        final near = (1 - ((p.dy - scanY).abs() / 26)).clamp(0.0, 1.0);
        final lit = (progress * rows * 1.1 - y).clamp(0.0, 1.0);
        dot.color = color.withValues(
          alpha: (0.14 + 0.35 * lit + 0.5 * near) * (1 - done),
        );
        canvas.drawCircle(p, 1.4 + near * 1.2, dot);
      }
    }

    if (done < 1) {
      canvas.drawOval(
        face,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color.withValues(alpha: 0.35 * (1 - done)),
      );
      final line = Rect.fromLTWH(face.left - 10, scanY - 1, face.width + 20, 2);
      canvas.drawRect(
        line,
        Paint()
          ..shader = LinearGradient(
            colors: [
              color.withValues(alpha: 0),
              AppColors.mint.withValues(alpha: 1 - done),
              color.withValues(alpha: 0),
            ],
          ).createShader(line)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }

    final ring = Rect.fromCircle(center: c, radius: size.width / 2 - 4);
    canvas.drawArc(
      ring,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.ivoryGhost,
    );
    canvas.drawArc(
      ring,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_ScannerPainter old) =>
      old.progress != progress || old.sweep != sweep || old.done != done;
}
