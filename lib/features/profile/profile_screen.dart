import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/hud_bits.dart';
import '../../core/widgets/hud_panel.dart';
import '../../core/widgets/hud_scaffold.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/wellnest_mark.dart';
import '../auth/data/practitioner.dart';
import '../auth/presentation/session_controller.dart';
import '../cme/data/cme_providers.dart';
import '../licence/data/licence.dart';
import 'preferences.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => const _SignOutSheet(),
    );
    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      ref.read(sessionProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(practitionerProvider);
    final licence = ref.watch(licenceProvider);
    final credits = ref.watch(cmeCreditsProvider);
    final certificates = ref.watch(certificatesProvider).length;
    final prefs = ref.watch(preferencesProvider);
    final prefsCtrl = ref.read(preferencesProvider.notifier);
    final padding = MediaQuery.paddingOf(context);

    return HudScaffold(
      flakes: 12,
      focus: const Alignment(0, -0.6),
      body: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            padding.top + 8,
            AppSpacing.gutter,
            padding.bottom + 30,
          ),
          children: [
            Row(
              children: [
                GlassIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => context.pop(),
                ),
                const Spacer(),
                const Text('PROFILE', style: AppText.hud),
                const Spacer(),
                const SizedBox(width: 44),
              ],
            ),
            const SizedBox(height: 22),
            Entrance(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.25),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: HexAvatar(initials: p.initials, size: 96),
                  ),
                  const SizedBox(height: 16),
                  Text(p.name, style: AppText.headline),
                  const SizedBox(height: 4),
                  Text(
                    '${p.role} · ${p.facility}',
                    textAlign: TextAlign.center,
                    style: AppText.body,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      HudTag(
                        '${licence.authorityShort} licensed',
                        icon: Icons.verified_rounded,
                      ),
                      HudTag(p.emirate, color: AppColors.gold),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Entrance(
              index: 1,
              child: HudPanel(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  children: [
                    _Stat(
                      value: p.yearsLicensed.toDouble(),
                      label: 'Years licensed',
                    ),
                    const _Rule(),
                    _Stat(
                      value: credits,
                      decimals: credits % 1 == 0 ? 0 : 1,
                      label: 'CME credits',
                    ),
                    const _Rule(),
                    _Stat(
                      value: certificates.toDouble(),
                      label: 'Certificates',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Entrance(
              index: 2,
              child: _Group(
                label: 'Credentials',
                children: [
                  _Row(
                    icon: Icons.badge_outlined,
                    title: 'Medical licence',
                    detail:
                        '${licence.number} · until ${Formatters.date(licence.expiresOn)}',
                    onTap: () => context.go(AppRoutes.licence),
                  ),
                  _Row(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Board certification',
                    detail: p.boardCertification,
                  ),
                  _Row(
                    icon: Icons.perm_identity_rounded,
                    title: 'Emirates ID',
                    detail: 'Verified · valid until ${p.emiratesIdExpiry}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Entrance(
              index: 3,
              child: _Group(
                label: 'Preferences',
                children: [
                  _Row(
                    icon: Icons.notifications_active_outlined,
                    title: 'Renewal reminders',
                    detail: '60, 30 and 7 days before expiry',
                    trailing: HudSwitch(
                      value: prefs.reminders,
                      onChanged: prefsCtrl.setReminders,
                    ),
                  ),
                  _Row(
                    icon: Icons.fingerprint_rounded,
                    title: 'Biometric sign-in',
                    detail: 'Face or fingerprint on this device',
                    trailing: HudSwitch(
                      value: prefs.biometrics,
                      onChanged: prefsCtrl.setBiometrics,
                    ),
                  ),
                  _Row(
                    icon: Icons.motion_photos_off_outlined,
                    title: 'Reduce motion',
                    detail: 'Calmer transitions and effects',
                    trailing: HudSwitch(
                      value: prefs.reduceMotion,
                      onChanged: prefsCtrl.setReduceMotion,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Entrance(
              index: 4,
              child: _Group(
                label: 'Support',
                children: [
                  _Row(
                    icon: Icons.support_agent_rounded,
                    title: 'Help centre',
                    detail: 'Licensing specialists, 24/7',
                    onTap: () {},
                  ),
                  _Row(
                    icon: Icons.shield_outlined,
                    title: 'Privacy & security',
                    detail: 'Encryption, sessions and data',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Entrance(
              index: 5,
              child: Pressable(
                onTap: () => _signOut(context, ref),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: AppColors.coral.withValues(alpha: 0.08),
                    border: Border.all(
                      color: AppColors.coral.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: AppColors.coral,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sign out',
                        style: AppText.button.copyWith(color: AppColors.coral),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Entrance(
              index: 6,
              child: Column(
                children: [
                  const WellnestMark(size: 30),
                  const SizedBox(height: 8),
                  Text(
                    'WELLNEST  ·  VERSION 1.0',
                    style: AppText.hud.copyWith(
                      color: AppColors.ivoryFaint,
                      fontSize: 9,
                    ),
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

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.decimals = 0});

  final double value;
  final String label;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CountUp(
            value: value,
            decimals: decimals,
            style: AppText.metric.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppText.bodySmall.copyWith(fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: AppColors.hairline);
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return HudPanel(
      label: label,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.detail,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.glow.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.glow.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, size: 19, color: AppColors.mint),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.label),
                const SizedBox(height: 2),
                Text(detail, style: AppText.bodySmall.copyWith(fontSize: 12)),
              ],
            ),
          ),
          trailing ??
              (onTap != null
                  ? const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.ivoryFaint,
                    )
                  : const SizedBox.shrink()),
        ],
      ),
    );
    return onTap == null ? row : Pressable(onTap: onTap, child: row);
  }
}

class HudSwitch extends StatelessWidget {
  const HudSwitch({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!value);
        },
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.easeOut,
          width: 50,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: value
                ? AppColors.glow.withValues(alpha: 0.22)
                : AppColors.deep,
            border: Border.all(
              color: value
                  ? AppColors.glow.withValues(alpha: 0.7)
                  : AppColors.hairline,
            ),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 360),
            curve: AppMotion.snap,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: AnimatedContainer(
              duration: AppMotion.normal,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? AppColors.mint : AppColors.ivoryFaint,
                boxShadow: value
                    ? [
                        BoxShadow(
                          color: AppColors.glow.withValues(alpha: 0.7),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignOutSheet extends StatelessWidget {
  const _SignOutSheet();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(22, 14, 22, bottom + 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xF00F3A2B), Color(0xF5061C15)],
            ),
            border: Border(
              top: BorderSide(color: AppColors.glow.withValues(alpha: 0.35)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ivoryGhost,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),
              const Icon(
                Icons.logout_rounded,
                color: AppColors.coral,
                size: 30,
              ),
              const SizedBox(height: 14),
              const Text('Sign out of Wellnest?', style: AppText.title),
              const SizedBox(height: 8),
              const Text(
                'Your licence and learning progress stay safely synced.',
                textAlign: TextAlign.center,
                style: AppText.body,
              ),
              const SizedBox(height: 22),
              HudButton.glow(
                label: 'Sign out',
                onTap: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 10),
              HudButton.ghost(
                label: 'Stay signed in',
                onTap: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
