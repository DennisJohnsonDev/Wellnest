import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/effects/matrix_rain.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/hud_bits.dart';
import '../../../core/widgets/hud_panel.dart';
import '../../../core/widgets/hud_scaffold.dart';
import '../../../core/widgets/hud_text_field.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/wellnest_mark.dart';
import '../data/practitioner.dart';
import 'biometric_scan.dart';
import 'session_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _loading = false;

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    ref.read(sessionProvider.notifier).signIn();
  }

  Future<void> _biometric() async {
    FocusScope.of(context).unfocus();
    final ok = await showBiometricScan(context);
    if (ok && mounted) ref.read(sessionProvider.notifier).signIn();
  }

  @override
  Widget build(BuildContext context) {
    final practitioner = ref.watch(practitionerProvider);
    final padding = MediaQuery.paddingOf(context);

    return HudScaffold(
      flakes: 10,
      focus: const Alignment(0, -0.9),
      body: Stack(
        children: [
          const Positioned.fill(
            child: Opacity(opacity: 0.08, child: MatrixRain(spacing: 24)),
          ),
          EntranceScope(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                padding.top + 28,
                AppSpacing.gutter,
                padding.bottom + 24,
              ),
              children: [
                const Entrance(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: WellnestMark(size: 58, glow: 0.35),
                  ),
                ),
                const SizedBox(height: 26),
                Entrance(
                  index: 1,
                  child: Text(
                    'Welcome back,\n${practitioner.shortName}.',
                    style: AppText.display,
                  ),
                ),
                const SizedBox(height: 10),
                const Entrance(
                  index: 2,
                  child: Text(
                    'Sign in to your secure practitioner workspace.',
                    style: AppText.body,
                  ),
                ),
                const SizedBox(height: 28),
                Entrance(
                  index: 3,
                  child: HudPanel(
                    label: 'Secure sign-in',
                    trailing: const HudTag(
                      'Encrypted',
                      mono: true,
                      icon: Icons.lock_rounded,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const HudTextField(
                          label: 'Licence number',
                          icon: Icons.badge_outlined,
                          initialValue: 'DHA-P-0417238',
                          mono: true,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        const HudTextField(
                          label: 'Password',
                          icon: Icons.key_rounded,
                          initialValue: 'wellnest-demo',
                          obscure: true,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Forgot password?',
                            style: AppText.label.copyWith(
                              color: AppColors.glow,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Entrance(
                  index: 4,
                  child: HudButton.glow(
                    label: 'Sign in',
                    icon: Icons.arrow_forward_rounded,
                    loading: _loading,
                    onTap: _signIn,
                  ),
                ),
                const SizedBox(height: 22),
                Entrance(
                  index: 5,
                  child: Row(
                    children: [
                      const Expanded(child: HudDivider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: AppText.hud.copyWith(
                            color: AppColors.ivoryFaint,
                          ),
                        ),
                      ),
                      const Expanded(child: HudDivider()),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Entrance(index: 6, child: _BiometricTile(onTap: _biometric)),
                const SizedBox(height: 30),
                Entrance(
                  index: 7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 13,
                        color: AppColors.ivoryFaint,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'END-TO-END ENCRYPTED  ·  ISO 27001',
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
        ],
      ),
    );
  }
}

class _BiometricTile extends StatelessWidget {
  const _BiometricTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.deep.withValues(alpha: 0.6),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF16503B), Color(0xFF0A2A1F)],
                ),
                border: Border.all(
                  color: AppColors.glow.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.face_retouching_natural_rounded,
                color: AppColors.mint,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Biometric sign-in', style: AppText.label),
                  SizedBox(height: 3),
                  Text(
                    'Face or fingerprint · this device',
                    style: AppText.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.ivoryFaint,
            ),
          ],
        ),
      ),
    );
  }
}
