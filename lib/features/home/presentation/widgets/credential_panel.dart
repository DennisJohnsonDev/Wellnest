import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/effects/ecg_line.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/hud_bits.dart';
import '../../../../core/widgets/hud_panel.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/progress_ring.dart';
import '../../../licence/data/licence.dart';

class CredentialPanel extends ConsumerWidget {
  const CredentialPanel({super.key});

  static const _window = 60;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licence = ref.watch(licenceProvider);
    final renewed = licence.isRenewed;
    final days = licence.daysRemaining;
    final value = renewed
        ? (days / licence.cycleDays).clamp(0.0, 1.0)
        : (days / _window).clamp(0.0, 1.0);
    final accent = renewed ? AppColors.glow : AppColors.gold;

    return HudPanel(
      label: 'Licence · ${licence.authorityShort}',
      glow: true,
      accent: renewed ? AppColors.glow : AppColors.gold,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      trailing: HudTag(
        renewed ? 'Active' : 'Action needed',
        color: accent,
        mono: true,
      ),
      child: Column(
        children: [
          Row(
            children: [
              ProgressRing(
                value: value,
                size: 124,
                stroke: 8,
                delay: const Duration(milliseconds: 250),
                colors: renewed
                    ? const [AppColors.emerald, AppColors.glow, AppColors.mint]
                    : const [
                        AppColors.goldDeep,
                        AppColors.gold,
                        AppColors.goldLight,
                      ],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CountUp(value: days.toDouble(), style: AppText.metric),
                    const SizedBox(height: 3),
                    Text(
                      'DAYS LEFT',
                      style: AppText.hud.copyWith(
                        fontSize: 8.5,
                        color: AppColors.ivoryMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      renewed ? 'Licence renewed' : licence.statusLabel,
                      style: AppText.titleSmall.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${renewed ? 'Valid until' : 'Expires'} ${Formatters.date(licence.expiresOn)}',
                      style: AppText.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      licence.number,
                      style: AppText.data.copyWith(
                        fontSize: 11.5,
                        color: AppColors.ivoryMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (renewed)
                      const HudTag(
                        'Up to date',
                        icon: Icons.check_rounded,
                        filled: true,
                      )
                    else
                      Pressable(
                        onTap: () => context.push(AppRoutes.renewal),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              colors: [AppColors.goldLight, AppColors.gold],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.35),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Renew now',
                                style: AppText.button.copyWith(fontSize: 13),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: AppColors.night,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          EcgLine(height: 34, color: accent),
        ],
      ),
    );
  }
}
