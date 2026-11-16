import 'package:flutter/widgets.dart';

import 'app_colors.dart';

abstract final class AppFonts {
  static const display = 'Sora';
  static const body = 'Inter';
  static const mono = 'JetBrainsMono';
  static const serif = 'Newsreader';
}

abstract final class AppText {
  static const _tabular = [FontFeature.tabularFigures()];

  static const display = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 34,
    height: 1.12,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.1,
    color: AppColors.ivory,
  );

  static const headline = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 26,
    height: 1.18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.7,
    color: AppColors.ivory,
  );

  static const title = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: AppColors.ivory,
  );

  static const titleSmall = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.ivory,
  );

  static const body = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    color: AppColors.ivoryMuted,
  );

  static const bodySmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 13,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.ivoryMuted,
  );

  static const label = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: AppColors.ivory,
  );

  static const button = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.night,
  );

  static const hud = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 10.5,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.8,
    color: AppColors.glow,
  );

  static const data = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: AppColors.ivory,
    fontFeatures: _tabular,
  );

  static const metric = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 30,
    height: 1,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.2,
    color: AppColors.ivory,
    fontFeatures: _tabular,
  );

  static const serifTitle = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 30,
    height: 1.18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );

  static const serifBody = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 18.5,
    height: 1.62,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );
}
