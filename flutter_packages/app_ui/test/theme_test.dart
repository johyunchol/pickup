import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // google_fonts 가 글꼴 파일을 찾을 때 asset 번들을 쓴다.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('테마가 토큰 색을 그대로 쓴다', () {
    final theme = pickupTheme();
    expect(theme.colorScheme.primary, PickupColors.primary);
    expect(theme.colorScheme.onSurface, PickupColors.text);
    expect(theme.scaffoldBackgroundColor, PickupColors.bg);
  });

  test('카드 모서리는 radius-lg 토큰이다', () {
    final shape = pickupTheme().cardTheme.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(PickupRadius.lg));
  });

  test('글꼴은 토큰의 Noto Sans KR 이고, 굵기마다 그 굵기의 파일을 쓴다', () {
    final text = pickupTheme().textTheme;
    expect(text.bodyLarge!.fontFamily, 'NotoSansKR_regular');
    expect(text.titleLarge!.fontFamily, 'NotoSansKR_700');
    expect(
      pickupFont(const TextStyle(fontWeight: PickupFontWeight.medium))
          .fontFamily,
      'NotoSansKR_500',
    );
  });
}
