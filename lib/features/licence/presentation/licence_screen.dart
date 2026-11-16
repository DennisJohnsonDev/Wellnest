import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/hud_bits.dart';
import '../../../core/widgets/hud_panel.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../auth/data/practitioner.dart';
import '../../cme/data/cme_providers.dart';
import '../data/licence.dart';
import 'widgets/holo_licence_card.dart';

class LicenceScreen extends ConsumerStatefulWidget {
  const LicenceScreen({super.key});

  @override
  ConsumerState<LicenceScreen> createState() => _LicenceScreenState();
}

class _LicenceScreenState extends ConsumerState<LicenceScreen> {
  final _flip = ValueNotifier(0);

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final licence = ref.watch(licenceProvider);
    final practitioner = ref.watch(practitionerProvider);
    final credits = ref.watch(cmeCreditsProvider);
    final padding = MediaQuery.paddingOf(context);

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
            Entrance(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DIGITAL LICENCE', style: AppText.hud),
                        SizedBox(height: 6),
                        Text('Licence', style: AppText.display),
                      ],
                    ),
                  ),
                  GlassIconButton(
                    icon: Icons.qr_code_2_rounded,
                    onTap: () => _flip.value++,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Entrance(
              index: 1,
              rise: 40,
              child: HoloLicenceCard(
                licence: licence,
                practitioner: practitioner,
                flipController: _flip,
              ),
            ),
            const SizedBox(height: 16),
            Entrance(
              index: 2,
              child: Center(
                child: Text(
                  'DRAG TO TILT  ·  TAP TO FLIP',
                  style: AppText.hud.copyWith(
                    color: AppColors.ivoryFaint,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Entrance(
              index: 3,
              child: _RequirementsPanel(credits: credits, licence: licence),
            ),
            const SizedBox(height: 14),
            Entrance(index: 4, child: _HistoryPanel(licence: licence)),
            const SizedBox(height: 22),
            Entrance(
              index: 5,
              child: licence.isRenewed
                  ? HudButton.ghost(
                      label: 'Share verification link',
                      icon: Icons.ios_share_rounded,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification link copied'),
                        ),
                      ),
                    )
                  : HudButton.gold(
                      label: 'Start renewal',
                      icon: Icons.arrow_forward_rounded,
                      onTap: () => context.push(AppRoutes.renewal),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementsPanel extends StatelessWidget {
  const _RequirementsPanel({required this.credits, required this.licence});

  final double credits;
  final Licence licence;

  @override
  Widget build(BuildContext context) {
    final met = credits >= requiredCmeCredits;
    return HudPanel(
      label: 'Renewal requirements',
      trailing: HudTag(
        '${complianceItems.length + 1}/${complianceItems.length + 1} met',
        mono: true,
        filled: true,
      ),
      child: Column(
        children: [
          Row(
            children: [
              ProgressRing(
                value: (credits / requiredCmeCredits).clamp(0.0, 1.0),
                size: 58,
                stroke: 5,
                ticks: false,
                orbit: false,
                child: Icon(
                  Icons.school_rounded,
                  size: 20,
                  color: met ? AppColors.mint : AppColors.gold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CME credits', style: AppText.label),
                    const SizedBox(height: 3),
                    Text(
                      '${Formatters.credits(credits)} of ${requiredCmeCredits.round()} required this cycle',
                      style: AppText.bodySmall,
                    ),
                  ],
                ),
              ),
              const _Check(),
            ],
          ),
          const SizedBox(height: 14),
          const HudDivider(),
          for (final item in complianceItems)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.glow.withValues(alpha: 0.08),
                      border: Border.all(
                        color: AppColors.glow.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(item.icon, size: 18, color: AppColors.mint),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.label, style: AppText.label),
                        const SizedBox(height: 2),
                        Text(item.detail, style: AppText.bodySmall),
                      ],
                    ),
                  ),
                  const _Check(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.glow,
      ),
      child: const Icon(Icons.check_rounded, size: 15, color: AppColors.night),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.licence});

  final Licence licence;

  @override
  Widget build(BuildContext context) {
    final renewed = licence.isRenewed;
    final events = [
      (
        'First licensed',
        'Specialist · ${Formatters.monthYear(licence.firstIssued)}',
        _Node.done,
      ),
      ('Upgraded to Consultant', 'Cardiology · Jun 2019', _Node.done),
      if (renewed) ...[
        ('Renewed today', 'Reference ${licence.reference}', _Node.done),
        ('Valid until', Formatters.date(licence.expiresOn), _Node.current),
      ] else ...[
        ('Last renewed', Formatters.date(licence.validFrom), _Node.done),
        (
          'Expires in ${licence.daysRemaining} days',
          Formatters.date(licence.expiresOn),
          _Node.warning,
        ),
        ('Renewal', 'Ready to submit', _Node.pending),
      ],
    ];

    return HudPanel(
      label: 'Licence history',
      child: Column(
        children: [
          for (var i = 0; i < events.length; i++)
            _TimelineRow(
              title: events[i].$1,
              detail: events[i].$2,
              node: events[i].$3,
              last: i == events.length - 1,
            ),
        ],
      ),
    );
  }
}

enum _Node { done, current, warning, pending }

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.detail,
    required this.node,
    required this.last,
  });

  final String title;
  final String detail;
  final _Node node;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = switch (node) {
      _Node.done => AppColors.emerald,
      _Node.current => AppColors.glow,
      _Node.warning => AppColors.gold,
      _Node.pending => AppColors.ivoryFaint,
    };
    final emphasised = node == _Node.current || node == _Node.warning;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                const SizedBox(height: 3),
                Container(
                  width: emphasised ? 14 : 10,
                  height: emphasised ? 14 : 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: node == _Node.pending ? Colors.transparent : color,
                    border: Border.all(color: color, width: 1.5),
                    boxShadow: emphasised
                        ? [BoxShadow(color: color, blurRadius: 10)]
                        : null,
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.hairline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.label.copyWith(
                      color: emphasised ? color : AppColors.ivory,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(detail, style: AppText.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
