import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/effects/cover_art.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/hud_bits.dart';
import '../../../../core/widgets/pressable.dart';
import '../../data/cme_providers.dart';
import '../../data/course.dart';

CoverMotif motifFor(CmeCategory category) => switch (category) {
  CmeCategory.cardiology => CoverMotif.pulse,
  CmeCategory.emergency => CoverMotif.rings,
  CmeCategory.endocrinology => CoverMotif.lattice,
  CmeCategory.infectious => CoverMotif.cells,
  CmeCategory.ethics => CoverMotif.columns,
  CmeCategory.genomics => CoverMotif.helix,
};

Color accentFor(CmeCategory category) => switch (category) {
  CmeCategory.endocrinology || CmeCategory.ethics => AppColors.gold,
  _ => AppColors.glow,
};

void openCourse(BuildContext context, String id, GlobalKey key) {
  final box = key.currentContext?.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  context.push(AppRoutes.course(id), extra: origin);
}

class CourseCard extends ConsumerStatefulWidget {
  const CourseCard({required this.course, this.compact = false, super.key});

  final Course course;
  final bool compact;

  @override
  ConsumerState<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends ConsumerState<CourseCard> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => openCourse(context, widget.course.id, _key),
      child: KeyedSubtree(
        key: _key,
        child: LiveCourseCard(
          courseId: widget.course.id,
          compact: widget.compact,
        ),
      ),
    );
  }
}

class LiveCourseCard extends ConsumerWidget {
  const LiveCourseCard({
    required this.courseId,
    this.compact = false,
    super.key,
  });

  final String courseId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseProvider(courseId));
    final done = ref.watch(cmeProgressProvider)[course.id] ?? 0;
    final claimed = ref.watch(certificatesProvider).containsKey(course.id);
    final total = course.modules.length;
    final progress = done / total;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: AppColors.surface,
        border: Border.all(color: AppColors.hairline.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: compact ? 92 : 128,
            child: CoverArt(
              motif: motifFor(course.category),
              seed: course.seed,
              accent: accentFor(course.category),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HudTag(
                      course.category.label,
                      icon: course.category.icon,
                      color: AppColors.ivory,
                    ),
                    const Spacer(),
                    HudTag(
                      '${Formatters.credits(course.credits)} CME',
                      color: AppColors.gold,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.titleSmall.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  course.provider,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySmall.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 12),
                if (claimed)
                  const HudTag(
                    'Certificate earned',
                    icon: Icons.workspace_premium_rounded,
                    color: AppColors.gold,
                  )
                else if (done > 0) ...[
                  HudProgressBar(value: progress),
                  const SizedBox(height: 8),
                  Text(
                    done == total
                        ? 'COMPLETE · CLAIM CERTIFICATE'
                        : 'MODULE ${done + 1} OF $total  ·  ${(progress * 100).round()}%',
                    style: AppText.hud.copyWith(
                      fontSize: 9,
                      color: done == total
                          ? AppColors.gold
                          : AppColors.ivoryMuted,
                    ),
                  ),
                ] else
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: AppColors.ivoryFaint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.minutes(course.minutes),
                        style: AppText.bodySmall.copyWith(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${course.rating}',
                        style: AppText.bodySmall.copyWith(fontSize: 12),
                      ),
                      const Spacer(),
                      if (course.mandatory)
                        const HudTag(
                          'Mandatory',
                          mono: true,
                          color: AppColors.coral,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
