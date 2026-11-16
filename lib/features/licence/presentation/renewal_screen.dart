import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/hud_bits.dart';
import '../../../core/widgets/hud_panel.dart';
import '../../../core/widgets/hud_scaffold.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../auth/data/practitioner.dart';
import '../../cme/data/cme_providers.dart';
import '../data/licence.dart';
import 'widgets/hold_to_confirm.dart';

class RenewalScreen extends ConsumerStatefulWidget {
  const RenewalScreen({super.key});

  @override
  ConsumerState<RenewalScreen> createState() => _RenewalScreenState();
}

class _RenewalScreenState extends ConsumerState<RenewalScreen> {
  static const _labels = ['Details', 'Compliance', 'Documents', 'Payment'];

  int _step = 0;
  bool _forward = true;
  bool _confirmed = false;
  bool _scanned = false;
  bool _uploaded = false;

  bool get _canContinue => switch (_step) {
    0 => _confirmed,
    1 => _scanned,
    2 => _uploaded,
    _ => false,
  };

  void _go(int step) {
    HapticFeedback.selectionClick();
    setState(() {
      _forward = step > _step;
      _step = step;
    });
  }

  Future<void> _pay() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    ref.read(licenceProvider.notifier).renew();
    context.pushReplacement(AppRoutes.renewalComplete);
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final total = renewalFees.fold(0, (sum, f) => sum + f.amount);

