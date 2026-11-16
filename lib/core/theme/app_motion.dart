import 'package:flutter/animation.dart';

abstract final class AppMotion {
  static const instant = Duration(milliseconds: 120);
  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 420);
  static const glide = Duration(milliseconds: 640);
  static const ambient = Duration(seconds: 14);

  static const easeOut = Curves.easeOutCubic;
  static const easeInOut = Curves.easeInOutCubic;
  static const settle = Curves.easeOutQuart;
  static const emphasized = Curves.easeInOutCubicEmphasized;
  static const overshoot = Curves.easeOutBack;
  static const snap = Cubic(0.2, 0.9, 0.1, 1.04);
}
