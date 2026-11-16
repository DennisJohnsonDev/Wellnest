import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/effects/gold_flakes.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/hud_bits.dart';
import '../../../core/widgets/hud_panel.dart';
import '../../../core/widgets/hud_scaffold.dart';
import '../../../core/widgets/wellnest_mark.dart';
import '../data/licence.dart';

class RenewalCompleteScreen extends ConsumerStatefulWidget {
  const RenewalCompleteScreen({super.key});

  @override
  ConsumerState<RenewalCompleteScreen> createState() =>
      _RenewalCompleteScreenState();
}

class _RenewalCompleteScreenState extends ConsumerState<RenewalCompleteScreen> {
  final _flakes = GoldFlakeController();
  final _sealKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 380));
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      final box = _sealKey.currentContext?.findRenderObject() as RenderBox?;
      final center = box == null
          ? MediaQuery.sizeOf(context).center(Offset.zero)
          : box.localToGlobal(box.size.center(Offset.zero));
      _flakes
        ..burst(center, count: 90, power: 1.1)
        ..shower(count: 70);
    });
  }

  @override
  void dispose() {
    _flakes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final licence = ref.watch(licenceProvider);
    final padding = MediaQuery.paddingOf(context);
    final paid = renewalFees.fold(0, (sum, f) => sum + f.amount);

    return HudScaffold(
      flakes: 18,
      focus: const Alignment(0, -0.35),
      body: Stack(
        children: [
          EntranceScope(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                padding.top + 40,
                AppSpacing.gutter,
                padding.bottom + 24,
              ),
              children: [
                Center(child: _Seal(key: _sealKey)),
                const SizedBox(height: 30),
                Entrance(
                  delay: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      Text(
                        'RENEWAL COMPLETE',
                        style: AppText.hud.copyWith(color: AppColors.gold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Licence renewed',
                        style: AppText.display,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You’re cleared to practise until ${Formatters.date(licence.expiresOn)}. Your digital licence has been updated.',
                        style: AppText.body,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Entrance(
                  index: 1,
                  delay: const Duration(milliseconds: 500),
                  child: HudPanel(
                    label: 'Receipt',
                    accent: AppColors.gold,
                    trailing: const HudTag(
                      'Paid',
                      icon: Icons.check_rounded,
                      color: AppColors.gold,
                    ),
                    child: Column(
                      children: [
                        _ReceiptRow('Reference', licence.reference ?? '—'),
                        _ReceiptRow('Amount', Formatters.aed(paid)),
                        _ReceiptRow(
                          'Valid from',
                          Formatters.date(licence.validFrom),
                        ),
                        _ReceiptRow(
                          'Valid until',
                          Formatters.date(licence.expiresOn),
                          last: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Entrance(
                  index: 2,
                  delay: const Duration(milliseconds: 500),
                  child: HudButton.gold(
                    label: 'View digital licence',
                    icon: Icons.arrow_forward_rounded,
                    onTap: () => context.go(AppRoutes.licence),
                  ),
                ),
                const SizedBox(height: 12),
                Entrance(
                  index: 3,
                  delay: const Duration(milliseconds: 500),
                  child: HudButton.ghost(
                    label: 'Back to home',
                    onTap: () => context.go(AppRoutes.home),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: GoldFlakeField(density: 0, controller: _flakes),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(this.label, this.value, {this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: AppText.hud.copyWith(
              fontSize: 9,
              color: AppColors.ivoryFaint,
            ),
          ),
          const Spacer(),
          Text(value, style: AppText.data),
        ],
      ),
    );
  }
}

class _Seal extends StatefulWidget {
  const _Seal({super.key});

  @override
  State<_Seal> createState() => _SealState();
}

class _SealState extends State<_Seal> with TickerProviderStateMixin {
  late final _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _enter.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_enter, _spin]),
      builder: (context, _) {
        final t = _enter.value;
        final scale = AppMotion.overshoot.transform(
          const Interval(0, 0.6).transform(t),
        );
        final ring = AppMotion.settle.transform(
          const Interval(0.15, 1).transform(t),
        );
        final check = AppMotion.overshoot.transform(
          const Interval(0.55, 1).transform(t),
        );
        return SizedBox.square(
          dimension: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _spin.value * math.pi * 2,
                child: CustomPaint(
                  size: const Size.square(200),
                  painter: _SealRingPainter(progress: ring),
                ),
              ),
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF16503B), Color(0xFF071F17)],
                    ),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.7),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.35),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  child: const Center(child: WellnestMark(size: 74, glow: 0.4)),
                ),
              ),
              Positioned(
                right: 34,
                bottom: 34,
                child: Transform.scale(
                  scale: check,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.glow,
                      border: Border.all(color: AppColors.night, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glow.withValues(alpha: 0.6),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 22,
                      color: AppColors.night,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SealRingPainter extends CustomPainter {
  _SealRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 6;
    final count = 72;
    final lit = (count * progress).round();
    for (var i = 0; i < lit; i++) {
      final a = i / count * math.pi * 2 - math.pi / 2;
      final major = i % 6 == 0;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * (r - (major ? 10 : 6)),
        c + Offset(math.cos(a), math.sin(a)) * r,
        Paint()
          ..strokeWidth = major ? 2 : 1.2
          ..strokeCap = StrokeCap.round
          ..color = (major ? AppColors.goldLight : AppColors.gold).withValues(
            alpha: 0.85,
          ),
      );
    }
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - 18),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.gold.withValues(alpha: 0.4),
    );
  }

  @override
  bool shouldRepaint(_SealRingPainter old) => old.progress != progress;
}
