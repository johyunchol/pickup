// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'menu/menu_client.dart';
import 'orders/orders_client.dart';

/// pickup api `v0.1.0`.
///
/// 생성 파일 — 고치지 마세요. 원본: apps/api 의 컨트롤러와 packages/contract (pnpm api:generate).
class PickupApi {
  PickupApi(
    Dio dio, {
    String? baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '0.1.0';

  MenuClient? _menu;
  OrdersClient? _orders;

  MenuClient get menu => _menu ??= MenuClient(_dio, baseUrl: _baseUrl);

  OrdersClient get orders => _orders ??= OrdersClient(_dio, baseUrl: _baseUrl);
}
