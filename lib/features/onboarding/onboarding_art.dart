import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/wellnest_mark.dart';

class FloatingChip extends StatelessWidget {
  const FloatingChip({
    required this.icon,
    required this.label,
    this.color = AppColors.glow,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 7, 12, 7),
      decoration: BoxDecoration(
        color: const Color(0xE60A2A1F),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 18),
          const BoxShadow(
            color: Color(0x80000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.16),
            ),
            child: Icon(icon, size: 13, color: color),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: AppText.bodySmall.copyWith(
              color: AppColors.ivory,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bob extends StatelessWidget {
  const _Bob({
    required this.t,
    required this.phase,
    required this.parallax,
    required this.child,
  });

  final double t;
  final double phase;
  final double parallax;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final y = math.sin((t + phase) * math.pi * 2) * 6;
    return Transform.translate(offset: Offset(parallax, y), child: child);
  }
}

class LicenceArt extends StatelessWidget {
  const LicenceArt({required this.t, required this.offset, super.key});

  final double t;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final a = t * math.pi * 2;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _OrbitPainter(t: t)),
        ),
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0014)
            ..rotateX(0.22 + math.cos(a) * 0.05)
            ..rotateY(math.sin(a) * 0.22 + offset * 0.9)
            ..rotateZ(-0.06),
          child: _MiniLicence(scan: (t * 1.5) % 1),
        ),
        Positioned(
          top: 18,
          right: 22,
          child: _Bob(
            t: t,
            phase: 0.2,
            parallax: offset * -70,
            child: const FloatingChip(
              icon: Icons.verified_rounded,
              label: 'Verified in 0.8s',
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 18,
          child: _Bob(
            t: t,
            phase: 0.6,
            parallax: offset * -120,
            child: const FloatingChip(
              icon: Icons.schedule_rounded,
              label: 'Renewal reminder · 60 days',
              color: AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniLicence extends StatelessWidget {
  const _MiniLicence({required this.scan});

  final double scan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 244,
      height: 154,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF15553F), Color(0xFF0A2A1F), Color(0xFF07211A)],
        ),
        border: Border.all(color: AppColors.glow.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withValues(alpha: 0.22),
            blurRadius: 40,
          ),
          const BoxShadow(
            color: Color(0xAA000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const WellnestMark(size: 22),
                      const SizedBox(width: 6),
                      Text(
                        'PRACTITIONER LICENCE',
                        style: AppText.hud.copyWith(
                          fontSize: 7.5,
                          color: AppColors.ivoryMuted,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 26,
                        height: 19,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: AppColors.goldFoil,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Dr. Mariam Al Suwaidi',
                    style: AppText.titleSmall.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'DHA-P-0417238',
                    style: AppText.data.copyWith(
                      fontSize: 10,
                      color: AppColors.glow,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _bar(54),
                      const SizedBox(width: 6),
                      _bar(34),
                      const Spacer(),
                      const _QrGlyph(size: 30),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: scan * 170 - 10,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x002FE0A0),
                      AppColors.mint,
                      Color(0x002FE0A0),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glow.withValues(alpha: 0.7),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(double w) => Container(
    width: w,
    height: 5,
    decoration: BoxDecoration(
      color: AppColors.ivoryGhost,
      borderRadius: BorderRadius.circular(3),
    ),
  );
}

class _QrGlyph extends StatelessWidget {
  const _QrGlyph({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _QrPainter());
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const n = 9;
    final cell = size.width / n;
    final r = math.Random(5);
    final paint = Paint()..color = AppColors.ivory.withValues(alpha: 0.85);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final corner = (x < 3 && y < 3) || (x > 5 && y < 3) || (x < 3 && y > 5);
        final on = corner || r.nextDouble() > 0.5;
        if (on) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell - 0.6, cell - 0.6),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => false;
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var i = 0; i < 3; i++) {
      final rx = size.width * (0.36 + i * 0.07);
      final ry = rx * 0.32;
      final rect = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(-0.18 + i * 0.12);
      canvas.translate(-c.dx, -c.dy);
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = AppColors.glow.withValues(alpha: 0.16 - i * 0.04),
      );
      final a = (t * (i.isEven ? 1 : -1) + i * 0.33) * math.pi * 2;
      final p = c + Offset(math.cos(a) * rx, math.sin(a) * ry);
      final gold = i == 1;
      canvas.drawCircle(
        p,
        gold ? 3.2 : 2.4,
        Paint()
          ..color = gold ? AppColors.gold : AppColors.mint
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.t != t;
}

class CmeArt extends StatelessWidget {
  const CmeArt({
    required this.t,
    required this.offset,
    required this.fill,
    super.key,
  });

  final double t;
  final double offset;
  final double fill;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Transform.translate(
          offset: Offset(offset * -40, 0),
          child: SizedBox.square(
            dimension: 220,
            child: CustomPaint(
              painter: _TripleRingPainter(fill: fill, t: t),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (51.5 * fill).toStringAsFixed(1),
                      style: AppText.metric.copyWith(fontSize: 38),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CME CREDITS',
                      style: AppText.hud.copyWith(color: AppColors.ivoryMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 6,
          left: 16,
          child: _Bob(
            t: t,
            phase: 0.1,
            parallax: offset * -110,
            child: const FloatingChip(
              icon: Icons.monitor_heart_outlined,
              label: 'Cardiology · 8 credits',
            ),
          ),
        ),
        Positioned(
          top: 120,
          right: 4,
          child: _Bob(
            t: t,
            phase: 0.45,
            parallax: offset * -160,
            child: const FloatingChip(
              icon: Icons.balance_outlined,
              label: 'Ethics · 3',
              color: AppColors.mint,
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 40,
          child: _Bob(
            t: t,
            phase: 0.75,
            parallax: offset * -80,
            child: const FloatingChip(
              icon: Icons.workspace_premium_rounded,
              label: 'Certificate earned',
              color: AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }
}

class _TripleRingPainter extends CustomPainter {
  _TripleRingPainter({required this.fill, required this.t});

  final double fill;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const rings = [
      (1.0, AppColors.glow, 0.0),
      (0.72, AppColors.mint, 0.08),
      (0.48, AppColors.gold, 0.16),
    ];
    for (var i = 0; i < rings.length; i++) {
      final (value, color, delay) = rings[i];
      final r = size.width / 2 - 10 - i * 22.0;
      final v = ((fill - delay) / (1 - delay)).clamp(0.0, 1.0) * value;
      final rect = Rect.fromCircle(center: c, radius: r);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 13
          ..color = color.withValues(alpha: 0.1),
      );
      if (v <= 0) continue;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * v,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * v,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 13
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }
    final a = t * math.pi * 2;
    final orbit = size.width / 2 + 6;
    canvas.drawCircle(
      c + Offset(math.cos(a), math.sin(a)) * orbit,
      2.6,
      Paint()..color = AppColors.goldLight,
    );
  }

  @override
  bool shouldRepaint(_TripleRingPainter old) => old.fill != fill || old.t != t;
}

class ResearchArt extends StatelessWidget {
  const ResearchArt({required this.t, required this.offset, super.key});

  final double t;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final a = t * math.pi * 2;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Transform.translate(
          offset: Offset(offset * -30 - 46, 10),
          child: Transform.rotate(
            angle: -0.16 + math.sin(a) * 0.015,
            child: const _Paper(opacity: 0.55),
          ),
        ),
        Transform.translate(
          offset: Offset(offset * -60 + 46, 4),
          child: Transform.rotate(
            angle: 0.14 - math.sin(a) * 0.015,
            child: const _Paper(opacity: 0.75),
          ),
        ),
        Transform.translate(
          offset: Offset(offset * -100, math.sin(a) * 4 - 8),
          child: const _Paper(featured: true),
        ),
        Positioned(
          bottom: 4,
          right: 20,
          child: _Bob(
            t: t,
            phase: 0.3,
            parallax: offset * -150,
            child: const FloatingChip(
              icon: Icons.bolt_rounded,
              label: 'Breaking · 2h ago',
              color: AppColors.gold,
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 18,
          child: _Bob(
            t: t,
            phase: 0.7,
            parallax: offset * -90,
            child: const FloatingChip(
              icon: Icons.auto_stories_rounded,
              label: '12 new papers',
            ),
          ),
        ),
      ],
    );
  }
}

class _Paper extends StatelessWidget {
  const _Paper({this.featured = false, this.opacity = 1});

  final bool featured;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    Widget line(double w, {double h = 5, Color color = AppColors.paperLine}) =>
        Container(
          width: w,
          height: h,
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        );

    return Opacity(
      opacity: opacity,
      child: Container(
        width: 172,
        height: 222,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GULF HEART JOURNAL',
                  style: AppText.hud.copyWith(
                    fontSize: 7,
                    color: AppColors.emeraldDeep,
                  ),
                ),
                const SizedBox(height: 10),
                if (featured)
                  Text(
                    'Calcium scoring sharpens risk prediction',
                    style: AppText.serifTitle.copyWith(
                      fontSize: 15,
                      height: 1.2,
                    ),
                  )
                else ...[
                  line(130, h: 8, color: AppColors.inkFaint),
                  line(96, h: 8, color: AppColors.inkFaint),
                ],
                const SizedBox(height: 10),
                line(140),
                line(128),
                line(136),
                const Spacer(),
                if (featured)
                  SizedBox(
                    height: 46,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final v in const [0.18, 0.4, 0.66, 1.0])
                          Expanded(
                            child: Container(
                              height: 46 * v,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                gradient: const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    AppColors.emeraldDeep,
                                    AppColors.emerald,
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            if (featured)
              Positioned(
                top: -16,
                right: 0,
                child: CustomPaint(
                  size: const Size(18, 30),
                  painter: _RibbonPainter(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - 6)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()..shader = AppColors.goldFoil.createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_RibbonPainter old) => false;
}
