// 생성 파일 — 고치지 마세요. 원본: packages/tokens/tokens.json (pnpm tokens:generate)
import 'package:flutter/widgets.dart';

/// 색
abstract final class PickupColors {
  static const bg = Color(0xFFFAF6F0);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF3EDE4);
  static const border = Color(0xFFE6DCCF);
  static const text = Color(0xFF2A211B);
  static const textMuted = Color(0xFF75675C);
  static const primary = Color(0xFF6F4429);
  static const primarySoft = Color(0xFFF0E4D8);
  static const onPrimary = Color(0xFFFFFFFF);
  static const statusReceived = Color(0xFFA84C26);
  static const statusReceivedSoft = Color(0xFFF8E6DC);
  static const statusMaking = Color(0xFF94600F);
  static const statusMakingSoft = Color(0xFFF6EBD3);
  static const statusReady = Color(0xFF3F7449);
  static const statusReadySoft = Color(0xFFE1EEDF);
  static const statusDone = Color(0xFF75675C);
  static const statusDoneSoft = Color(0xFFEEE9E3);
  static const danger = Color(0xFFB23B2A);
  static const dangerSoft = Color(0xFFF7E1DD);
}

/// 글꼴
abstract final class PickupFont {
  static const family = 'Noto Sans KR';
}

/// 글자 크기 (논리 픽셀)
abstract final class PickupFontSize {
  static const xs = 12.0;
  static const sm = 14.0;
  static const md = 16.0;
  static const lg = 18.0;
  static const xl = 22.0;
  static const xl2 = 28.0;
  static const xl3 = 36.0;
  static const display = 64.0;
}

/// 글자 굵기
abstract final class PickupFontWeight {
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const bold = FontWeight.w700;
}

/// 간격 (논리 픽셀)
abstract final class PickupSpace {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s10 = 40.0;
  static const s12 = 48.0;
}

/// 모서리 반지름 (논리 픽셀)
abstract final class PickupRadius {
  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 16.0;
  static const pill = 999.0;
}
