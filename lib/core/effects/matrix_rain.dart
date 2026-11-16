import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class MatrixRain extends StatefulWidget {
  const MatrixRain({this.opacity = 1, this.spacing = 20, super.key});

  final double opacity;
  final double spacing;

  @override
  State<MatrixRain> createState() => _MatrixRainState();
}

class _MatrixRainState extends State<MatrixRain>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  final _rain = _Rain();
  Duration _last = Duration.zero;
  Size _size = Size.zero;

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
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = elapsed;
    if (!_size.isEmpty) _rain.step(dt, _size);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _rain.dispose();
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
            _rain.layout(size, widget.spacing);
          }
          return RepaintBoundary(
            child: CustomPaint(
              size: size,
              painter: _RainPainter(_rain, widget.opacity),
            ),
          );
        },
      ),
    );
  }
}

class _Column {
  _Column(this.x, this.head, this.speed, this.glyphs);

  final double x;
  double head;
  double speed;
  final List<int> glyphs;
}

class _Rain extends ChangeNotifier {
  static const chars = '0123456789ABCDEF+<>=*/';
  static const cell = 17.0;

  final math.Random _random = math.Random(3);
  final List<_Column> columns = [];
  ui.Image? atlas;
  double _mutate = 0;

  void layout(Size size, double spacing) {
    atlas ??= _buildAtlas();
    columns.clear();
    final count = (size.width / spacing).ceil();
    for (var i = 0; i < count; i++) {
      columns.add(
        _Column(
          i * spacing + spacing / 2 - 5,
          _random.nextDouble() * size.height * 1.4 - size.height * 0.4,
          46 + _random.nextDouble() * 90,
          List.generate(
            6 + _random.nextInt(14),
            (_) => _random.nextInt(chars.length),
          ),
        ),
      );
    }
  }

  ui.Image _buildAtlas() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (var i = 0; i < chars.length; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: chars[i],
          style: const TextStyle(
            fontFamily: AppFonts.mono,
            fontSize: 12,
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(i * cell + (cell - painter.width) / 2, 1));
      painter.dispose();
    }
    final picture = recorder.endRecording();
    final image = picture.toImageSync(
      (chars.length * cell).ceil(),
      cell.ceil(),
    );
    picture.dispose();
    return image;
  }

  void step(double dt, Size size) {
    _mutate += dt;
    final mutate = _mutate > 0.09;
    if (mutate) _mutate = 0;
    for (final c in columns) {
      c.head += c.speed * dt;
      if (c.head - c.glyphs.length * cell > size.height) {
        c.head = -_random.nextDouble() * size.height * 0.5;
        c.speed = 46 + _random.nextDouble() * 90;
      }
      if (mutate && _random.nextDouble() < 0.35) {
        c.glyphs[_random.nextInt(c.glyphs.length)] = _random.nextInt(
          chars.length,
        );
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    atlas?.dispose();
    super.dispose();
  }
}

class _RainPainter extends CustomPainter {
  _RainPainter(this.rain, this.opacity) : super(repaint: rain);

  final _Rain rain;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final atlas = rain.atlas;
    if (atlas == null) return;

    var total = 0;
    for (final c in rain.columns) {
      total += c.glyphs.length;
    }
    final transforms = Float32List(total * 4);
    final rects = Float32List(total * 4);
    final colors = Int32List(total);

    const cell = _Rain.cell;
    var n = 0;
    for (final c in rain.columns) {
      final len = c.glyphs.length;
      final headIndex = (c.head / cell).floor();
      for (var k = 0; k < len; k++) {
        final y = (headIndex - k) * cell;
        if (y < -cell || y > size.height) continue;
        final g = c.glyphs[(headIndex - k).abs() % len];
        final fade = math.pow(1 - k / len, 1.6).toDouble();
        final color = k == 0
            ? AppColors.mint.withValues(alpha: 0.9 * opacity)
            : AppColors.glow.withValues(alpha: 0.55 * fade * opacity);

        transforms[n * 4] = 1;
        transforms[n * 4 + 1] = 0;
        transforms[n * 4 + 2] = c.x;
        transforms[n * 4 + 3] = y;
        rects[n * 4] = g * cell;
        rects[n * 4 + 1] = 0;
        rects[n * 4 + 2] = g * cell + cell;
        rects[n * 4 + 3] = cell;
        colors[n] = color.toARGB32();
        n++;
      }
    }
    if (n == 0) return;

    canvas.drawRawAtlas(
      atlas,
      Float32List.sublistView(transforms, 0, n * 4),
      Float32List.sublistView(rects, 0, n * 4),
      Int32List.sublistView(colors, 0, n),
      BlendMode.modulate,
      null,
      Paint()..filterQuality = FilterQuality.low,
    );
  }

  @override
  bool shouldRepaint(_RainPainter old) => old.opacity != opacity;
}
