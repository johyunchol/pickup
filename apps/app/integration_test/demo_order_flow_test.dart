// 시연 녹화용 — 실제 api 서버에 붙어 손님 주문 흐름을 사람 속도로 따라간다.
//
// api 를 먼저 띄우고(저장소 루트에서 pnpm dev), 시뮬레이터를 지정해 실행한다.
//   flutter test integration_test/demo_order_flow_test.dart -d <기기> \
//     --dart-define=API_BASE_URL=http://localhost:4000
//
// 사장님 화면에서 상태를 넘기면 3초 폴링으로 바뀌는 것까지 화면에 담기도록,
// 주문 뒤에도 '픽업을 마쳤어요'(또는 시간 초과)까지 앱을 띄워 둔다.
// 'TL <이름> <ms>' 줄은 영상 편집용 벽시계 시각(epoch ms)이다.
import 'package:app_api/app_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pickup_app/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  // 녹화 화면에 DEBUG 띠가 나오지 않게 — 앱 코드는 그대로 둔다.
  WidgetsApp.debugAllowBannerOverride = false;

  void mark(String name) =>
      // ignore: avoid_print
      print('TL $name ${DateTime.now().millisecondsSinceEpoch}');

  testWidgets('시연: 아메리카노·카페라떼 주문 → 내 주문 상태 갱신', (tester) async {
    Future<void> pause(int ms) async {
      await Future<void>.delayed(Duration(milliseconds: ms));
      await tester.pump();
    }

    /// [finder] 가 화면에 나올 때까지 기다린다 (실시간, 100ms 간격).
    Future<bool> waitFor(Finder finder, Duration timeout) async {
      final end = DateTime.now().add(timeout);
      while (DateTime.now().isBefore(end)) {
        if (finder.evaluate().isNotEmpty) return true;
        await pause(100);
      }
      return false;
    }

    await tester.pumpWidget(
      PickupApp(api: PickupApi(Dio(BaseOptions(baseUrl: apiBaseUrl)))),
    );
    expect(
      await waitFor(find.byTooltip('아메리카노 담기'), const Duration(seconds: 20)),
      isTrue,
    );
    mark('app_menu_ready');
    await pause(2500);

    await tester.tap(find.byTooltip('아메리카노 담기'));
    mark('app_tap_americano');
    await pause(1300);
    await tester.tap(find.byTooltip('카페라떼 담기'));
    mark('app_tap_latte');
    await pause(1500);

    await tester.tap(find.text('장바구니 보기'));
    mark('app_open_cart');
    await pause(1800);

    await tester.tap(find.byType(TextField));
    await pause(700);
    await tester.enterText(find.byType(TextField), '도');
    await pause(400);
    await tester.enterText(find.byType(TextField), '도윤');
    mark('app_nickname_entered');
    await pause(1000);
    FocusManager.instance.primaryFocus?.unfocus();
    await pause(1000);

    await tester.tap(find.byType(FilledButton));
    mark('app_order_submitted');
    expect(
      await waitFor(find.text('주문을 받았어요'), const Duration(seconds: 10)),
      isTrue,
    );
    mark('app_shows_received');

    // 사장님이 넘기는 단계를 기다린다 — 폴링 3초라 화면이 늦게 바뀌는 그대로 담는다.
    for (final (name, headline) in [
      ('making', '지금 만들고 있어요'),
      ('ready', '픽업대에 나왔어요'),
      ('done', '픽업을 마쳤어요'),
    ]) {
      if (await waitFor(find.text(headline), const Duration(seconds: 90))) {
        mark('app_shows_$name');
      } else {
        mark('app_timeout_$name');
        break;
      }
    }
    await pause(4000);
    mark('app_end');
  }, timeout: const Timeout(Duration(minutes: 6)));

  testWidgets('시연: 주문 취소', (tester) async {
    Future<void> pause(int ms) async {
      await Future<void>.delayed(Duration(milliseconds: ms));
      await tester.pump();
    }

    Future<bool> waitFor(Finder finder, Duration timeout) async {
      final end = DateTime.now().add(timeout);
      while (DateTime.now().isBefore(end)) {
        if (finder.evaluate().isNotEmpty) return true;
        await pause(100);
      }
      return false;
    }

    await tester.pumpWidget(
      PickupApp(api: PickupApi(Dio(BaseOptions(baseUrl: apiBaseUrl)))),
    );
    expect(
      await waitFor(find.byTooltip('아메리카노 담기'), const Duration(seconds: 20)),
      isTrue,
    );
    mark('app_menu_ready');
    await pause(2000);
    await tester.tap(find.byTooltip('아메리카노 담기'));
    await pause(1300);
    await tester.tap(find.text('장바구니 보기'));
    await pause(1500);
    await tester.tap(find.byType(TextField));
    await pause(600);
    await tester.enterText(find.byType(TextField), '예린');
    await pause(900);
    FocusManager.instance.primaryFocus?.unfocus();
    await pause(900);
    await tester.tap(find.byType(FilledButton));
    mark('app_order_submitted');
    expect(
      await waitFor(find.text('주문을 받았어요'), const Duration(seconds: 10)),
      isTrue,
    );
    mark('app_shows_received');
    await pause(2500);

    await tester.tap(find.text('주문 취소').last);
    mark('app_tap_cancel');
    expect(
      await waitFor(find.text('주문을 취소할까요?'), const Duration(seconds: 5)),
      isTrue,
    );
    await pause(1800);
    await tester.tap(find.text('주문 취소').last);
    mark('app_confirm_cancel');
    expect(
      await waitFor(find.text('주문을 취소했어요'), const Duration(seconds: 10)),
      isTrue,
    );
    mark('app_shows_cancelled');
    await pause(5000);
    mark('app_end');
  }, timeout: const Timeout(Duration(minutes: 4)));

  // 메뉴 화면만 잠깐 띄워 둔다 — 토큰 색을 바꾼 앞뒤 캡처용.
  //   flutter test integration_test/demo_order_flow_test.dart --plain-name '시연: 메뉴 화면' ...
  testWidgets('시연: 메뉴 화면', (tester) async {
    await tester.pumpWidget(
      PickupApp(api: PickupApi(Dio(BaseOptions(baseUrl: apiBaseUrl)))),
    );
    final end = DateTime.now().add(const Duration(seconds: 20));
    while (find.byTooltip('아메리카노 담기').evaluate().isEmpty &&
        DateTime.now().isBefore(end)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    }
    mark('app_menu_ready');
    await Future<void>.delayed(const Duration(seconds: 5));
    await tester.pump();
    // 하나 담으면 장바구니 바·수량 버튼이 primary 색으로 나온다
    await tester.tap(find.byTooltip('아메리카노 담기'));
    mark('app_tap_americano');
    await Future<void>.delayed(const Duration(seconds: 5));
    await tester.pump();
    mark('app_end');
  });
}
