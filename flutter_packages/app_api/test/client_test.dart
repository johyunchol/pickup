import 'dart:convert';
import 'dart:typed_data';

import 'package:app_api/app_api.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

const _orderJson = {
  'id': 7,
  'number': 42,
  'nickname': '도윤',
  'lines': [
    {
      'menuId': 1,
      'name': '아메리카노',
      'price': 4500,
      'quantity': 2,
      'extraShot': 1,
    },
  ],
  'total': 10000,
  'status': 'making',
  'history': [
    {'status': 'received', 'at': '2026-10-15T05:28:00.000Z'},
    {'status': 'making', 'at': '2026-10-15T05:30:00.000Z'},
  ],
};

/// 네트워크 대신 [handle] 이 응답하는 Dio 어댑터
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handle);

  final ResponseBody Function(RequestOptions options, String? body) handle;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = requestStream == null
        ? null
        : utf8.decode(await requestStream.expand((c) => c).toList());
    return handle(options, body);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, [int status = 200]) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

PickupApi _api(ResponseBody Function(RequestOptions, String?) handle) =>
    PickupApi(
      Dio(BaseOptions(baseUrl: 'http://api.test'))
        ..httpClientAdapter = _FakeAdapter(handle),
    );

void main() {
  test('createOrder 는 본문을 JSON 으로 보내고 Order 로 받는다', () async {
    late RequestOptions sent;
    String? sentBody;
    final api = _api((options, body) {
      sent = options;
      sentBody = body;
      return _json(_orderJson, 201);
    });

    final order = await api.orders.createOrder(
      body: const CreateOrderBody(
        nickname: '도윤',
        items: [CreateOrderItem(menuId: 1, quantity: 2, extraShot: 1)],
      ),
    );

    expect(sent.method, 'POST');
    expect(sent.uri, Uri.parse('http://api.test/orders'));
    expect(jsonDecode(sentBody!), {
      'nickname': '도윤',
      'items': [
        {'menuId': 1, 'quantity': 2, 'extraShot': 1},
      ],
    });
    expect(order.number, 42);
    expect(order.status, OrderStatus.making);
    expect(order.lines.single.name, '아메리카노');
    expect(order.lines.single.extraShot, 1);
    expect(order.history.first.at, DateTime.utc(2026, 10, 15, 5, 28));
  });

  test('경로 파라미터를 채운다', () async {
    late Uri url;
    final api = _api((options, _) {
      url = options.uri;
      return _json(_orderJson);
    });

    await api.orders.advanceOrder(id: 7);
    expect(url, Uri.parse('http://api.test/orders/7/advance'));
  });

  test('2xx 가 아니면 DioException 에서 서버 메시지를 읽을 수 있다', () async {
    final api = _api(
      (_, _) => _json({
        'statusCode': 409,
        'code': 'CONFLICT',
        'message': '품절된 메뉴예요',
      }, 409),
    );

    expect(
      api.menu.listMenu(),
      throwsA(
        isA<DioException>()
            .having((e) => e.response?.statusCode, 'statusCode', 409)
            .having((e) => e.serverMessage, 'serverMessage', '품절된 메뉴예요'),
      ),
    );
  });

  test('enum 은 API 문자열 값과 오간다', () {
    final item = MenuItem.fromJson({
      'id': 5,
      'name': '말차라떼',
      'description': '제주 말차로 쌉싸름하게',
      'category': 'non_coffee',
      'price': 5800,
      'soldOut': false,
    });
    expect(item.category, MenuCategory.nonCoffee);
    expect(MenuCategory.nonCoffee.toJson(), 'non_coffee');
  });
}
