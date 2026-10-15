import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_app/main.dart';

import 'fake_api.dart';

void main() {
  testWidgets('GET /menu 결과를 가격과 함께, 품절은 담기 없이 보여 준다', (tester) async {
    final fake = FakeApi();
    await tester.pumpWidget(PickupApp(api: fake.api));
    await tester.pumpAndSettle();

    expect(fake.requests.single.url, Uri.parse('http://api.test/menu'));
    expect(find.text('아메리카노'), findsOneWidget);
    expect(find.text('4,500원'), findsOneWidget);
    expect(find.text('품절'), findsOneWidget);
    expect(find.byTooltip('아메리카노 담기'), findsOneWidget);
    expect(find.byTooltip('콜드브루 담기'), findsNothing);
  });

  testWidgets('카테고리 칩으로 거른다', (tester) async {
    await tester.pumpWidget(PickupApp(api: FakeApi().api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('디저트'));
    await tester.pumpAndSettle();
    expect(find.text('버터 스콘'), findsOneWidget);
    expect(find.text('아메리카노'), findsNothing);
  });

  testWidgets('담으면 장바구니 바에 개수와 합계가 보인다', (tester) async {
    await tester.pumpWidget(PickupApp(api: FakeApi().api));
    await tester.pumpAndSettle();
    expect(find.text('장바구니 보기'), findsNothing);

    await tester.tap(find.byTooltip('아메리카노 담기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('아메리카노 더 담기'));
    await tester.tap(find.byTooltip('버터 스콘 담기'));
    await tester.pumpAndSettle();

    expect(find.text('장바구니 보기'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('12,800원'), findsOneWidget);

    await tester.tap(find.byTooltip('버터 스콘 빼기'));
    await tester.pumpAndSettle();
    expect(find.text('9,000원'), findsOneWidget);
  });

  testWidgets('불러오지 못하면 다시 시도 버튼을 보여 준다', (tester) async {
    final fake = FakeApi()..failMenu = true;
    await tester.pumpWidget(PickupApp(api: fake.api));
    await tester.pumpAndSettle();
    expect(find.text('메뉴를 불러오지 못했습니다'), findsOneWidget);

    fake.failMenu = false;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('아메리카노'), findsOneWidget);
  });
}
