import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/hud_bits.dart';
import '../../auth/data/practitioner.dart';
import '../../cme/data/cme_providers.dart';
import '../../cme/presentation/widgets/course_card.dart';
import '../../library/data/library_providers.dart';
import '../../library/presentation/widgets/article_tile.dart';
import '../../licence/data/licence.dart';
import 'widgets/credential_panel.dart';
import 'widgets/home_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practitioner = ref.watch(practitionerProvider);
    final credits = ref.watch(cmeCreditsProvider);
    final certificates = ref.watch(certificatesProvider).length;
    final saved = ref.watch(bookmarksProvider).length;
    final learning = ref.watch(inProgressCoursesProvider);
    final latest = ref.watch(newsProvider);
    final renewed = ref.watch(licenceProvider.select((l) => l.isRenewed));
    final padding = MediaQuery.paddingOf(context);
    final today = Formatters.today;

    void tab(String path) => context.go(path);

    return Material(
      type: MaterialType.transparency,
      child: EntranceScope(
        child: ListView(
          padding: EdgeInsets.only(
            top: padding.top + 14,
            bottom: padding.bottom + AppSpacing.navClearance,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: Entrance(
                child: GreetingHeader(
                  greeting: Formatters.greeting(),
                  name: practitioner.shortName,
                  initials: practitioner.initials,
                  subtitle:
                      '${Formatters.weekday(today)} · ${Formatters.date(today)} · ${practitioner.emirate}',
                  onAvatar: () => context.push(AppRoutes.profile),
                  onAlerts: () => showAlertsSheet(context),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: Entrance(index: 1, child: CredentialPanel()),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: Entrance(
                index: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        value: credits,
                        decimals: credits % 1 == 0 ? 0 : 1,
                        suffix: ' / ${requiredCmeCredits.round()}',
                        label: 'CME credits',
                        icon: Icons.school_rounded,
                        onTap: () => tab(AppRoutes.cme),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        value: certificates.toDouble(),
                        label: 'Certificates',
                        icon: Icons.workspace_premium_rounded,
                        accent: AppColors.gold,
                        onTap: () => tab(AppRoutes.cme),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        value: saved.toDouble(),
                        label: 'Saved papers',
                        icon: Icons.bookmark_rounded,
                        accent: AppColors.mint,
                        onTap: () => tab(AppRoutes.library),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Entrance(
              index: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    QuickAction(
                      icon: renewed
                          ? Icons.verified_rounded
                          : Icons.autorenew_rounded,
                      label: renewed ? 'Renewed' : 'Renew',
                      accent: AppColors.gold,
                      onTap: () => renewed
                          ? tab(AppRoutes.licence)
                          : context.push(AppRoutes.renewal),
                    ),
                    QuickAction(
                      icon: Icons.qr_code_2_rounded,
                      label: 'Digital ID',
                      onTap: () => tab(AppRoutes.licence),
                    ),
                    QuickAction(
                      icon: Icons.travel_explore_rounded,
                      label: 'Find CME',
                      onTap: () => tab(AppRoutes.cme),
                    ),
                    QuickAction(
                      icon: Icons.newspaper_rounded,
                      label: 'Journals',
                      accent: AppColors.mint,
                      onTap: () => tab(AppRoutes.library),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            if (learning.isNotEmpty) ...[
              Entrance(
                index: 4,
                child: SectionHeader(
                  'Continue learning',
                  eyebrow: 'In progress',
                  action: 'All courses',
                  onAction: () => tab(AppRoutes.cme),
                ),
              ),
              const SizedBox(height: 14),
              Entrance(
                index: 5,
                child: SizedBox(
                  height: 262,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    itemCount: learning.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => SizedBox(
                      width: 268,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: CourseCard(course: learning[i]),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Entrance(
              index: 6,
              child: SectionHeader(
                'Today in medicine',
                eyebrow: 'Clinical news',
                action: 'Library',
                onAction: () => tab(AppRoutes.library),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: Entrance(
                index: 7,
                child: NewsTicker(items: [for (final a in latest) a.title]),
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  0,
                  AppSpacing.gutter,
                  10,
                ),
                child: Entrance(
                  index: 8 + i,
                  child: ArticleTile(article: latest[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
