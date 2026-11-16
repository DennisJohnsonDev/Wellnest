import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    scheme: const ColorScheme.dark(
      primary: AppColors.glow,
      onPrimary: AppColors.night,
      primaryContainer: AppColors.emeraldDeep,
      onPrimaryContainer: AppColors.ivory,
      secondary: AppColors.gold,
      onSecondary: AppColors.night,
      tertiary: AppColors.mint,
      surface: AppColors.surface,
      onSurface: AppColors.ivory,
      onSurfaceVariant: AppColors.ivoryMuted,
      surfaceContainerLowest: AppColors.night,
      surfaceContainerLow: AppColors.deep,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.raised,
      outline: AppColors.hairline,
      outlineVariant: AppColors.ivoryGhost,
      error: AppColors.coral,
      onError: AppColors.night,
    ),
    background: AppColors.night,
    foreground: AppColors.ivory,
    muted: AppColors.ivoryMuted,
  );

  static final ThemeData paper = _build(
    brightness: Brightness.light,
    scheme: const ColorScheme.light(
      primary: AppColors.emeraldDeep,
      onPrimary: AppColors.paper,
      secondary: AppColors.goldDeep,
      onSecondary: AppColors.paper,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.inkMuted,
      surfaceContainer: AppColors.paperShade,
      outline: AppColors.paperLine,
      error: AppColors.coral,
    ),
    background: AppColors.paper,
    foreground: AppColors.ink,
    muted: AppColors.inkMuted,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color background,
    required Color foreground,
    required Color muted,
  }) {
    final text = TextTheme(
      displayLarge: AppText.display.copyWith(color: foreground),
      headlineMedium: AppText.headline.copyWith(color: foreground),
      titleLarge: AppText.title.copyWith(color: foreground),
      titleMedium: AppText.titleSmall.copyWith(color: foreground),
      bodyLarge: AppText.body.copyWith(color: muted),
      bodyMedium: AppText.body.copyWith(color: muted),
      bodySmall: AppText.bodySmall.copyWith(color: muted),
      labelLarge: AppText.label.copyWith(color: foreground),
      labelSmall: AppText.hud,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: AppFonts.body,
      textTheme: text,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      dividerColor: scheme.outlineVariant,
      iconTheme: IconThemeData(color: foreground, size: 22),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: scheme.primary,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.28),
        selectionHandleColor: scheme.primary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.raised,
        contentTextStyle: AppText.label,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.hairline),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalBarrierColor: Color(0xB3020A07),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
