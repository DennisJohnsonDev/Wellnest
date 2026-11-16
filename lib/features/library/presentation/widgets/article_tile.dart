import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/effects/cover_art.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pressable.dart';
import '../../data/article.dart';
import '../../data/library_providers.dart';

CoverMotif motifForTopic(String topic) => switch (topic) {
  'Cardiology' => CoverMotif.pulse,
  'Endocrinology' => CoverMotif.lattice,
  'Emergency' || 'Public health' => CoverMotif.rings,
  'Infectious disease' => CoverMotif.cells,
  'Genomics' => CoverMotif.helix,
  _ => CoverMotif.waves,
};

class ArticleTile extends ConsumerWidget {
  const ArticleTile({required this.article, super.key});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(bookmarksProvider).contains(article.id);
    return Pressable(
      onTap: () => context.push(AppRoutes.article(article.id)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.surface.withValues(alpha: 0.72),
          border: Border.all(color: AppColors.hairline.withValues(alpha: 0.7)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 78,
                height: 78,
                child: CoverArt(
                  motif: motifForTopic(article.topic),
                  seed: article.seed,
                  accent: article.isPublication
                      ? AppColors.glow
                      : AppColors.gold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.source.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.hud.copyWith(
                      fontSize: 9,
                      color: article.isPublication
                          ? AppColors.glow
                          : AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.label.copyWith(fontSize: 14.5, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${Formatters.ago(article.publishedAt)}  ·  ${article.readMinutes} min read',
                        style: AppText.bodySmall.copyWith(fontSize: 11.5),
                      ),
                      const Spacer(),
                      BookmarkButton(id: article.id, saved: saved),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({
    required this.id,
    required this.saved,
    this.color = AppColors.gold,
    this.idle = AppColors.ivoryFaint,
    this.size = 20,
    super.key,
  });

  final String id;
  final bool saved;
  final Color color;
  final Color idle;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Pressable(
      scale: 0.8,
      onTap: () => ref.read(bookmarksProvider.notifier).toggle(id),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: AnimatedSwitcher(
          duration: AppMotion.normal,
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: AppMotion.overshoot,
            ),
            child: child,
          ),
          child: Icon(
            saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            key: ValueKey(saved),
            size: size,
            color: saved ? color : idle,
          ),
        ),
      ),
    );
  }
}
