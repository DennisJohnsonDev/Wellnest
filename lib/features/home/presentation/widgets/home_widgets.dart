import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/entrance.dart';
import '../../../../core/widgets/hud_bits.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/progress_ring.dart';
import '../../data/alerts.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    required this.value,
    required this.label,
    required this.icon,
    this.decimals = 0,
    this.suffix = '',
    this.accent = AppColors.glow,
    this.onTap,
    super.key,
  });

  final double value;
  final String label;
  final IconData icon;
  final int decimals;
  final String suffix;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md + 2),
          gradient: AppColors.panel,
          border: Border.all(color: AppColors.hairline.withValues(alpha: 0.75)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                CountUp(
                  value: value,
                  decimals: decimals,
                  style: AppText.metric.copyWith(fontSize: 24),
                ),
                if (suffix.isNotEmpty)
                  Text(suffix, style: AppText.bodySmall.copyWith(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.bodySmall.copyWith(fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  const QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = AppColors.glow,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.18),
                  AppColors.surface.withValues(alpha: 0.8),
                ],
              ),
              border: Border.all(color: accent.withValues(alpha: 0.32)),
            ),
            child: Icon(icon, color: accent, size: 25),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppText.bodySmall.copyWith(
              fontSize: 11.5,
              color: AppColors.ivory,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class NewsTicker extends StatefulWidget {
  const NewsTicker({required this.items, super.key});

  final List<String> items;

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  final _offset = ValueNotifier(0.0);
  Duration _last = Duration.zero;
  double _width = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ticker.stop();
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (_width <= 0) return;
    _offset.value = (_offset.value + dt * 34) % _width;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _offset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.items.map((e) => e.toUpperCase()).join('     •     ');
    final style = AppText.hud.copyWith(
      color: AppColors.ivoryMuted,
      fontSize: 10,
      letterSpacing: 1.4,
    );
    final painter = TextPainter(
      text: TextSpan(text: '$text     •     ', style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    _width = painter.width;
    painter.dispose();

    return Container(
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.deep.withValues(alpha: 0.75),
        border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              color: AppColors.gold.withValues(alpha: 0.14),
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.coral,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coral.withValues(alpha: 0.8),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: AppText.hud.copyWith(
                    color: AppColors.gold,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRect(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                  stops: [0, 0.06, 0.92, 1],
                ).createShader(bounds),
                child: ValueListenableBuilder<double>(
                  valueListenable: _offset,
                  builder: (context, offset, _) => OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: double.infinity,
                    child: Transform.translate(
                      offset: Offset(-offset, 0),
                      child: Text(
                        '$text     •     $text     •     ',
                        maxLines: 1,
                        softWrap: false,
                        style: style,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showAlertsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) => const _AlertsSheet(),
  );
}

class _AlertsSheet extends StatelessWidget {
  const _AlertsSheet();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 20),
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
          child: EntranceScope(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.ivoryGhost,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text('Notifications', style: AppText.title),
                    const Spacer(),
                    HudTag('${alerts.length} new', mono: true),
                  ],
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < alerts.length; i++)
                  Entrance(
                    index: i,
                    child: _AlertRow(alert: alerts[i]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert});

  final Alert alert;

  @override
  Widget build(BuildContext context) {
    final color = alert.urgent ? AppColors.gold : AppColors.glow;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.deep.withValues(alpha: 0.6),
        border: Border.all(
          color: alert.urgent
              ? AppColors.gold.withValues(alpha: 0.4)
              : AppColors.hairline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(alert.icon, size: 19, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(alert.title, style: AppText.label)),
                    Text(
                      alert.when,
                      style: AppText.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(alert.body, style: AppText.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    required this.greeting,
    required this.name,
    required this.initials,
    required this.subtitle,
    required this.onAvatar,
    required this.onAlerts,
    super.key,
  });

  final String greeting;
  final String name;
  final String initials;
  final String subtitle;
  final VoidCallback onAvatar;
  final VoidCallback onAlerts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Pressable(
              onTap: onAvatar,
              child: HexAvatar(initials: initials, size: 48),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting, style: AppText.bodySmall),
                  const SizedBox(height: 1),
                  Text(name, style: AppText.title.copyWith(fontSize: 21)),
                ],
              ),
            ),
            _AlertsButton(onTap: onAlerts),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          subtitle.toUpperCase(),
          style: AppText.hud.copyWith(
            color: AppColors.ivoryFaint,
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }
}

class _AlertsButton extends StatelessWidget {
  const _AlertsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.raised.withValues(alpha: 0.55),
          border: Border.all(color: AppColors.hairline.withValues(alpha: 0.8)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              size: 22,
              color: AppColors.ivory,
            ),
            Positioned(
              top: 10,
              right: 11,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.8),
                      blurRadius: 6,
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
