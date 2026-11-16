import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/effects/cover_art.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/hud_bits.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/segmented.dart';
import '../data/article.dart';
import '../data/library_providers.dart';
import 'widgets/article_tile.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final papers = ref.watch(publicationsProvider);
    final stories = ref.watch(newsProvider);
    final saved = ref.watch(bookmarksProvider);
    final padding = MediaQuery.paddingOf(context);
    final everything = [...papers, ...stories];

    final List<Widget> content = switch (_tab) {
      0 => [
        _FeaturedPaper(article: papers.firstWhere((a) => a.featured)),
        const SizedBox(height: 24),
        const Text('LATEST PAPERS', style: AppText.hud),
        const SizedBox(height: 12),
        for (final a in papers.where((a) => !a.featured))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ArticleTile(article: a),
          ),
      ],
      1 => [
        _TopStory(article: stories.firstWhere((a) => a.featured)),
        const SizedBox(height: 24),
        const Text('MORE STORIES', style: AppText.hud),
        const SizedBox(height: 12),
        for (final a in stories.where((a) => !a.featured))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ArticleTile(article: a),
          ),
      ],
      _ => [
        if (saved.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Column(
              children: [
                Icon(
                  Icons.bookmark_border_rounded,
                  size: 40,
                  color: AppColors.ivoryFaint,
                ),
                SizedBox(height: 12),
                Text('Nothing saved yet', style: AppText.titleSmall),
                SizedBox(height: 6),
                Text(
                  'Tap the bookmark on any paper to keep it here.',
                  style: AppText.bodySmall,
                ),
              ],
            ),
          ),
        for (final a in everything.where((a) => saved.contains(a.id)))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ArticleTile(article: a),
          ),
      ],
    };

    return Material(
      type: MaterialType.transparency,
      child: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            padding.top + 14,
            AppSpacing.gutter,
            padding.bottom + AppSpacing.navClearance,
          ),
          children: [
            const Entrance(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PUBLICATIONS & NEWS', style: AppText.hud),
                  SizedBox(height: 6),
                  Text('Library', style: AppText.display),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Entrance(
              index: 1,
              child: HudSegmented(
                items: ['Publications', 'News', 'Saved · ${saved.length}'],
                index: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: AppMotion.normal,
              switchInCurve: AppMotion.easeOut,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topCenter,
                children: [...previous, ?current],
              ),
              child: EntranceScope(
                key: ValueKey(_tab),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < content.length; i++)
                      Entrance(index: 2 + i, child: content[i]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedPaper extends ConsumerWidget {
  const _FeaturedPaper({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(bookmarksProvider).contains(article.id);
    final figure = article.figure!;
    final peak = figure.values.reduce((a, b) => a > b ? a : b);

    return Pressable(
      onTap: () => context.push(AppRoutes.article(article.id)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.12),
              blurRadius: 40,
            ),
            const BoxShadow(
              color: Color(0x99000000),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  article.source.toUpperCase(),
                  style: AppText.hud.copyWith(color: AppColors.emeraldDeep),
                ),
                const Spacer(),
                BookmarkButton(
                  id: article.id,
                  saved: saved,
                  color: AppColors.goldDeep,
                  idle: AppColors.inkFaint,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              article.title,
              style: AppText.serifTitle.copyWith(fontSize: 23, height: 1.22),
            ),
            const SizedBox(height: 10),
            Text(
              article.authors,
              style: AppText.serifBody.copyWith(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 64,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < figure.values.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: figure.values[i] / peak),
                          duration: Duration(milliseconds: 900 + i * 140),
                          curve: AppMotion.settle,
                          builder: (context, v, _) => Container(
                            height: 64 * v,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: i == figure.values.length - 1
                                    ? const [AppColors.goldDeep, AppColors.gold]
                                    : const [
                                        AppColors.emeraldDeep,
                                        AppColors.emerald,
                                      ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              figure.title,
              style: AppText.bodySmall.copyWith(
                color: AppColors.inkMuted,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: AppColors.paperLine),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 15,
                  color: AppColors.emeraldDeep,
                ),
                const SizedBox(width: 5),
                Text(
                  'Peer reviewed',
                  style: AppText.label.copyWith(
                    color: AppColors.emeraldDeep,
                    fontSize: 12.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '${article.readMinutes} min read',
                  style: AppText.bodySmall.copyWith(
                    color: AppColors.inkMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopStory extends StatelessWidget {
  const _TopStory({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => context.push(AppRoutes.article(article.id)),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.hairline),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: CoverArt(
          motif: motifForTopic(article.topic),
          seed: article.seed,
          accent: AppColors.gold,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00061C15), Color(0xF2061C15)],
                stops: [0.2, 0.9],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HudTag(
                    'Top story',
                    mono: true,
                    color: AppColors.gold,
                    icon: Icons.bolt_rounded,
                  ),
                  const Spacer(),
                  Text(
                    article.title,
                    style: AppText.title.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${article.source.toUpperCase()}  ·  ${Formatters.ago(article.publishedAt).toUpperCase()}',
                    style: AppText.hud.copyWith(
                      fontSize: 9,
                      color: AppColors.ivoryMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
