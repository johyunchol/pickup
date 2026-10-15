import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.g.dart';

/// [style] 에 토큰 글꼴(Noto Sans KR)을 입힌다.
///
/// google_fonts 는 굵기마다 글꼴 파일이 따로라, 테마의 글자 스타일과 다른 굵기를 쓰는
/// TextStyle 은 이걸 거쳐야 그 굵기의 파일을 불러온다. 파일은 처음 쓸 때 받아 기기에 캐시한다.
TextStyle pickupFont([TextStyle? style]) =>
    GoogleFonts.getFont(PickupFont.family, textStyle: style);

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

  TextStyle style(double size, FontWeight weight, [Color? color]) => pickupFont(
    TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color ?? PickupColors.text,
    ),
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: PickupColors.bg,
    // 글자 스타일을 따로 주지 않은 곳(버튼·입력 칸 등)의 기본 글꼴
    fontFamily: pickupFont().fontFamily,
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
