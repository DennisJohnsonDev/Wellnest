import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/hud_bits.dart';
import '../../../core/widgets/hud_panel.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../../core/widgets/segmented.dart';
import '../../licence/data/licence.dart';
import '../data/cme_providers.dart';
import '../data/course.dart';
import 'widgets/course_card.dart';

class CmeScreen extends ConsumerStatefulWidget {
  const CmeScreen({super.key});

  @override
  ConsumerState<CmeScreen> createState() => _CmeScreenState();
}

class _CmeScreenState extends ConsumerState<CmeScreen> {
  CmeCategory? _category;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final catalogue = ref.watch(cmeCatalogueProvider);
    final credits = ref.watch(cmeCreditsProvider);
    final inProgress = ref.watch(inProgressCoursesProvider).length;
    final certificates = ref.watch(certificatesProvider).length;
    final padding = MediaQuery.paddingOf(context);

    final q = _query.trim().toLowerCase();
    final browsing = _category == null && q.isEmpty;
    final featured = catalogue.firstWhere((c) => c.featured);
    final courses = catalogue.where((c) {
      if (_category != null && c.category != _category) return false;
      if (q.isNotEmpty &&
          !'${c.title} ${c.provider} ${c.category.label}'
              .toLowerCase()
              .contains(q)) {
        return false;
      }
      return !(browsing && c.featured);
    }).toList();

    return Material(
      type: MaterialType.transparency,
      child: EntranceScope(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                padding.top + 14,
                AppSpacing.gutter,
                0,
              ),
              sliver: SliverList.list(
                children: [
                  const Entrance(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CONTINUING EDUCATION', style: AppText.hud),
                        SizedBox(height: 6),
                        Text('CME', style: AppText.display),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Entrance(
                    index: 1,
                    child: HudPanel(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ProgressRing(
                            value: (credits / requiredCmeCredits).clamp(
                              0.0,
                              1.0,
                            ),
                            size: 72,
                            stroke: 6,
                            ticks: false,
                            child: Text(
                              '${(credits / requiredCmeCredits * 100).clamp(0, 100).round()}%',
                              style: AppText.metric.copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    CountUp(
                                      value: credits,
                                      decimals: credits % 1 == 0 ? 0 : 1,
                                      style: AppText.metric.copyWith(
                                        fontSize: 26,
                                      ),
                                    ),
                                    const Text(
                                      '  credits this cycle',
                                      style: AppText.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    HudTag('$inProgress in progress'),
                                    HudTag(
                                      '$certificates certificate${certificates == 1 ? '' : 's'}',
                                      color: AppColors.gold,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Entrance(
                    index: 2,
                    child: HudSearchField(
                      hint: 'Search courses, providers, topics',
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Entrance(
                index: 3,
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    children: [
                      HudChip(
                        label: 'All',
                        selected: _category == null,
                        onTap: () => setState(() => _category = null),
                      ),
                      for (final c in CmeCategory.values) ...[
                        const SizedBox(width: 8),
                        HudChip(
                          label: c.label,
                          icon: c.icon,
                          selected: _category == c,
                          onTap: () => setState(
                            () => _category = _category == c ? null : c,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                20,
                AppSpacing.gutter,
                padding.bottom + AppSpacing.navClearance,
              ),
              sliver: SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: AppMotion.normal,
                  switchInCurve: AppMotion.easeOut,
                  child: EntranceScope(
                    key: ValueKey('${_category?.name}-$q'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (browsing) ...[
                          const Entrance(
                            index: 4,
                            child: Text('FEATURED', style: AppText.hud),
                          ),
                          const SizedBox(height: 10),
                          Entrance(
                            index: 4,
                            child: CourseCard(course: featured),
                          ),
                          const SizedBox(height: 24),
                          Entrance(
                            index: 5,
                            child: Text(
                              'ALL COURSES · ${courses.length}',
                              style: AppText.hud,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (courses.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 36,
                                  color: AppColors.ivoryFaint,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No courses match “$_query”',
                                  style: AppText.body,
                                ),
                              ],
                            ),
                          ),
                        for (var i = 0; i < courses.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Entrance(
                              index: (browsing ? 6 : 0) + i,
                              child: CourseCard(course: courses[i]),
                            ),
                          ),
                        if (courses.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Center(
                              child: Text(
                                '${Formatters.credits(courses.fold(0.0, (s, c) => s + c.credits))} CREDITS AVAILABLE',
                                style: AppText.hud.copyWith(
                                  color: AppColors.ivoryFaint,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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
