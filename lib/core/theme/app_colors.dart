import 'package:flutter/painting.dart';

abstract final class AppColors {
  static const night = Color(0xFF04120D);
  static const deep = Color(0xFF061C15);
  static const surface = Color(0xFF0A2A1F);
  static const raised = Color(0xFF0F3A2B);
  static const hairline = Color(0xFF1C5A44);

  static const emerald = Color(0xFF13A673);
  static const emeraldDeep = Color(0xFF0B6B4C);
  static const glow = Color(0xFF2FE0A0);
  static const mint = Color(0xFF9FF5D2);

  static const ivory = Color(0xFFF6F1E4);
  static const ivoryDim = Color(0xFFCFC8B4);
  static const ivoryMuted = Color(0xA3F6F1E4);
  static const ivoryFaint = Color(0x61F6F1E4);
  static const ivoryGhost = Color(0x1FF6F1E4);

  static const paper = Color(0xFFF8F3E7);
  static const paperShade = Color(0xFFEFE7D4);
  static const paperLine = Color(0xFFE2D8C0);
  static const ink = Color(0xFF0A2A1F);
  static const inkMuted = Color(0x9E0A2A1F);
  static const inkFaint = Color(0x5C0A2A1F);

  static const gold = Color(0xFFD6AE45);
  static const goldLight = Color(0xFFF5DE95);
  static const goldDeep = Color(0xFF8F6A1B);

  static const coral = Color(0xFFF07F6E);

  static const goldFoil = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8A6516),
      Color(0xFFD9B048),
      Color(0xFFFFF0BC),
      Color(0xFFC99A2E),
      Color(0xFF7A5B16),
    ],
    stops: [0, 0.32, 0.5, 0.68, 1],
  );

  static const emeraldSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2FE0A0), Color(0xFF13A673), Color(0xFF0B6B4C)],
  );

  static const panel = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xE60F3A2B), Color(0xD9081F17)],
  );
}
