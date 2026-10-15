import 'dart:convert';

import 'package:app_api/app_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_app/cart.dart';
import 'package:pickup_app/main.dart';

import 'fake_api.dart';

void main() {
  group('Cart 샷 추가', () {
    final americano = testMenu[0];
    final scone = testMenu[2];

    test('샷마다 500원 — 담은 잔 모두에 붙고, 주문 줄에 실린다', () {
      final cart = Cart()
        ..add(americano)
        ..add(americano)
        ..setExtraShot(americano, 2)
        ..add(scone);
      expect(cart.extraShotOf(americano.id), 2);
      expect(cart.total, (4500 + 1000) * 2 + 3800);
      expect(
        [for (final i in cart.toOrderItems()) i.toJson()],
        [
          {'extraShot': 2, 'menuId': 1, 'quantity': 2},
          {'extraShot': 0, 'menuId': 6, 'quantity': 1},
        ],
      );
    });

    test('커피가 아니거나 담지 않은 메뉴는 바꾸지 않고, 0~2 로 자른다', () {
      final cart = Cart()
        ..add(scone)
        ..setExtraShot(scone, 1)
        ..setExtraShot(americano, 1);
      expect(cart.extraShotOf(scone.id), 0);
      expect(cart.quantityOf(americano.id), 0);

      cart
        ..add(americano)
        ..setExtraShot(americano, 5);
      expect(cart.extraShotOf(americano.id), 2);
    });

    test('빼다가 다시 담으면 샷 추가는 처음부터', () {
      final cart = Cart()
        ..add(americano)
        ..setExtraShot(americano, 1)
        ..remove(americano)
        ..add(americano);
      expect(cart.extraShotOf(americano.id), 0);
    });
  });

  testWidgets('커피 카드에서 샷을 고르면 장바구니·주문하기·주문 내역 금액에 반영된다', (tester) async {
    final fake = FakeApi();
    await tester.pumpWidget(PickupApp(api: fake.api));
    await tester.pumpAndSettle();

    // 담기 전에는 샷 선택이 없다
    expect(find.byTooltip('아메리카노 샷 +1'), findsNothing);

    await tester.tap(find.byTooltip('아메리카노 담기'));
    await tester.tap(find.byTooltip('버터 스콘 담기'));
    await tester.pumpAndSettle();
    // 커피에만 샷 선택이 생긴다
    expect(find.byTooltip('아메리카노 샷 +1'), findsOneWidget);
    expect(find.byTooltip('버터 스콘 샷 +1'), findsNothing);

    await tester.tap(find.byTooltip('아메리카노 더 담기'));
    await tester.tap(find.byTooltip('아메리카노 샷 +2'));
    await tester.pumpAndSettle();
    // 카드 가격은 한 잔 값, 장바구니는 (4,500 + 1,000) × 2 + 3,800
    expect(find.text('5,500원'), findsOneWidget);
    expect(find.text('14,800원'), findsOneWidget);

    await tester.tap(find.text('장바구니 보기'));
    await tester.pumpAndSettle();
    expect(find.text('아메리카노 (샷 +2) × 2'), findsOneWidget);
    expect(find.text('11,000원'), findsOneWidget);
    expect(find.text('버터 스콘 × 1'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '도윤');
    await tester.pump();
    await tester.tap(find.text('14,800원 주문하기'));
    await tester.pumpAndSettle();

    final sent = fake.requests.firstWhere((r) => r.method == 'POST');
    expect(jsonDecode(sent.body), {
      'nickname': '도윤',
      'items': [
        {'menuId': 1, 'quantity': 2, 'extraShot': 2},
        {'menuId': 6, 'quantity': 1, 'extraShot': 0},
      ],
    });

    // 내 주문 화면 — 서버가 돌려준 줄로 다시 그린다
    expect(fake.order!.status, OrderStatus.received);
    expect(find.text('아메리카노 (샷 +2) × 2'), findsOneWidget);
    expect(find.text('11,000원'), findsOneWidget);
    expect(find.text('14,800원'), findsOneWidget);
  });
}
