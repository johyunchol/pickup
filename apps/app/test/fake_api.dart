import 'dart:convert';
import 'dart:typed_data';

import 'package:app_api/app_api.dart';
import 'package:dio/dio.dart';
import 'package:pickup_app/shot.dart';

const testMenu = [
  MenuItem(
    id: 1,
    name: '아메리카노',
    description: '진하고 깔끔한 기본 한 잔',
    category: MenuCategory.coffee,
    price: 4500,
    soldOut: false,
  ),
  MenuItem(
    id: 4,
    name: '콜드브루',
    description: '12시간 천천히 내린 커피',
    category: MenuCategory.coffee,
    price: 5000,
    soldOut: true,
  ),
  MenuItem(
    id: 6,
    name: '버터 스콘',
    description: '매일 아침 굽는 스콘',
    category: MenuCategory.dessert,
    price: 3800,
    soldOut: false,
  ),
];

/// 가짜 api 가 받은 요청 하나
typedef FakeRequest = ({String method, Uri url, String body});

/// 메모리에 주문을 들고 있는 가짜 api — 생성 클라이언트(PickupApi)를 그대로 태운다.
class FakeApi implements HttpClientAdapter {
  final requests = <FakeRequest>[];
  Order? order;

  /// true 면 GET /menu 가 500 을 돌려준다.
  bool failMenu = false;

  late final api = PickupApi(
    Dio(BaseOptions(baseUrl: 'http://api.test'))..httpClientAdapter = this,
  );

  /// 사장님이 다음 단계로 넘긴 것처럼
  void advance(OrderStatus status) {
    final o = order!;
    order = Order(
      id: o.id,
      number: o.number,
      nickname: o.nickname,
      lines: o.lines,
      total: o.total,
      status: status,
      history: [
        ...o.history,
        StatusChange(status: status, at: DateTime.utc(2026, 10, 15, 5, 30)),
      ],
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final req = (
      method: options.method,
      url: options.uri,
      body: requestStream == null
          ? ''
          : utf8.decode(await requestStream.expand((c) => c).toList()),
    );
    requests.add(req);
    final path = req.url.path;
    if (req.method == 'GET' && path == '/menu') {
      return failMenu
          ? ResponseBody.fromString('', 500)
          : _json([for (final m in testMenu) m.toJson()]);
    }
    if (req.method == 'POST' && path == '/orders') {
      final body = CreateOrderBody.fromJson(
        jsonDecode(req.body) as Map<String, Object?>,
      );
      final lines = [
        for (final i in body.items)
          () {
            final m = testMenu.firstWhere((m) => m.id == i.menuId);
            return OrderLine(
              menuId: m.id,
              name: m.name,
              price: m.price,
              quantity: i.quantity,
              extraShot: i.extraShot,
            );
          }(),
      ];
      order = Order(
        id: 1,
        number: 42,
        nickname: body.nickname,
        lines: lines,
        total: lines.fold(0, (s, l) => s + l.amount),
        status: OrderStatus.received,
        history: [
          StatusChange(
            status: OrderStatus.received,
            at: DateTime.utc(2026, 10, 15, 5, 28),
          ),
        ],
      );
      return _json(order!.toJson(), 201);
    }
    if (req.method == 'GET' && path == '/orders/1') {
      return _json(order!.toJson());
    }
    return ResponseBody.fromString('not found', 404);
  }

  @override
  void close({bool force = false}) {}

  static ResponseBody _json(Object body, [int status = 200]) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}