    return HudScaffold(
      flakes: 8,
      body: Column(
        children: [
          SizedBox(height: padding.top + 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Row(
              children: [
                GlassIconButton(
                  icon: Icons.close_rounded,
                  onTap: () => context.pop(),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('LICENCE RENEWAL', style: AppText.hud),
                      const SizedBox(height: 4),
                      Text(
                        'Step ${_step + 1} of ${_labels.length}',
                        style: AppText.titleSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: _Stepper(step: _step, labels: _labels),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 460),
              switchInCurve: AppMotion.settle,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final incoming = child.key == ValueKey(_step);
                final dir = (_forward ? 1.0 : -1.0) * (incoming ? 1 : -1);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: Offset(0.18 * dir, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: switch (_step) {
                  0 => _DetailsStep(
                    confirmed: _confirmed,
                    onToggle: () => setState(() => _confirmed = !_confirmed),
                  ),
                  1 => _ComplianceStep(
                    done: _scanned,
                    onDone: () => setState(() => _scanned = true),
                  ),
                  2 => _DocumentsStep(
                    uploaded: _uploaded,
                    onUploaded: () => setState(() => _uploaded = true),
                  ),
                  _ => _PaymentStep(total: total),
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              12,
              AppSpacing.gutter,
              padding.bottom + 16,
            ),
            child: AnimatedSwitcher(
              duration: AppMotion.normal,
              child: _step == 3
                  ? HoldToConfirm(
                      key: const ValueKey('pay'),
                      label: 'Hold to pay ${Formatters.aed(total)}',
                      onConfirmed: _pay,
                    )
                  : Row(
                      key: const ValueKey('nav'),
                      children: [
                        if (_step > 0) ...[
                          SizedBox(
                            width: 112,
                            child: HudButton.ghost(
                              label: 'Back',
                              onTap: () => _go(_step - 1),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: HudButton.glow(
                            label: 'Continue',
                            icon: Icons.arrow_forward_rounded,
                            onTap: _canContinue ? () => _go(_step + 1) : null,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.step, required this.labels});

  final int step;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: step.toDouble()),
      duration: const Duration(milliseconds: 560),
      curve: AppMotion.emphasized,
      builder: (context, v, _) => LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final gap = (w - 28) / (labels.length - 1);
          return SizedBox(
            height: 50,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 14,
                  right: 14,
                  top: 13,
                  child: Container(height: 2, color: AppColors.hairline),
                ),
                Positioned(
                  left: 14,
                  top: 13,
                  child: Container(
                    width: gap * v,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.emerald, AppColors.glow],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glow.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                for (var i = 0; i < labels.length; i++)
                  Positioned(
                    left: i * gap - 18 + 14,
                    width: 36,
                    top: 0,
                    child: Column(
                      children: [
                        _StepNode(
                          state: v >= i
                              ? (v.round() == i
                                    ? _NodeState.active
                                    : _NodeState.done)
                              : _NodeState.todo,
                          index: i,
                        ),
                      ],
                    ),
                  ),
                for (var i = 0; i < labels.length; i++)
                  Positioned(
                    left: i * gap + 14 - 40,
                    width: 80,
                    top: 34,
                    child: Text(
                      labels[i].toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppText.hud.copyWith(
                        fontSize: 8.5,
                        letterSpacing: 1.2,
                        color: v.round() == i
                            ? AppColors.glow
                            : AppColors.ivoryFaint,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum _NodeState { todo, active, done }

class _StepNode extends StatelessWidget {
  const _StepNode({required this.state, required this.index});

  final _NodeState state;
  final int index;

  @override
  Widget build(BuildContext context) {
    final active = state == _NodeState.active;
    final done = state == _NodeState.done;
    return AnimatedContainer(
      duration: AppMotion.normal,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done
            ? AppColors.glow
            : active
            ? AppColors.raised
            : AppColors.deep,
        border: Border.all(
          color: done || active ? AppColors.glow : AppColors.hairline,
          width: active ? 2 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.glow.withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check_rounded, size: 16, color: AppColors.night)
            : Text(
                '${index + 1}',
                style: AppText.data.copyWith(
                  fontSize: 11,
                  color: active ? AppColors.glow : AppColors.ivoryFaint,
                ),
              ),
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.title,
    required this.body,
    required this.children,
  });

  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return EntranceScope(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          18,
          AppSpacing.gutter,
          12,
        ),
        children: [
          Entrance(child: Text(title, style: AppText.headline)),
          const SizedBox(height: 8),
          Entrance(index: 1, child: Text(body, style: AppText.body)),
          const SizedBox(height: 22),
          for (var i = 0; i < children.length; i++)
            Entrance(index: 2 + i, child: children[i]),
        ],
      ),
    );
  }
}

class _DetailsStep extends ConsumerWidget {
  const _DetailsStep({required this.confirmed, required this.onToggle});

  final bool confirmed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(practitionerProvider);
    final l = ref.watch(licenceProvider);
    final rows = [
      ('Full name', p.name),
      ('Licence number', l.number),
      ('Category', '${l.category} · ${l.specialty}'),
      ('Facility', p.facility),
      ('Emirate', p.emirate),
      ('Current expiry', Formatters.date(l.expiresOn)),
    ];
    return _StepBody(
      title: 'Confirm your details',
      body:
          'We pre-filled everything from your record. Check it once — that’s it.',
      children: [
        HudPanel(
          label: 'Practitioner record',
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      rows[i].$1.toUpperCase(),
                      style: AppText.hud.copyWith(
                        fontSize: 9,
                        color: AppColors.ivoryFaint,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rows[i].$2,
                        textAlign: TextAlign.right,
                        style: AppText.label.copyWith(fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Pressable(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: AppMotion.normal,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: confirmed
                  ? AppColors.glow.withValues(alpha: 0.08)
                  : AppColors.deep.withValues(alpha: 0.6),
              border: Border.all(
                color: confirmed
                    ? AppColors.glow.withValues(alpha: 0.6)
                    : AppColors.hairline,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppMotion.normal,
                  curve: AppMotion.overshoot,
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: confirmed ? AppColors.glow : Colors.transparent,
                    border: Border.all(
                      color: confirmed ? AppColors.glow : AppColors.ivoryFaint,
                      width: 1.5,
                    ),
                  ),
                  child: AnimatedScale(
                    scale: confirmed ? 1 : 0,
                    duration: AppMotion.normal,
                    curve: AppMotion.overshoot,
                    child: const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: AppColors.night,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'I confirm these details are accurate and complete.',
                    style: AppText.label.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ComplianceStep extends ConsumerStatefulWidget {
  const _ComplianceStep({required this.done, required this.onDone});

  final bool done;
  final VoidCallback onDone;

  @override
  ConsumerState<_ComplianceStep> createState() => _ComplianceStepState();
}

class _ComplianceStepState extends ConsumerState<_ComplianceStep> {
  late int _passed = widget.done ? complianceItems.length + 1 : 0;

  @override
  void initState() {
    super.initState();
    if (!widget.done) _run();
  }

  Future<void> _run() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    for (var i = 0; i <= complianceItems.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 520));
      if (!mounted) return;
      HapticFeedback.selectionClick();
      setState(() => _passed = i + 1);
    }
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final credits = ref.watch(cmeCreditsProvider);
    final total = complianceItems.length + 1;
    final items = [
      (
        'CME credits',
        '${Formatters.credits(credits)} of ${requiredCmeCredits.round()} credits',
        Icons.school_rounded,
      ),
      for (final c in complianceItems) (c.label, c.detail, c.icon),
    ];
    final complete = _passed >= total;

    return _StepBody(
      title: 'Compliance check',
      body:
          'We verify every renewal requirement against connected registries in real time.',
      children: [
        HudPanel(
          glow: complete,
          child: Row(
            children: [
              ProgressRing(
                value: _passed / total,
                size: 76,
                stroke: 6,
                ticks: false,
                orbit: !complete,
                child: Text(
                  '$_passed/$total',
                  style: AppText.metric.copyWith(fontSize: 18),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: AppMotion.normal,
                      child: Text(
                        complete ? 'All requirements met' : 'Verifying…',
                        key: ValueKey(complete),
                        style: AppText.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      complete
                          ? 'Eligible for instant renewal'
                          : 'Checking registries securely',
                      style: AppText.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < items.length; i++)
          _ScanRow(
            title: items[i].$1,
            detail: items[i].$2,
            icon: items[i].$3,
            state: i < _passed
                ? _ScanState.passed
                : i == _passed
                ? _ScanState.checking
                : _ScanState.waiting,
          ),
      ],
    );
  }
}

enum _ScanState { waiting, checking, passed }

class _ScanRow extends StatelessWidget {
  const _ScanRow({
    required this.title,
    required this.detail,
    required this.icon,
    required this.state,
  });

  final String title;
  final String detail;
  final IconData icon;
  final _ScanState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: AppMotion.normal,
      opacity: state == _ScanState.waiting ? 0.45 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.deep.withValues(alpha: 0.6),
          border: Border.all(
            color: state == _ScanState.checking
                ? AppColors.glow.withValues(alpha: 0.6)
                : AppColors.hairline.withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.mint),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.label),
                  const SizedBox(height: 2),
                  Text(detail, style: AppText.bodySmall),
                ],
              ),
            ),
            SizedBox.square(
              dimension: 24,
              child: AnimatedSwitcher(
                duration: AppMotion.normal,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: AppMotion.overshoot,
                  ),
                  child: child,
                ),
                child: switch (state) {
                  _ScanState.passed => Container(
                    key: const ValueKey('ok'),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.glow,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColors.night,
                    ),
                  ),
                  _ScanState.checking => const Padding(
                    key: ValueKey('busy'),
                    padding: EdgeInsets.all(3),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.glow,
                    ),
                  ),
                  _ScanState.waiting => Container(
                    key: const ValueKey('wait'),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.hairline),
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentsStep extends StatefulWidget {
  const _DocumentsStep({required this.uploaded, required this.onUploaded});

  final bool uploaded;
  final VoidCallback onUploaded;

  @override
  State<_DocumentsStep> createState() => _DocumentsStepState();
}

class _DocumentsStepState extends State<_DocumentsStep>
    with SingleTickerProviderStateMixin {
  late final _upload = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
    value: widget.uploaded ? 1 : 0,
  );

  @override
  void dispose() {
    _upload.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    HapticFeedback.selectionClick();
    await _upload.animateTo(1, curve: Curves.easeInOutCubic);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    widget.onUploaded();
  }

  @override
  Widget build(BuildContext context) {
    return _StepBody(
      title: 'Supporting documents',
      body:
          'Two documents are already on file. Add your latest good standing letter to finish.',
      children: [
        for (final doc in renewalDocuments)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: doc.onFile
                ? _DocTile(
                    title: doc.label,
                    detail: doc.detail,
                    trailing: const HudTag(
                      'On file',
                      icon: Icons.check_rounded,
                    ),
                  )
                : AnimatedBuilder(
                    animation: _upload,
                    builder: (context, _) {
                      final v = _upload.value;
                      final idle = v == 0;
                      final done = v >= 1;
                      return _DocTile(
                        title: doc.label,
                        detail: done
                            ? 'good-standing-2026.pdf · uploaded just now'
                            : idle
                            ? doc.detail
                            : 'Uploading · ${(v * 100).round()}%',
                        highlight: !done,
                        trailing: done
                            ? const HudTag(
                                'Uploaded',
                                icon: Icons.check_rounded,
                                filled: true,
                              )
                            : idle
                            ? Pressable(
                                onTap: _start,
                                child: const HudTag(
                                  'Upload',
                                  icon: Icons.upload_rounded,
                                  color: AppColors.gold,
                                ),
                              )
                            : SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  value: v,
                                  strokeWidth: 2.4,
                                  color: AppColors.gold,
                                  backgroundColor: AppColors.ivoryGhost,
                                ),
                              ),
                        progress: idle || done ? null : v,
                      );
                    },
                  ),
          ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: AppColors.ivoryFaint,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Files are encrypted and shared only with the licensing authority.',
                style: AppText.bodySmall.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.title,
    required this.detail,
    required this.trailing,
    this.highlight = false,
    this.progress,
  });

  final String title;
  final String detail;
  final Widget trailing;
  final bool highlight;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.deep.withValues(alpha: 0.6),
        border: Border.all(
          color: highlight
              ? AppColors.gold.withValues(alpha: 0.45)
              : AppColors.hairline.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.paper,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: AppColors.emeraldDeep,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.label),
                    const SizedBox(height: 3),
                    Text(
                      detail,
                      style: AppText.bodySmall.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            HudProgressBar(value: progress!, color: AppColors.gold),
          ],
        ],
      ),
    );
  }
}

class _PaymentStep extends StatefulWidget {
  const _PaymentStep({required this.total});

  final int total;

  @override
  State<_PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<_PaymentStep> {
  int _method = 0;

  @override
  Widget build(BuildContext context) {
    const methods = [
      ('Visa', '•••• 4021 · Expires 08/29', Icons.credit_card_rounded),
      (
        'Digital wallet',
        'Pay with your device',
        Icons.account_balance_wallet_outlined,
      ),
    ];
    return _StepBody(
      title: 'Review & pay',
      body: 'Your renewal is processed instantly once payment is confirmed.',
      children: [
        HudPanel(
          label: 'Fee summary',
          accent: AppColors.gold,
          child: Column(
            children: [
              for (final fee in renewalFees) ...[
                Row(
                  children: [
                    Expanded(child: Text(fee.label, style: AppText.body)),
                    Text(
                      Formatters.aed(fee.amount),
                      style: AppText.data.copyWith(fontSize: 13.5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              const HudDivider(),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text('Total', style: AppText.titleSmall),
                  ),
                  Text(
                    Formatters.aed(widget.total),
                    style: AppText.metric.copyWith(
                      fontSize: 22,
                      color: AppColors.goldLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < methods.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Pressable(
              onTap: () => setState(() => _method = i),
              child: AnimatedContainer(
                duration: AppMotion.normal,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColors.deep.withValues(alpha: 0.6),
                  border: Border.all(
                    color: _method == i
                        ? AppColors.glow.withValues(alpha: 0.7)
                        : AppColors.hairline.withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(methods[i].$3, color: AppColors.mint, size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(methods[i].$1, style: AppText.label),
                          const SizedBox(height: 2),
                          Text(methods[i].$2, style: AppText.bodySmall),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: AppMotion.normal,
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _method == i
                              ? AppColors.glow
                              : AppColors.ivoryFaint,
                          width: _method == i ? 6.5 : 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
