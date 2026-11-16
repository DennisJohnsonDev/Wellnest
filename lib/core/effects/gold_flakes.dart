import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';

class GoldFlakeController extends ChangeNotifier {
  final List<_BurstRequest> _pending = [];

  void burst(Offset origin, {int count = 60, double power = 1}) {
    _pending.add(_BurstRequest(origin, count, power));
    notifyListeners();
  }

  void shower({int count = 40}) {
    _pending.add(_BurstRequest(null, count, 1));
    notifyListeners();
  }
}

class _BurstRequest {
  const _BurstRequest(this.origin, this.count, this.power);

  final Offset? origin;
  final int count;
  final double power;
}

class GoldFlakeField extends StatefulWidget {
  const GoldFlakeField({
    this.density = 24,
    this.controller,
    this.speed = 1,
    this.opacity = 1,
    this.seed = 7,
    super.key,
  });

  final int density;
  final GoldFlakeController? controller;
  final double speed;
  final double opacity;
  final int seed;

  @override
  State<GoldFlakeField> createState() => _GoldFlakeFieldState();
}

class _GoldFlakeFieldState extends State<GoldFlakeField>
    with SingleTickerProviderStateMixin {
  late final _system = _FlakeSystem(math.Random(widget.seed));
  late final Ticker _ticker = createTicker(_tick);
  Duration _last = Duration.zero;
  Size _size = Size.zero;
  bool _still = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_drain);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (_still) {
      _ticker.stop();
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(GoldFlakeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_drain);
      widget.controller?.addListener(_drain);
    }
  }

  void _drain() {
    final controller = widget.controller;
    if (controller == null || _size.isEmpty) return;
    for (final r in controller._pending) {
      if (r.origin == null) {
        _system.shower(_size, r.count);
      } else {
        _system.burst(r.origin!, r.count, r.power, _size);
      }
    }
    controller._pending.clear();
  }

  void _tick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = elapsed;
    if (_size.isEmpty) return;
    _system.step(dt * widget.speed, _size, widget.density);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_drain);
    _ticker.dispose();
    _system.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          if (size != _size) {
            _size = size;
            _system.seed(size, widget.density);
            WidgetsBinding.instance.addPostFrameCallback((_) => _drain());
          }
          return RepaintBoundary(
            child: CustomPaint(
              size: size,
              painter: _FlakePainter(_system, widget.opacity),
            ),
          );
        },
      ),
    );
  }
}

class _Flake {
  _Flake({
    required this.position,
    required this.velocity,
    required this.depth,
    required this.size,
    required this.angle,
    required this.spin,
    required this.flipPhase,
    required this.flipSpeed,
    required this.swayPhase,
    required this.shape,
    this.life = double.infinity,
    this.burst = false,
  });

  Offset position;
  Offset velocity;
  final double depth;
  final double size;
  double angle;
  final double spin;
  double flipPhase;
  final double flipSpeed;
  final double swayPhase;
  final int shape;
  double life;
  final bool burst;
  double age = 0;
}

class _FlakeSystem extends ChangeNotifier {
  _FlakeSystem(this._random);

  final math.Random _random;
  final List<_Flake> ambient = [];
  final List<_Flake> bursts = [];
  double time = 0;

