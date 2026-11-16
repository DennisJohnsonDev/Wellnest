import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GoldFoil extends StatefulWidget {
  const GoldFoil({
    required this.child,
    this.animate = true,
    this.period = const Duration(milliseconds: 3600),
    super.key,
  });

  final Widget child;
  final bool animate;
  final Duration period;

  @override
  State<GoldFoil> createState() => _GoldFoilState();
}

class _GoldFoilState extends State<GoldFoil>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.animate && !MediaQuery.disableAnimationsOf(context)) {
      _controller.repeat();
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFF9C7420),
            Color(0xFFD9B048),
            Color(0xFFFFF3C8),
            Color(0xFFD9B048),
            Color(0xFF9C7420),
          ],
          stops: const [0, 0.38, 0.5, 0.62, 1],
          transform: _Slide(_controller.value),
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class Sheen extends StatefulWidget {
  const Sheen({
    required this.child,
    this.color = const Color(0x55FFFFFF),
    this.period = const Duration(milliseconds: 4200),
    this.width = 0.18,
    super.key,
  });

  final Widget child;
  final Color color;
  final Duration period;
  final double width;

  @override
  State<Sheen> createState() => _SheenState();
}

class _SheenState extends State<Sheen> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context)) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = Curves.easeInOutSine.transform(
                  (_controller.value * 1.6).clamp(0.0, 1.0),
                );
                final center = -0.3 + t * 1.6;
                final w = widget.width;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(-1, -0.6),
                      end: const Alignment(1, 0.6),
                      colors: [
                        widget.color.withValues(alpha: 0),
                        widget.color,
                        widget.color.withValues(alpha: 0),
                      ],
                      stops: [
                        (center - w).clamp(0.0, 1.0),
                        center.clamp(0.0, 1.0),
                        (center + w).clamp(0.0, 1.0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class GoldText extends StatelessWidget {
  const GoldText(
    this.text, {
    required this.style,
    this.animate = true,
    super.key,
  });

  final String text;
  final TextStyle style;
  final bool animate;

  @override
  Widget build(BuildContext context) => GoldFoil(
    animate: animate,
    child: Text(text, style: style.copyWith(color: AppColors.gold)),
  );
}

class _Slide extends GradientTransform {
  const _Slide(this.t);

  final double t;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (t * 2.4 - 1.2), 0, 0);
}
