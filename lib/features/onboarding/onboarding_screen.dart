import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/effects/matrix_rain.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/hud_scaffold.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/wellnest_mark.dart';
import 'onboarding_art.dart';

class _Slide {
  const _Slide(this.eyebrow, this.title, this.body);

  final String eyebrow;
  final String title;
  final String body;
}

const _slides = [
  _Slide(
    'Licensing',
    'Your licence,\nalways in force.',
    'Track expiry, meet every requirement and renew in minutes — with a verified digital licence in your pocket.',
  ),
  _Slide(
    'Continuing education',
    'CME that fits\nbetween shifts.',
    'Accredited courses matched to your specialty. Every credit counts toward renewal automatically.',
  ),
  _Slide(
    'Publications & news',
    'Research,\ndistilled.',
    'Peer-reviewed papers and clinical news from across the region, curated for how you practise.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pages = PageController();
  late final _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();
  late final _fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    _ambient.dispose();
    _fill.dispose();
    super.dispose();
  }

  void _onPage(int i) {
    HapticFeedback.selectionClick();
    setState(() => _index = i);
    if (i == 1) _fill.forward(from: 0);
  }

  void _next() {
    if (_index == _slides.length - 1) {
      context.go(AppRoutes.signIn);
      return;
    }
    _pages.nextPage(duration: AppMotion.glide, curve: AppMotion.emphasized);
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final height = MediaQuery.sizeOf(context).height;
    final last = _index == _slides.length - 1;

    return HudScaffold(
      flakes: 16,
      focus: const Alignment(0, -0.45),
      body: Stack(
        children: [
          const Positioned.fill(
            child: Opacity(opacity: 0.1, child: MatrixRain(spacing: 26)),
          ),
          AnimatedBuilder(
            animation: Listenable.merge([_pages, _ambient, _fill]),
            builder: (context, _) {
              final page = _pages.hasClients && _pages.position.haveDimensions
                  ? _pages.page ?? 0
                  : 0.0;
              return PageView.builder(
                controller: _pages,
                onPageChanged: _onPage,
                itemCount: _slides.length,
                itemBuilder: (context, i) => _SlideView(
                  slide: _slides[i],
                  index: i,
                  offset: page - i,
                  artHeight: height * (height < 760 ? 0.34 : 0.4),
                  top: padding.top + 64,
                  art: switch (i) {
                    0 => LicenceArt(t: _ambient.value, offset: page - i),
                    1 => CmeArt(
                      t: _ambient.value,
                      offset: page - i,
                      fill: AppMotion.settle.transform(_fill.value),
                    ),
                    _ => ResearchArt(t: _ambient.value, offset: page - i),
                  },
                ),
              );
            },
          ),
          Positioned(
            top: padding.top + 12,
            left: AppSpacing.gutter,
            right: AppSpacing.gutter,
            child: Row(
              children: [
                const WellnestMark(size: 28),
                const SizedBox(width: 8),
                const Wordmark(size: 18),
                const Spacer(),
                AnimatedOpacity(
                  opacity: last ? 0 : 1,
                  duration: AppMotion.normal,
                  child: Pressable(
                    onTap: last ? null : () => context.go(AppRoutes.signIn),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'SKIP',
                        style: AppText.hud.copyWith(
                          color: AppColors.ivoryMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: AppSpacing.gutter,
            right: AppSpacing.gutter,
            bottom: padding.bottom + 20,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _pages,
                  builder: (context, _) => _Segments(
                    page: _pages.hasClients && _pages.position.haveDimensions
                        ? _pages.page ?? 0
                        : 0,
                    count: _slides.length,
                  ),
                ),
                const SizedBox(height: 22),
                last
                    ? HudButton.gold(
                        key: const ValueKey('start'),
                        label: 'Get started',
                        icon: Icons.arrow_forward_rounded,
                        onTap: _next,
                      )
                    : HudButton.glow(
                        key: const ValueKey('next'),
                        label: 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        onTap: _next,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.index,
    required this.offset,
    required this.artHeight,
    required this.top,
    required this.art,
  });

  final _Slide slide;
  final int index;
  final double offset;
  final double artHeight;
  final double top;
  final Widget art;

  @override
  Widget build(BuildContext context) {
    final fade = (1 - offset.abs() * 1.4).clamp(0.0, 1.0);
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: artHeight,
            width: double.infinity,
            child: Opacity(
              opacity: (1 - offset.abs() * 0.8).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 1 - offset.abs() * 0.12,
                child: art,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Transform.translate(
              offset: Offset(offset * 60, 0),
              child: Opacity(
                opacity: fade,
                child: Entrance(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '0${index + 1} — ${slide.eyebrow}'.toUpperCase(),
                        style: AppText.hud,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        slide.title,
                        style: AppText.display.copyWith(fontSize: 36),
                      ),
                      const SizedBox(height: 14),
                      Text(slide.body, style: AppText.body),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segments extends StatelessWidget {
  const _Segments({required this.page, required this.count});

  final double page;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Builder(
            builder: (context) {
              final active = (1 - (page - i).abs()).clamp(0.0, 1.0);
              return Container(
                width: 12 + 30 * active,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Color.lerp(
                    AppColors.ivoryGhost,
                    AppColors.glow,
                    active,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glow.withValues(alpha: 0.6 * active),
                      blurRadius: 8,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        const Spacer(),
        Text(
          '0${page.round() + 1} / 0$count',
          style: AppText.hud.copyWith(color: AppColors.ivoryMuted),
        ),
      ],
    );
  }
}
