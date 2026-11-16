import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/effects/foil.dart';
import '../../../core/effects/gold_flakes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/hud_scaffold.dart';
import '../../../core/widgets/wellnest_mark.dart';
import '../../auth/data/practitioner.dart';
import '../data/cme_providers.dart';
import '../data/course.dart';

class CertificateScreen extends ConsumerStatefulWidget {
  const CertificateScreen({required this.courseId, super.key});

  final String courseId;

  @override
  ConsumerState<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends ConsumerState<CertificateScreen>
    with SingleTickerProviderStateMixin {
  late final _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );
  final _flakes = GoldFlakeController();
  final _sealKey = GlobalKey();
  bool _stamped = false;

  @override
  void initState() {
    super.initState();
    _intro
      ..addListener(() {
        if (!_stamped && _intro.value >= 0.72) {
          _stamped = true;
          HapticFeedback.heavyImpact();
          final box = _sealKey.currentContext?.findRenderObject() as RenderBox?;
          if (box != null) {
            _flakes.burst(
              box.localToGlobal(box.size.center(Offset.zero)),
              count: 54,
              power: 0.7,
            );
          }
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    _flakes.dispose();
    super.dispose();
  }

  void _claim(Course course) {
    HapticFeedback.mediumImpact();
    ref.read(certificatesProvider.notifier).claim(course);
    _flakes.shower(count: 50);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '+${Formatters.credits(course.credits)} CME credits added to your licence record',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(courseProvider(widget.courseId));
    final practitioner = ref.watch(practitionerProvider);
    final claimedAt = ref.watch(certificatesProvider)[course.id];
    final padding = MediaQuery.paddingOf(context);

    return HudScaffold(
      flakes: 14,
      focus: const Alignment(0, -0.2),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              padding.top + 8,
              AppSpacing.gutter,
              padding.bottom + 24,
            ),
            children: [
              Row(
                children: [
                  GlassIconButton(
                    icon: Icons.close_rounded,
                    onTap: () => context.pop(),
                  ),
                  const Spacer(),
                  const Text('CERTIFICATE', style: AppText.hud),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 22),
              AnimatedBuilder(
                animation: _intro,
                builder: (context, child) {
                  final t = AppMotion.settle.transform(
                    const Interval(0, 0.55).transform(_intro.value),
                  );
                  return Opacity(
                    opacity: t,
                    child: Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..translateByDouble(0, (1 - t) * 120, 0, 1)
                        ..rotateX((1 - t) * 0.7),
                      child: child,
                    ),
                  );
                },
                child: _Certificate(
                  course: course,
                  name: practitioner.name,
                  date: claimedAt ?? DateTime.now(),
                  seal: AnimatedBuilder(
                    key: _sealKey,
                    animation: _intro,
                    builder: (context, _) {
                      final t = const Interval(
                        0.55,
                        0.75,
                      ).transform(_intro.value);
                      final land = Curves.easeInCubic.transform(t);
                      final settle = AppMotion.overshoot.transform(
                        const Interval(0.72, 1).transform(_intro.value),
                      );
                      final scale = t < 1
                          ? 2.4 - 1.4 * land
                          : 1 + 0.08 * (1 - settle);
                      return Opacity(
                        opacity: t == 0 ? 0 : 1,
                        child: Transform.rotate(
                          angle: (1 - land) * -0.6,
                          child: Transform.scale(
                            scale: scale,
                            child: const _GoldSeal(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 26),
              AnimatedBuilder(
                animation: _intro,
                builder: (context, child) => Opacity(
                  opacity: const Interval(0.75, 1).transform(_intro.value),
                  child: child,
                ),
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: AppMotion.normal,
                      child: claimedAt == null
                          ? HudButton.gold(
                              key: const ValueKey('claim'),
                              label: 'Add to licence record',
                              icon: Icons.add_task_rounded,
                              onTap: () => _claim(course),
                            )
                          : HudButton.glow(
                              key: const ValueKey('claimed'),
                              label: 'Added to licence record',
                              icon: Icons.check_rounded,
                              onTap: () => context.pop(),
                            ),
                    ),
                    const SizedBox(height: 12),
                    HudButton.ghost(
                      label: 'Share certificate',
                      icon: Icons.ios_share_rounded,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Certificate link copied'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: GoldFlakeField(density: 0, controller: _flakes),
          ),
        ],
      ),
    );
  }
}

class _Certificate extends StatelessWidget {
  const _Certificate({
    required this.course,
    required this.name,
    required this.date,
    required this.seal,
  });

  final Course course;
  final String name;
  final DateTime date;
  final Widget seal;

  @override
  Widget build(BuildContext context) {
    final id = 'WN-CME-${date.year}-${(course.seed % 90000 + 10000)}';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.18),
            blurRadius: 50,
          ),
          const BoxShadow(
            color: Color(0xB3000000),
            blurRadius: 40,
            offset: Offset(0, 24),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: CustomPaint(
        painter: _BorderPainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 28, 26, 22),
          child: Column(
            children: [
              const _InkMark(),
              const SizedBox(height: 14),
              Text(
                'CERTIFICATE OF COMPLETION',
                style: AppText.hud.copyWith(
                  color: AppColors.emeraldDeep,
                  fontSize: 10,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'This certifies that',
                style: AppText.serifBody.copyWith(
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                textAlign: TextAlign.center,
                style: AppText.serifTitle.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 6),
              Container(
                width: 160,
                height: 1,
                color: AppColors.gold.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 12),
              Text(
                'has successfully completed',
                style: AppText.serifBody.copyWith(
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                course.title,
                textAlign: TextAlign.center,
                style: AppText.serifTitle.copyWith(fontSize: 19, height: 1.25),
              ),
              const SizedBox(height: 10),
              Text(
                '${Formatters.credits(course.credits)} CME credits  ·  ${course.provider}',
                textAlign: TextAlign.center,
                style: AppText.bodySmall.copyWith(
                  color: AppColors.inkMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accreditation Board',
                          style: AppText.serifBody.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                            color: AppColors.emeraldDeep,
                          ),
                        ),
                        Container(
                          width: 110,
                          height: 1,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          color: AppColors.inkFaint,
                        ),
                        Text(
                          Formatters.date(date).toUpperCase(),
                          style: AppText.hud.copyWith(
                            fontSize: 8.5,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          id,
                          style: AppText.hud.copyWith(
                            fontSize: 8.5,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox.square(dimension: 92, child: Center(child: seal)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InkMark extends StatelessWidget {
  const _InkMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 44,
      child: CustomPaint(painter: _InkMarkPainter()),
    );
  }
}

class _InkMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / MarkPainter.artboard);
    canvas.drawPath(
      MarkPainter.line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 30
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.emeraldDeep,
    );
    canvas.drawPath(
      Path()
        ..moveTo(253, 52)
        ..lineTo(287, 88)
        ..lineTo(264, 128)
        ..lineTo(227, 96)
        ..close(),
      Paint()..color = AppColors.gold,
    );
  }

  @override
  bool shouldRepaint(_InkMarkPainter old) => false;
}

class _BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = AppColors.goldFoil.createShader(Offset.zero & size),
    );
    canvas.drawRRect(
      outer.deflate(5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = AppColors.gold.withValues(alpha: 0.6),
    );
    final c = Offset(size.width / 2, size.height * 0.46);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = AppColors.emeraldDeep.withValues(alpha: 0.05);
    for (var k = 0; k < 14; k++) {
      final path = Path();
      final base = 40.0 + k * 9;
      for (var i = 0; i <= 160; i++) {
        final a = i / 160 * math.pi * 2;
        final r = base + math.sin(a * 12 + k) * 4;
        final p = c + Offset(math.cos(a) * r * 1.3, math.sin(a) * r);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BorderPainter old) => false;
}

class _GoldSeal extends StatelessWidget {
  const _GoldSeal();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size.square(84), painter: _SealBasePainter()),
          GoldFoil(
            period: const Duration(milliseconds: 3000),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 22,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 2),
                Text(
                  'ACCREDITED',
                  style: AppText.hud.copyWith(
                    fontSize: 6.5,
                    letterSpacing: 1.2,
                    color: AppColors.gold,
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

class _SealBasePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final path = Path();
    const points = 28;
    for (var i = 0; i <= points * 2; i++) {
      final a = i / (points * 2) * math.pi * 2;
      final rr = i.isEven ? r : r - 4;
      final p = c + Offset(math.cos(a), math.sin(a)) * rr;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawCircle(
      c.translate(0, 3),
      r - 2,
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      path,
      Paint()..shader = AppColors.goldFoil.createShader(Offset.zero & size),
    );
    canvas.drawCircle(c, r - 10, Paint()..color = const Color(0xFF0B3A2B));
    canvas.drawCircle(
      c,
      r - 13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AppColors.gold.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(_SealBasePainter old) => false;
}
