import 'dart:convert';

import 'package:app_api/app_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_app/main.dart';
import 'package:pickup_app/order/order_status_screen.dart';

import 'fake_api.dart';

void main() {
  testWidgets('닉네임을 넣어 주문하면 큰 주문 번호와 상태를 보여 주고, 폴링으로 갱신한다', (tester) async {
    final fake = FakeApi();
    await tester.pumpWidget(PickupApp(api: fake.api));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('아메리카노 담기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('장바구니 보기'));
    await tester.pumpAndSettle();

    // 닉네임이 없으면 주문할 수 없다
    final orderButton = find.widgetWithText(FilledButton, '4,500원 주문하기');
    expect(tester.widget<FilledButton>(orderButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField), ' 도윤 ');
    await tester.pump();
    await tester.tap(orderButton);
    await tester.pumpAndSettle();

    final sent = fake.requests.firstWhere((r) => r.method == 'POST');
    expect(jsonDecode(sent.body), {
      'nickname': '도윤',
      'items': [
        {'menuId': 1, 'quantity': 1},
      ],
    });

    expect(find.text('042'), findsOneWidget);
    expect(find.text('도윤 님의 주문'), findsOneWidget);
    expect(find.text('주문을 받았어요'), findsOneWidget);

    // 사장님이 제조 시작 → 3초 안에 바뀐다
    fake.advance(OrderStatus.making);
    await tester.pump(orderPollInterval);
    await tester.pumpAndSettle();
    expect(find.text('지금 만들고 있어요'), findsOneWidget);

    // 뒤로 가면 장바구니는 비어 있고, 내 주문 버튼이 생긴다
    await tester.tap(find.byTooltip('뒤로'));
    await tester.pumpAndSettle();
    expect(find.text('장바구니 보기'), findsNothing);
    expect(find.byTooltip('내 주문'), findsOneWidget);
  });
}
