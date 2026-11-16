import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/pressable.dart';
import '../data/article.dart';
import '../data/library_providers.dart';
import 'widgets/article_tile.dart';

class ArticleScreen extends ConsumerStatefulWidget {
  const ArticleScreen({required this.articleId, super.key});

  final String articleId;

  @override
  ConsumerState<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends ConsumerState<ArticleScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _toast(String message) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final article = ref.watch(articleProvider(widget.articleId));
    final saved = ref.watch(bookmarksProvider).contains(article.id);
    final padding = MediaQuery.paddingOf(context);
    final accent = article.isPublication
        ? AppColors.emeraldDeep
        : AppColors.goldDeep;

    return Theme(
      data: AppTheme.paper,
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.paper,
          body: Stack(
            children: [
              EntranceScope(
                child: ListView(
                  controller: _scroll,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    padding.top + 76,
                    24,
                    padding.bottom + 40,
                  ),
                  children: [
                    Entrance(
                      child: Text(
                        article.isPublication
                            ? 'PEER-REVIEWED RESEARCH  ·  ${article.topic.toUpperCase()}'
                            : 'CLINICAL NEWS  ·  ${article.topic.toUpperCase()}',
                        style: AppText.hud.copyWith(
                          color: accent,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Entrance(
                      index: 1,
                      child: Text(article.title, style: AppText.serifTitle),
                    ),
                    const SizedBox(height: 14),
                    Entrance(
                      index: 2,
                      child: Text(
                        article.authors,
                        style: AppText.serifBody.copyWith(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Entrance(
                      index: 2,
                      child: Text(
                        [
                          Formatters.date(article.publishedAt),
                          '${article.readMinutes} min read',
                          if (article.doi != null) 'doi ${article.doi}',
                        ].join('  ·  '),
                        style: AppText.bodySmall.copyWith(
                          color: AppColors.inkMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Entrance(
                      index: 3,
                      child: Container(
                        height: 1.2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.gold, Color(0x00D6AE45)],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Entrance(
                      index: 4,
                      child: Text(
                        article.summary,
                        style: AppText.serifBody.copyWith(
                          fontSize: 20.5,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (article.keyFindings.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Entrance(
                        index: 5,
                        child: _KeyFindings(items: article.keyFindings),
                      ),
                    ],
                    const SizedBox(height: 24),
                    for (var i = 0; i < article.body.length; i++) ...[
                      Entrance(
                        index: 6 + i,
                        child: Text(article.body[i], style: AppText.serifBody),
                      ),
                      const SizedBox(height: 18),
                      if (i == 1 && article.figure != null) ...[
                        _Figure(figure: article.figure!),
                        const SizedBox(height: 24),
                      ],
                    ],
                    if (article.body.length < 2 && article.figure != null) ...[
                      _Figure(figure: article.figure!),
                      const SizedBox(height: 24),
                    ],
                    const SizedBox(height: 8),
                    _Citation(
                      article: article,
                      onCopy: () => _toast('Citation copied'),
                    ),
                  ],
                ),
              ),
              _ReaderBar(
                scroll: _scroll,
                source: article.source,
                saved: saved,
                articleId: article.id,
                onShare: () => _toast('Link copied to share'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReaderBar extends StatelessWidget {
  const _ReaderBar({
    required this.scroll,
    required this.source,
    required this.saved,
    required this.articleId,
    required this.onShare,
  });

  final ScrollController scroll;
  final String source;
  final bool saved;
  final String articleId;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: AppColors.paper.withValues(alpha: 0.86),
          padding: EdgeInsets.only(top: top),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
                child: Row(
                  children: [
                    _PaperButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        source.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.hud.copyWith(
                          color: AppColors.inkMuted,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.paperShade,
                      ),
                      alignment: Alignment.center,
                      child: BookmarkButton(
                        id: articleId,
                        saved: saved,
                        color: AppColors.goldDeep,
                        idle: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _PaperButton(icon: Icons.ios_share_rounded, onTap: onShare),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: scroll,
                builder: (context, _) {
                  final max =
                      scroll.hasClients && scroll.position.hasContentDimensions
                      ? scroll.position.maxScrollExtent
                      : 0.0;
                  final p = max <= 0
                      ? 0.0
                      : (scroll.offset / max).clamp(0.0, 1.0);
                  return Container(
                    height: 2,
                    alignment: Alignment.centerLeft,
                    color: AppColors.paperLine,
                    child: FractionallySizedBox(
                      widthFactor: p,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.emerald, AppColors.gold],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaperButton extends StatelessWidget {
  const _PaperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.paperShade,
        ),
        child: Icon(icon, size: 20, color: AppColors.ink),
      ),
    );
  }
}

class _KeyFindings extends StatelessWidget {
  const _KeyFindings({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paperShade,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: AppColors.emeraldDeep),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KEY FINDINGS',
                      style: AppText.hud.copyWith(color: AppColors.emeraldDeep),
                    ),
                    const SizedBox(height: 12),
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: Transform.rotate(
                                angle: 0.785,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: AppText.body.copyWith(
                                  color: AppColors.ink,
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _Figure extends StatelessWidget {
  const _Figure({required this.figure});

  final ArticleFigure figure;

  @override
  Widget build(BuildContext context) {
    final peak = figure.values.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.paperLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FIGURE 1',
            style: AppText.hud.copyWith(color: AppColors.goldDeep),
          ),
          const SizedBox(height: 6),
          Text(
            figure.title,
            style: AppText.label.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < figure.values.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: figure.values[i] / peak),
                        duration: Duration(milliseconds: 1000 + i * 160),
                        curve: AppMotion.settle,
                        builder: (context, v, _) => Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${(v * peak).toStringAsFixed(figure.values[i] % 1 == 0 ? 0 : 1)}${figure.unit}',
                              style: AppText.data.copyWith(
                                fontSize: 11,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 116 * v,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: i == figure.values.length - 1
                                      ? const [
                                          AppColors.goldDeep,
                                          AppColors.gold,
                                        ]
                                      : const [
                                          AppColors.emeraldDeep,
                                          AppColors.emerald,
                                        ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.inkFaint),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final label in figure.labels)
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppText.bodySmall.copyWith(
                      color: AppColors.inkMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Citation extends StatelessWidget {
  const _Citation({required this.article, required this.onCopy});

  final Article article;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final year = article.publishedAt.year;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                article.isPublication ? 'CITE THIS ARTICLE' : 'SOURCE',
                style: AppText.hud,
              ),
              const Spacer(),
              Pressable(
                onTap: onCopy,
                child: Row(
                  children: [
                    const Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: AppColors.goldLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Copy',
                      style: AppText.label.copyWith(
                        color: AppColors.goldLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${article.authors} ($year). ${article.title}. ${article.source}.${article.doi != null ? ' doi:${article.doi}' : ''}',
            style: AppText.bodySmall.copyWith(color: AppColors.ivoryDim),
          ),
        ],
      ),
    );
  }
}
