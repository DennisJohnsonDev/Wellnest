import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/effects/foil.dart';
import '../../core/effects/gold_flakes.dart';
import '../../core/effects/matrix_backdrop.dart';
import '../../core/effects/matrix_rain.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/wellnest_mark.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const markSize = 155.0;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 4600);

  late final _controller = AnimationController(vsync: this, duration: _total);
  final _flakes = GoldFlakeController();
  bool _burst = false;
  bool _left = false;

  double _at(double start, double end, [Curve curve = Curves.linear]) {
    final ms = _controller.value * _total.inMilliseconds;
    return curve.transform(((ms - start) / (end - start)).clamp(0.0, 1.0));
  }

  @override
  void initState() {
    super.initState();
    _controller
      ..addListener(_onTick)
      ..forward();
  }

  void _onTick() {
    final ms = _controller.value * _total.inMilliseconds;
    if (!_burst && ms >= 1150) {
      _burst = true;
      HapticFeedback.lightImpact();
      final size = MediaQuery.sizeOf(context);
      final flake = _flakeOrigin(size);
      _flakes
        ..burst(flake, count: 72, power: 0.85)
        ..shower(count: 90);
    }
    if (!_left && _controller.isCompleted) {
      _left = true;
      context.go(AppRoutes.onboarding);
    }
  }

  Offset _flakeOrigin(Size size) {
    const scale = SplashScreen.markSize / 512;
    final markTop = size.height / 2 - SplashScreen.markSize / 2;
    return Offset(size.width / 2 + 1.5 * scale, markTop + 90 * scale);
  }

  @override
  void dispose() {
    _controller.dispose();
    _flakes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_controller.value > 0.45 && !_left) _controller.value = 1;
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => _build(context),
        ),
      ),
    );
  }

  Widget _build(BuildContext context) {
    final reveal = _at(250, 1900, Curves.easeOutCubic);
    final pulse = _at(250, 1350, Curves.easeInOutSine);
    final glow = _at(300, 1150, Curves.easeOut) * (1 - _at(1400, 2600) * 0.55);
    final flare =
        _at(1100, 1350, Curves.easeOut) - _at(1350, 1800, Curves.easeIn);
    final rise = _at(1450, 2350, Curves.easeInOutCubicEmphasized);
    final exit = _at(4150, 4600, Curves.easeInCubic);
    final loader = _at(2300, 4050, Curves.easeInOutCubic);

    return Opacity(
      opacity: 1 - exit,
      child: Transform.scale(
        scale: 1 + exit * 0.06,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => RadialGradient(
                radius: 0.15 + reveal * 1.4,
                colors: const [Colors.white, Colors.white, Colors.transparent],
                stops: const [0, 0.7, 1],
              ).createShader(bounds),
              child: const MatrixBackdrop(focus: Alignment.center),
            ),
            Opacity(
              opacity: 0.22 * _at(600, 2200),
              child: const MatrixRain(spacing: 22),
            ),
            GoldFlakeField(
              density: 34,
              controller: _flakes,
              seed: 19,
              opacity: _at(900, 2000),
            ),
            _Emblem(pulse: pulse, glow: glow, flare: flare, rise: rise),
            _Titles(
              words: _at(1700, 2600),
              tagline: _at(2350, 3300),
              rise: rise,
            ),
            _Loader(progress: loader, visible: _at(2200, 2600)),
          ],
        ),
      ),
    );
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem({
    required this.pulse,
    required this.glow,
    required this.flare,
    required this.rise,
  });

  final double pulse;
  final double glow;
  final double flare;
  final double rise;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: Offset(0, -86 * rise),
        child: Transform.scale(
          scale: 1 - 0.18 * rise,
          child: SizedBox.square(
            dimension: SplashScreen.markSize,
            child: CustomPaint(
              painter: MarkPainter(
                pulse: pulse > 0 && pulse < 1 ? pulse : null,
                glow: glow,
                flake: 1 + 0.35 * flare,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Titles extends StatelessWidget {
  const _Titles({
    required this.words,
    required this.tagline,
    required this.rise,
  });

  final double words;
  final double tagline;
  final double rise;

  static const _word = 'Wellnest';
  static const _tag = 'LICENSING  ·  CME  ·  RESEARCH';

  @override
  Widget build(BuildContext context) {
    final letters = <Widget>[];
    for (var i = 0; i < _word.length; i++) {
      final t = Curves.easeOutCubic.transform(
        ((words * 1.6) - i * 0.08).clamp(0.0, 1.0),
      );
      letters.add(
        Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 18),
            child: Text(
              _word[i],
              style: AppText.display.copyWith(
                fontSize: 44,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.6 + (1 - t) * 8,
              ),
            ),
          ),
        ),
      );
    }

    final chars = (_tag.length * tagline).floor();

    return Center(
      child: Transform.translate(
        offset: Offset(0, 46 + (1 - rise) * 40),
        child: Opacity(
          opacity: rise,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: letters),
              const SizedBox(height: 14),
              GoldFoil(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: _tag.substring(0, chars)),
                      TextSpan(
                        text: _tag.substring(chars),
                        style: const TextStyle(color: Colors.transparent),
                      ),
                    ],
                  ),
                  style: AppText.hud.copyWith(
                    color: AppColors.gold,
                    fontSize: 11,
                    letterSpacing: 2.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader({required this.progress, required this.visible});

  final double progress;
  final double visible;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final label = progress < 0.45
        ? 'SECURING SESSION'
        : progress < 0.9
        ? 'SYNCING CREDENTIALS'
        : 'READY';
    return Positioned(
      left: 56,
      right: 56,
      bottom: bottom + 48,
      child: Opacity(
        opacity: visible,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: AppText.hud.copyWith(
                    color: AppColors.ivoryMuted,
                    fontSize: 9.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).round().toString().padLeft(3, '0')}%',
                  style: AppText.hud.copyWith(fontSize: 9.5),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 3,
              child: CustomPaint(
                size: const Size(double.infinity, 3),
                painter: _LoaderPainter(progress),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  _LoaderPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const segments = 28;
    const gap = 3.0;
    final w = (size.width - gap * (segments - 1)) / segments;
    for (var i = 0; i < segments; i++) {
      final lit = (progress * segments - i).clamp(0.0, 1.0);
      final rect = Rect.fromLTWH(i * (w + gap), 0, w, size.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()
          ..color = Color.lerp(
            AppColors.ivoryGhost,
            i / segments > 0.86 ? AppColors.gold : AppColors.glow,
            lit,
          )!,
      );
    }
    final head = progress * size.width;
    canvas.drawCircle(
      Offset(head, size.height / 2),
      6,
      Paint()
        ..color = AppColors.glow.withValues(
          alpha: 0.5 * math.sin(progress * math.pi),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(_LoaderPainter old) => old.progress != progress;
}
