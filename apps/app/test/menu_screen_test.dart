import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pickup_app/main.dart';
import 'package:pickup_app/menu/menu_api.dart';

const _menuJson =
    '[{"id":1,"name":"아메리카노","price":4500},'
    '{"id":2,"name":"카페라떼","price":5000}]';

void main() {
  testWidgets('GET /menu 결과를 가격과 함께 보여 준다', (tester) async {
    Uri? requested;
    final client = MockClient((req) async {
      requested = req.url;
      return http.Response.bytes(utf8.encode(_menuJson), 200);
    });

    await tester.pumpWidget(
      PickupApp(menuApi: MenuApi(client, baseUrl: 'http://api.test')),
    );
    await tester.pumpAndSettle();

    expect(requested, Uri.parse('http://api.test/menu'));
    expect(find.text('아메리카노'), findsOneWidget);
    expect(find.text('4,500원'), findsOneWidget);
    expect(find.text('카페라떼'), findsOneWidget);
    expect(find.text('5,000원'), findsOneWidget);
  });

  testWidgets('불러오지 못하면 다시 시도 버튼을 보여 준다', (tester) async {
    var calls = 0;
    final client = MockClient((req) async {
      calls++;
      return calls == 1
          ? http.Response('', 500)
          : http.Response.bytes(utf8.encode(_menuJson), 200);
    });

    await tester.pumpWidget(
      PickupApp(menuApi: MenuApi(client, baseUrl: 'http://api.test')),
    );
    await tester.pumpAndSettle();
    expect(find.text('메뉴를 불러오지 못했습니다'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('아메리카노'), findsOneWidget);
  });
}
