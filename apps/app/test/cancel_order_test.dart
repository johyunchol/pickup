import 'package:app_api/app_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_app/main.dart';
import 'package:pickup_app/order/order_status_screen.dart';

import 'fake_api.dart';

/// 아메리카노 한 잔을 주문하고 내 주문 화면까지 간다.
Future<FakeApi> _order(WidgetTester tester) async {
  final fake = FakeApi();
  await tester.pumpWidget(PickupApp(api: fake.api));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('아메리카노 담기'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('장바구니 보기'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), '도윤');
  await tester.pump();
  await tester.tap(find.widgetWithText(FilledButton, '4,500원 주문하기'));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('접수 상태에서는 확인을 받고 주문을 취소한다', (tester) async {
    final fake = await _order(tester);
    final cancelButton = find.widgetWithText(OutlinedButton, '주문 취소');
    expect(cancelButton, findsOneWidget);

    // 확인 창에서 그대로 두면 아무 요청도 가지 않는다
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
    expect(find.text('주문을 취소할까요?'), findsOneWidget);
    await tester.tap(find.text('그대로 둘게요'));
    await tester.pumpAndSettle();
    expect(fake.requests.where((r) => r.url.path.endsWith('/cancel')), isEmpty);

    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, '주문 취소'));
    await tester.pumpAndSettle();

    expect(
      fake.requests.where(
        (r) => r.method == 'POST' && r.url.path == '/orders/1/cancel',
      ),
      hasLength(1),
    );
    expect(find.text('주문을 취소했어요'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '주문 취소'), findsNothing);
    // 취소한 주문은 픽업 안내·진행 막대를 보이지 않고, 더 폴링하지 않는다
    expect(find.text('번호가 불리면 왼쪽 픽업대에서 받아 가세요'), findsNothing);
    expect(find.text('제조 중'), findsNothing);
    final count = fake.requests.length;
    await tester.pump(orderPollInterval * 2);
    expect(fake.requests, hasLength(count));
  });

  testWidgets('제조가 시작되면 취소 버튼이 사라진다', (tester) async {
    final fake = await _order(tester);
    fake.advance(OrderStatus.making);
    await tester.pump(orderPollInterval);
    await tester.pumpAndSettle();
    expect(find.text('지금 만들고 있어요'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '주문 취소'), findsNothing);
  });

  testWidgets('취소하는 사이 제조가 시작됐으면 서버의 이유를 보여 주고 상태를 갱신한다', (tester) async {
    final fake = await _order(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, '주문 취소'));
    await tester.pumpAndSettle();
    // 확인 창이 떠 있는 사이 사장님이 제조를 시작했다
    fake.advance(OrderStatus.making);
    await tester.tap(find.widgetWithText(TextButton, '주문 취소'));
    await tester.pumpAndSettle();

    expect(find.text('주문 42번은 이미 만들기 시작해서 취소할 수 없어요'), findsOneWidget);
    expect(find.text('지금 만들고 있어요'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '주문 취소'), findsNothing);
  });
}
