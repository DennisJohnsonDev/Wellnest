import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../../../../core/effects/foil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/hud_bits.dart';
import '../../../../core/widgets/wellnest_mark.dart';
import '../../../auth/data/practitioner.dart';
import '../../data/licence.dart';

class HoloLicenceCard extends StatefulWidget {
  const HoloLicenceCard({
    required this.licence,
    required this.practitioner,
    this.flipController,
    super.key,
  });

  final Licence licence;
  final Practitioner practitioner;
  final ValueNotifier<int>? flipController;

  @override
  State<HoloLicenceCard> createState() => _HoloLicenceCardState();
}

class _HoloLicenceCardState extends State<HoloLicenceCard>
    with TickerProviderStateMixin {
  static const _limit = 0.32;

  late final _idle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  late final _release = AnimationController.unbounded(vsync: this);
  late final _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );

  Offset _tilt = Offset.zero;
  Offset _releaseFrom = Offset.zero;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _release.addListener(() {
      setState(() => _tilt = _releaseFrom * (1 - _release.value));
    });
    widget.flipController?.addListener(_toggleFlip);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context)) _idle.repeat();
  }

  @override
  void dispose() {
    widget.flipController?.removeListener(_toggleFlip);
    _idle.dispose();
    _release.dispose();
    _flip.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    HapticFeedback.lightImpact();
    if (_flip.value < 0.5) {
      _flip.animateTo(1, curve: AppMotion.emphasized);
    } else {
      _flip.animateBack(0, curve: AppMotion.emphasized);
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    _dragging = true;
    _release.stop();
    setState(() {
      _tilt = Offset(
        (_tilt.dx - d.delta.dy * 0.006).clamp(-_limit, _limit),
        (_tilt.dy + d.delta.dx * 0.006).clamp(-_limit, _limit),
      );
    });
  }

  void _onPanEnd(DragEndDetails d) {
    _dragging = false;
    _releaseFrom = _tilt;
    _release.value = 0;
    _release.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 140, damping: 9),
        0,
        1,
        0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width / 1.586;
        return GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onTap: _toggleFlip,
          child: AnimatedBuilder(
            animation: Listenable.merge([_idle, _flip]),
            builder: (context, _) {
              final a = _idle.value * math.pi * 2;
              final idle = _dragging
                  ? Offset.zero
                  : Offset(math.cos(a) * 0.035, math.sin(a) * 0.06);
              final tilt = _tilt + idle;
              final flip = _flip.value * math.pi;
              final showBack = flip > math.pi / 2;

              return SizedBox(
                width: width,
                height: height,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0012)
                    ..rotateX(tilt.dx)
                    ..rotateY(tilt.dy + flip),
                  child: showBack
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: _CardShell(
                            tilt: tilt,
                            child: _Back(licence: widget.licence),
                          ),
                        )
                      : _CardShell(
                          tilt: tilt,
                          child: _Front(
                            licence: widget.licence,
                            practitioner: widget.practitioner,
                          ),
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.tilt, required this.child});

  final Offset tilt;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final light = Alignment(
      (tilt.dy * 3.2).clamp(-1.4, 1.4),
      (-tilt.dx * 3.2).clamp(-1.4, 1.4),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withValues(alpha: 0.2),
            blurRadius: 46,
            offset: Offset(tilt.dy * -40, 18 + tilt.dx * 40),
          ),
          BoxShadow(
            color: const Color(0xB3000000),
            blurRadius: 30,
            offset: Offset(tilt.dy * -30, 22 + tilt.dx * 30),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A6149),
                    Color(0xFF0D3527),
                    Color(0xFF06201A),
                  ],
                  stops: [0, 0.5, 1],
                ),
              ),
            ),
            const RepaintBoundary(
              child: CustomPaint(painter: _GuillochePainter()),
            ),
            CustomPaint(painter: _FleckPainter(tilt: tilt)),
            child,
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + light.x * 0.6, -1),
                    end: Alignment(1 + light.x * 0.6, 1),
                    colors: const [
                      Color(0x002FE0A0),
                      Color(0x1C2FE0A0),
                      Color(0x24F5DE95),
                      Color(0x1CFFF2C4),
                      Color(0x189FF5D2),
                      Color(0x002FE0A0),
                    ],
                    stops: [
                      0,
                      (0.25 + light.x * 0.2).clamp(0.0, 1.0),
                      (0.4 + light.x * 0.2).clamp(0.0, 1.0),
                      (0.5 + light.x * 0.2).clamp(0.0, 1.0),
                      (0.62 + light.x * 0.2).clamp(0.0, 1.0),
                      1,
                    ],
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: light,
                    radius: 0.9,
                    colors: const [Color(0x24FFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.glow.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Front extends StatelessWidget {
  const _Front({required this.licence, required this.practitioner});

  final Licence licence;
  final Practitioner practitioner;

  @override
  Widget build(BuildContext context) {
    final renewed = licence.isRenewed;
    return Stack(
      children: [
        const Positioned(
          right: -36,
          bottom: -42,
          child: Opacity(opacity: 0.07, child: WellnestMark(size: 210)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const WellnestLogo(size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'PRACTITIONER LICENCE',
                    style: AppText.hud.copyWith(
                      fontSize: 8.5,
                      color: AppColors.ivoryMuted,
                    ),
                  ),
                  const Spacer(),
                  GoldText(
                    licence.authorityShort,
                    style: AppText.title.copyWith(
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  HexAvatar(initials: practitioner.initials, size: 50),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          practitioner.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.titleSmall.copyWith(fontSize: 16.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${licence.category} · ${licence.specialty}',
                          style: AppText.bodySmall.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const _FoilSeal(),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Field('LICENCE NO.', licence.number),
                  const SizedBox(width: 18),
                  _Field(
                    'VALID UNTIL',
                    Formatters.hudDate(licence.expiresOn),
                    color: renewed ? AppColors.mint : AppColors.goldLight,
                  ),
                  const Spacer(),
                  _StatusDot(renewed: renewed),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value, {this.color = AppColors.ivory});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.hud.copyWith(
            fontSize: 7.5,
            color: AppColors.ivoryFaint,
          ),
        ),
        const SizedBox(height: 3),
        Text(value, style: AppText.data.copyWith(fontSize: 12, color: color)),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.renewed});

  final bool renewed;

  @override
  Widget build(BuildContext context) {
    final color = renewed ? AppColors.glow : AppColors.gold;
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color, blurRadius: 8)],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          renewed ? 'ACTIVE' : 'RENEW',
          style: AppText.hud.copyWith(fontSize: 8.5, color: color),
        ),
      ],
    );
  }
}

class _FoilSeal extends StatelessWidget {
  const _FoilSeal();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 42,
      child: GoldFoil(
        period: const Duration(milliseconds: 2800),
        child: CustomPaint(painter: _SealPainter()),
      ),
    );
  }
}