  static final List<Path> shapes = List.generate(8, (i) {
    final r = math.Random(i * 97 + 13);
    final path = Path();
    final points = 4 + (i % 3 == 0 ? 1 : 0);
    for (var p = 0; p < points; p++) {
      final a = p / points * math.pi * 2 + (r.nextDouble() - 0.5) * 0.7;
      final rad = 0.55 + r.nextDouble() * 0.45;
      final pt = Offset(math.cos(a) * rad, math.sin(a) * rad * 0.82);
      p == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    return path..close();
  });

  _Flake _spawn(Size size, {required bool anywhere}) {
    final depth = math.pow(_random.nextDouble(), 1.6).toDouble();
    return _Flake(
      position: Offset(
        _random.nextDouble() * size.width,
        anywhere
            ? _random.nextDouble() * size.height
            : -20 - _random.nextDouble() * 60,
      ),
      velocity: Offset(0, 14 + 34 * depth + _random.nextDouble() * 10),
      depth: depth,
      size: 2.2 + 7.5 * depth + _random.nextDouble() * 1.5,
      angle: _random.nextDouble() * math.pi * 2,
      spin: (_random.nextDouble() - 0.5) * 1.4,
      flipPhase: _random.nextDouble() * math.pi * 2,
      flipSpeed: 1.2 + _random.nextDouble() * 2.4,
      swayPhase: _random.nextDouble() * math.pi * 2,
      shape: _random.nextInt(shapes.length),
    );
  }

  void seed(Size size, int count) {
    ambient
      ..clear()
      ..addAll(List.generate(count, (_) => _spawn(size, anywhere: true)));
    notifyListeners();
  }

  void shower(Size size, int count) {
    for (var i = 0; i < count; i++) {
      final f = _spawn(size, anywhere: false)
        ..position = Offset(
          _random.nextDouble() * size.width,
          -10 - _random.nextDouble() * size.height * 0.5,
        )
        ..life = 9;
      bursts.add(f);
    }
  }

  void burst(Offset origin, int count, double power, Size size) {
    for (var i = 0; i < count; i++) {
      final a = _random.nextDouble() * math.pi * 2;
      final speed = (120 + _random.nextDouble() * 420) * power;
      final depth = 0.3 + _random.nextDouble() * 0.7;
      bursts.add(
        _Flake(
          position: origin,
          velocity: Offset(
            math.cos(a) * speed,
            math.sin(a) * speed - 160 * power,
          ),
          depth: depth,
          size: 3 + 8 * depth,
          angle: _random.nextDouble() * math.pi * 2,
          spin: (_random.nextDouble() - 0.5) * 8,
          flipPhase: _random.nextDouble() * math.pi * 2,
          flipSpeed: 4 + _random.nextDouble() * 6,
          swayPhase: _random.nextDouble() * math.pi * 2,
          shape: _random.nextInt(shapes.length),
          life: 3.2 + _random.nextDouble() * 1.8,
          burst: true,
        ),
      );
    }
  }

  void step(double dt, Size size, int density) {
    time += dt;

    while (ambient.length < density) {
      ambient.add(_spawn(size, anywhere: false));
    }
    if (ambient.length > density) ambient.length = density;

    for (var i = 0; i < ambient.length; i++) {
      final f = ambient[i];
      _drift(f, dt);
      if (f.position.dy > size.height + 30) {
        ambient[i] = _spawn(size, anywhere: false);
      }
    }

    for (final f in bursts) {
      f.age += dt;
      if (f.burst) {
        final drag = math.pow(0.12, dt).toDouble();
        f.velocity = Offset(
          f.velocity.dx * drag,
          f.velocity.dy * drag + 220 * dt,
        );
        if (f.velocity.dy > 70) {
          f.velocity = Offset(f.velocity.dx, 70 + (f.velocity.dy - 70) * 0.9);
        }
        f.position += f.velocity * dt;
        f.position += Offset(math.sin(time * 1.6 + f.swayPhase) * 18 * dt, 0);
        f.angle += f.spin * dt;
        f.flipPhase += f.flipSpeed * dt;
      } else {
        _drift(f, dt);
      }
    }
    bursts.removeWhere(
      (f) => f.age > f.life || f.position.dy > size.height + 40,
    );

    notifyListeners();
  }

  void _drift(_Flake f, double dt) {
    final sway = math.sin(time * 0.9 + f.swayPhase) * (10 + 16 * f.depth);
    f.position += Offset(sway * dt, f.velocity.dy * dt);
    f.angle += f.spin * dt;
    f.flipPhase += f.flipSpeed * dt;
  }
}

class _FlakePainter extends CustomPainter {
  _FlakePainter(this.system, this.opacity) : super(repaint: system);

  final _FlakeSystem system;
  final double opacity;

  static const _deep = AppColors.goldDeep;
  static const _mid = AppColors.gold;
  static const _light = Color(0xFFFFF2C4);

  final Paint _fill = Paint()..isAntiAlias = true;
  final Paint _glint = Paint()..blendMode = BlendMode.plus;

  @override
  void paint(Canvas canvas, Size size) {
    for (final f in system.ambient) {
      _paintFlake(canvas, f, opacity);
    }
    for (final f in system.bursts) {
      final fadeIn = (f.age / 0.12).clamp(0.0, 1.0);
      final fadeOut = f.life.isFinite
          ? ((f.life - f.age) / 0.9).clamp(0.0, 1.0)
          : 1.0;
      _paintFlake(canvas, f, fadeIn * fadeOut);
    }
  }

  void _paintFlake(Canvas canvas, _Flake f, double alpha) {
    final flip = math.cos(f.flipPhase);
    final facing = flip.abs();
    final front = flip >= 0;
    final a = (0.35 + 0.65 * f.depth) * alpha;
    if (a <= 0.01) return;

    final base = front
        ? Color.lerp(_mid, _light, math.pow(facing, 3).toDouble())!
        : Color.lerp(_deep, _mid, facing * 0.6)!;
    _fill.color = base.withValues(alpha: a);

    canvas.save();
    canvas.translate(f.position.dx, f.position.dy);
    canvas.rotate(f.angle);
    canvas.scale(f.size * math.max(0.12, facing), f.size);
    canvas.drawPath(_FlakeSystem.shapes[f.shape], _fill);
    canvas.restore();

    if (front && facing > 0.965 && f.depth > 0.55) {
      final g = ((facing - 0.965) / 0.035) * a;
      final r = f.size * (0.9 + 0.6 * f.depth);
      _glint.color = _light.withValues(alpha: 0.85 * g);
      _glint.strokeWidth = 0.9;
      canvas.drawLine(
        f.position.translate(-r, 0),
        f.position.translate(r, 0),
        _glint,
      );
      canvas.drawLine(
        f.position.translate(0, -r),
        f.position.translate(0, r),
        _glint,
      );
      canvas.drawCircle(
        f.position,
        f.size * 0.45,
        _glint..color = const Color(0xFFFFFFFF).withValues(alpha: 0.7 * g),
      );
    }
  }

  @override
  bool shouldRepaint(_FlakePainter old) => old.opacity != opacity;
}
