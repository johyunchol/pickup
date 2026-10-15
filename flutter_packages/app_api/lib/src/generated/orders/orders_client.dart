// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_order_body.dart';
import '../models/order.dart';

part 'orders_client.g.dart';

@RestApi()
abstract class OrdersClient {
  factory OrdersClient(Dio dio, {String? baseUrl}) = _OrdersClient;

  /// 오늘 주문 목록 (사장님)
  @GET('/orders')
  Future<List<Order>> listOrders();

  /// 주문하기 (손님)
  @POST('/orders')
  Future<Order> createOrder({
    @Body() required CreateOrderBody body,
  });

  /// 주문 하나 (손님 — 상태 확인)
  @GET('/orders/{id}')
  Future<Order> getOrder({
    @Path('id') required int id,
  });

  /// 주문을 다음 상태로 (사장님)
  @POST('/orders/{id}/advance')
  Future<Order> advanceOrder({
    @Path('id') required int id,
  });

  /// 주문 취소 (손님 — 접수 상태에서만)
  @POST('/orders/{id}/cancel')
  Future<Order> cancelOrder({
    @Path('id') required int id,
  });
}