class _SealPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.gold;
    canvas.drawCircle(c, size.width / 2 - 1, paint);
    canvas.drawCircle(c, size.width / 2 - 5, paint..strokeWidth = 0.8);
    for (var i = 0; i < 24; i++) {
      final a = i / 24 * math.pi * 2;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * (size.width / 2 - 8),
        c + Offset(math.cos(a), math.sin(a)) * (size.width / 2 - 11),
        paint,
      );
    }
    final check = Path()
      ..moveTo(c.dx - 6, c.dy)
      ..lineTo(c.dx - 1.5, c.dy + 4.5)
      ..lineTo(c.dx + 6.5, c.dy - 4.5);
    canvas.drawPath(
      check,
      paint
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SealPainter old) => false;
}

class _Back extends StatelessWidget {
  const _Back({required this.licence});

  final Licence licence;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const SizedBox.square(
              dimension: 116,
              child: CustomPaint(painter: VerificationQrPainter()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SCAN TO VERIFY',
                  style: AppText.hud.copyWith(fontSize: 9),
                ),
                const SizedBox(height: 8),
                Text(
                  'Live credential check',
                  style: AppText.titleSmall.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  'Employers and facilities can confirm this licence instantly.',
                  style: AppText.bodySmall.copyWith(fontSize: 11.5),
                ),
                const SizedBox(height: 12),
                Text(
                  licence.number,
                  style: AppText.data.copyWith(
                    fontSize: 11,
                    color: AppColors.goldLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VerificationQrPainter extends CustomPainter {
  const VerificationQrPainter({this.color = AppColors.ink});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 25;
    final cell = size.width / n;
    final r = math.Random(2026);
    final paint = Paint()..color = color;

    bool finder(int x, int y) {
      for (final (ox, oy) in [(0, 0), (n - 7, 0), (0, n - 7)]) {
        final dx = x - ox;
        final dy = y - oy;
        if (dx >= 0 && dx < 7 && dy >= 0 && dy < 7) return true;
      }
      return false;
    }

    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (finder(x, y)) continue;
        final mid = (x - n / 2).abs() < 3.5 && (y - n / 2).abs() < 3.5;
        if (mid) continue;
        if (r.nextDouble() > 0.52) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x * cell, y * cell, cell * 0.92, cell * 0.92),
              Radius.circular(cell * 0.25),
            ),
            paint,
          );
        }
      }
    }

    for (final (ox, oy) in [(0, 0), (n - 7, 0), (0, n - 7)]) {
      final outer = Rect.fromLTWH(ox * cell, oy * cell, cell * 7, cell * 7);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          outer.deflate(cell * 0.5),
          Radius.circular(cell * 1.6),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = cell
          ..color = color,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(outer.deflate(cell * 2), Radius.circular(cell)),
        paint,
      );
    }

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.drawCircle(
      Offset.zero,
      cell * 3.2,
      Paint()..color = AppColors.paper,
    );
    final s = cell * 5.4 / MarkPainterArt.size;
    canvas.scale(s);
    canvas.translate(-MarkPainterArt.size / 2, -MarkPainterArt.size / 2);
    canvas.drawPath(
      MarkPainterArt.path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 34
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.emeraldDeep,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(VerificationQrPainter old) => old.color != color;
}

