import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/effects/cover_art.dart';
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
import '../../../core/widgets/progress_ring.dart';
import '../data/cme_providers.dart';
import '../data/course.dart';
import 'widgets/course_card.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({required this.courseId, super.key});

  final String courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  static const _coverHeight = 300.0;

  final _scroll = ScrollController();
  bool _working = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _completeNext(Course course) async {
    setState(() => _working = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final done = ref.read(cmeProgressProvider.notifier).completeNext(course);
    done == course.modules.length
        ? HapticFeedback.heavyImpact()
        : HapticFeedback.mediumImpact();
    setState(() => _working = false);
  }

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(courseProvider(widget.courseId));
    final done = ref.watch(cmeProgressProvider)[course.id] ?? 0;
    final claimed = ref.watch(certificatesProvider).containsKey(course.id);
    final total = course.modules.length;
    final complete = done >= total;
    final padding = MediaQuery.paddingOf(context);

    return HudScaffold(
      flakes: 8,
      body: Stack(
        children: [
          EntranceScope(
            child: CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedBuilder(
                        animation: _scroll,
                        builder: (context, child) {
                          final o = _scroll.hasClients ? _scroll.offset : 0.0;
                          return SizedBox(
                            height: _coverHeight,
                            child: ClipRect(
                              child: OverflowBox(
                                alignment: Alignment.bottomCenter,
                                maxHeight: _coverHeight + (o < 0 ? -o : 0),
                                child: Transform.translate(
                                  offset: Offset(0, o > 0 ? o * 0.45 : 0),
                                  child: child,
                                ),
                              ),
                            ),
                          );
                        },
                        child: CoverArt(
                          motif: motifFor(course.category),
                          seed: course.seed,
                          accent: accentFor(course.category),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -86),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.gutter,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Entrance(
                                child: Wrap(
                                  spacing: 8,
                                  children: [
                                    HudTag(
                                      course.category.label,
                                      icon: course.category.icon,
                                      color: AppColors.ivory,
                                    ),
                                    HudTag(course.level, color: AppColors.mint),
                                    if (course.mandatory)
                                      const HudTag(
                                        'Mandatory',
                                        mono: true,
                                        color: AppColors.coral,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Entrance(
                                index: 1,
                                child: Text(
                                  course.title,
                                  style: AppText.headline,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Entrance(
                                index: 2,
                                child: Text(
                                  course.provider,
                                  style: AppText.body.copyWith(
                                    color: AppColors.ivory,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Entrance(index: 3, child: _Stats(course: course)),
                              const SizedBox(height: 14),
                              Entrance(
                                index: 4,
                                child: _ProgressPanel(
                                  done: done,
                                  total: total,
                                  claimed: claimed,
                                ),
                              ),
                              const SizedBox(height: 22),
                              const Entrance(
                                index: 5,
                                child: Text('ABOUT', style: AppText.hud),
                              ),
                              const SizedBox(height: 10),
                              Entrance(
                                index: 5,
                                child: Text(
                                  course.summary,
                                  style: AppText.body,
                                ),
                              ),
                              const SizedBox(height: 14),
                              for (final o in course.outcomes)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 3),
                                        child: Icon(
                                          Icons.check_circle_rounded,
                                          size: 16,
                                          color: AppColors.glow,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          o,
                                          style: AppText.body.copyWith(
                                            color: AppColors.ivory,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 18),
                              Text(
                                'MODULES · ${course.modules.length}',
                                style: AppText.hud,
                              ),
                              const SizedBox(height: 12),
                              for (var i = 0; i < total; i++)
                                _ModuleRow(
                                  module: course.modules[i],
                                  index: i,
                                  state: i < done
                                      ? _ModuleState.done
                                      : i == done
                                      ? _ModuleState.current
                                      : _ModuleState.upcoming,
                                  working: _working && i == done,
                                ),
                              SizedBox(height: padding.bottom + 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _TopBar(scroll: _scroll, title: course.title),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(
              child: claimed
                  ? HudButton.ghost(
                      label: 'View certificate',
                      icon: Icons.workspace_premium_rounded,
                      onTap: () =>
                          context.push(AppRoutes.certificate(course.id)),
                    )
                  : complete
                  ? HudButton.gold(
                      label: 'Claim certificate',
                      icon: Icons.workspace_premium_rounded,
                      onTap: () =>
                          context.push(AppRoutes.certificate(course.id)),
                    )
                  : HudButton.glow(
                      label: done == 0
                          ? 'Start course'
                          : 'Complete module ${done + 1}',
                      icon: Icons.play_arrow_rounded,
                      loading: _working,
                      onTap: () => _completeNext(course),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.scroll, required this.title});

  final ScrollController scroll;
  final String title;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return AnimatedBuilder(
      animation: scroll,
      builder: (context, _) {
        final o = scroll.hasClients ? scroll.offset : 0.0;
        final t = ((o - 150) / 80).clamp(0.0, 1.0);
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22 * t, sigmaY: 22 * t),
            child: Container(
              padding: EdgeInsets.fromLTRB(16, top + 6, 16, 10),
              decoration: BoxDecoration(
                color: AppColors.night.withValues(alpha: 0.65 * t),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.hairline.withValues(alpha: t),
                  ),
                ),
              ),
              child: Row(
                children: [
                  GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Opacity(
                      opacity: t,
                      child: Transform.translate(
                        offset: Offset(0, (1 - t) * 8),
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.titleSmall,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 28, 20, bottom + 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x0004120D), Color(0xE604120D), AppColors.night],
          stops: [0, 0.45, 1],
        ),
      ),
      child: AnimatedSwitcher(duration: AppMotion.normal, child: child),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Formatters.credits(course.credits), 'CME credits', AppColors.goldLight),
      (Formatters.minutes(course.minutes), 'Duration', AppColors.ivory),
      ('${course.modules.length}', 'Modules', AppColors.ivory),
      ('${course.rating}', '${course.learners} learners', AppColors.ivory),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Container(
              width: 1,
              height: 34,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: AppColors.hairline,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items[i].$1,
                  style: AppText.metric.copyWith(
                    fontSize: 19,
                    color: items[i].$3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  items[i].$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({
    required this.done,
    required this.total,
    required this.claimed,
  });

  final int done;
  final int total;
  final bool claimed;

  @override
  Widget build(BuildContext context) {
    final complete = done >= total;
    return HudPanel(
      padding: const EdgeInsets.all(16),
      accent: complete ? AppColors.gold : AppColors.glow,
      glow: complete,
      child: Row(
        children: [
          ProgressRing(
            value: done / total,
            size: 64,
            stroke: 5,
            ticks: false,
            orbit: false,
            colors: complete
                ? const [
                    AppColors.goldDeep,
                    AppColors.gold,
                    AppColors.goldLight,
                  ]
                : const [AppColors.emerald, AppColors.glow, AppColors.mint],
            child: Text(
              '${(done / total * 100).round()}%',
              style: AppText.metric.copyWith(fontSize: 15),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  claimed
                      ? 'Certificate earned'
                      : complete
                      ? 'Course complete'
                      : done == 0
                      ? 'Not started'
                      : 'In progress',
                  style: AppText.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  complete
                      ? (claimed
                            ? 'Credits added to your licence record'
                            : 'Claim your certificate to bank the credits')
                      : '$done of $total modules completed',
                  style: AppText.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ModuleState { done, current, upcoming }

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.module,
    required this.index,
    required this.state,
    required this.working,
  });

  final CourseModule module;
  final int index;
  final _ModuleState state;
  final bool working;

  @override
  Widget build(BuildContext context) {
    final current = state == _ModuleState.current;
    final done = state == _ModuleState.done;
    return AnimatedContainer(
      duration: AppMotion.normal,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: current
            ? AppColors.glow.withValues(alpha: 0.07)
            : AppColors.deep.withValues(alpha: 0.6),
        border: Border.all(
          color: current
              ? AppColors.glow.withValues(alpha: 0.55)
              : AppColors.hairline.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 34,
            child: AnimatedSwitcher(
              duration: AppMotion.slow,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: AppMotion.overshoot,
                ),
                child: child,
              ),
              child: done
                  ? Container(
                      key: const ValueKey('done'),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.glow,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.glow.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: AppColors.night,
                      ),
                    )
                  : Container(
                      key: const ValueKey('todo'),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: current ? AppColors.glow : AppColors.hairline,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: working
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.glow,
                              ),
                            )
                          : Text(
                              '${index + 1}'.padLeft(2, '0'),
                              style: AppText.data.copyWith(
                                fontSize: 11,
                                color: current
                                    ? AppColors.glow
                                    : AppColors.ivoryFaint,
                              ),
                            ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: AppText.label.copyWith(
                    color: state == _ModuleState.upcoming
                        ? AppColors.ivoryMuted
                        : AppColors.ivory,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      module.kind.icon,
                      size: 13,
                      color: AppColors.ivoryFaint,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${module.kind.label} · ${module.minutes} min',
                      style: AppText.bodySmall.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (current)
            const HudTag('Up next', mono: true)
          else if (state == _ModuleState.upcoming)
            const Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: AppColors.ivoryFaint,
            ),
        ],
      ),
    );
  }
}
