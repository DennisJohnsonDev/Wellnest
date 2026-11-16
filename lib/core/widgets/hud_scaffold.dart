import 'package:flutter/material.dart';

import '../effects/gold_flakes.dart';
import '../effects/matrix_backdrop.dart';
import '../theme/app_colors.dart';

class HudBackground extends StatelessWidget {
  const HudBackground({
    this.flakes = 14,
    this.focus = const Alignment(0, -0.75),
    this.intensity = 1,
    super.key,
  });

  final int flakes;
  final Alignment focus;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MatrixBackdrop(focus: focus, intensity: intensity),
        if (flakes > 0)
          GoldFlakeField(density: flakes, speed: 0.6, opacity: 0.8),
      ],
    );
  }
}

class HudScaffold extends StatelessWidget {
  const HudScaffold({
    required this.body,
    this.flakes = 12,
    this.focus = const Alignment(0, -0.75),
    this.bottom,
    super.key,
  });

  final Widget body;
  final int flakes;
  final Alignment focus;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      body: Stack(
        fit: StackFit.expand,
        children: [
          HudBackground(flakes: flakes, focus: focus),
          body,
          if (bottom != null)
            Positioned(left: 0, right: 0, bottom: 0, child: bottom!),
        ],
      ),
    );
  }
}