abstract final class MarkPainterArt {
  static const size = MarkPainter.artboard;
  static Path get path => MarkPainter.line;
}

class _GuillochePainter extends CustomPainter {
  const _GuillochePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.78, size.height * 0.42);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (var k = 0; k < 18; k++) {
      final base = size.height * (0.18 + k * 0.045);
      final path = Path();
      for (var i = 0; i <= 180; i++) {
        final a = i / 180 * math.pi * 2;
        final rr = base + math.sin(a * 9 + k * 0.4) * 5;
        final p = c + Offset(math.cos(a) * rr * 1.25, math.sin(a) * rr);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      paint.color = (k.isEven ? AppColors.ivory : AppColors.glow).withValues(
        alpha: 0.05,
      );
      canvas.drawPath(path, paint);
    }
    for (var y = 0.0; y < size.height; y += 3.2) {
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width * 0.5; x += 6) {
        path.lineTo(x, y + math.sin(x / 14 + y / 9) * 1.2);
      }
      canvas.drawPath(
        path,
        paint..color = AppColors.ivory.withValues(alpha: 0.025),
      );
    }
  }

  @override
  bool shouldRepaint(_GuillochePainter old) => false;
}

class _FleckPainter extends CustomPainter {
  _FleckPainter({required this.tilt});

  final Offset tilt;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(88);
    for (var i = 0; i < 26; i++) {
      final p = Offset(
        r.nextDouble() * size.width,
        r.nextDouble() * size.height,
      );
      final phase = r.nextDouble() * math.pi * 2;
      final glint = (math.sin(tilt.dx * 9 + tilt.dy * 11 + phase) + 1) / 2;
      final s = 1.2 + r.nextDouble() * 2.4;
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(r.nextDouble() * math.pi);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: s * 1.6, height: s),
        Paint()
          ..color = Color.lerp(
            AppColors.goldDeep,
            AppColors.goldLight,
            glint,
          )!.withValues(alpha: 0.35 + 0.55 * glint),
      );
      canvas.restore();
      if (glint > 0.92) {
        canvas.drawCircle(
          p,
          s * 2.2,
          Paint()
            ..blendMode = ui.BlendMode.plus
            ..color = AppColors.goldLight.withValues(alpha: (glint - 0.92) * 4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FleckPainter old) => old.tilt != tilt;
}
