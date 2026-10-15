import 'package:flutter/material.dart';

import 'tokens.g.dart';

/// 토큰으로 만든 앱 테마 — 사장님 웹(packages/tokens 의 CSS 변수)과 같은 값을 쓴다.
ThemeData pickupTheme() {
  const colorScheme = ColorScheme.light(
    primary: PickupColors.primary,
    onPrimary: PickupColors.onPrimary,
    primaryContainer: PickupColors.primarySoft,
    onPrimaryContainer: PickupColors.primary,
    secondary: PickupColors.primary,
    onSecondary: PickupColors.onPrimary,
    surface: PickupColors.surface,
    onSurface: PickupColors.text,
    onSurfaceVariant: PickupColors.textMuted,
    surfaceContainerHighest: PickupColors.surfaceMuted,
    outline: PickupColors.border,
    outlineVariant: PickupColors.border,
    error: PickupColors.danger,
    onError: PickupColors.onPrimary,
    errorContainer: PickupColors.dangerSoft,
    onErrorContainer: PickupColors.danger,
  );

  TextStyle style(double size, FontWeight weight, [Color? color]) => TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color ?? PickupColors.text,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: PickupColors.bg,
    fontFamily: PickupFont.family,
    textTheme: TextTheme(
      displayLarge: style(PickupFontSize.display, PickupFontWeight.bold),
      headlineMedium: style(PickupFontSize.xl3, PickupFontWeight.bold),
      headlineSmall: style(PickupFontSize.xl2, PickupFontWeight.bold),
      titleLarge: style(PickupFontSize.xl, PickupFontWeight.bold),
      titleMedium: style(PickupFontSize.md, PickupFontWeight.bold),
      bodyLarge: style(PickupFontSize.md, PickupFontWeight.regular),
      bodyMedium: style(PickupFontSize.sm, PickupFontWeight.regular),
      bodySmall: style(
        PickupFontSize.xs,
        PickupFontWeight.regular,
        PickupColors.textMuted,
      ),
      labelLarge: style(PickupFontSize.sm, PickupFontWeight.bold),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: PickupColors.bg,
      foregroundColor: PickupColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: PickupColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PickupRadius.lg),
        side: const BorderSide(color: PickupColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PickupColors.primary,
        foregroundColor: PickupColors.onPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: PickupSpace.s5,
          vertical: PickupSpace.s3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PickupRadius.md),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(color: PickupColors.border),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: PickupColors.primary,
    ),
  );
}
