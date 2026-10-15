import 'package:app_api/app_api.dart';
import 'package:app_ui/app_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'menu/menu_screen.dart';

// api 주소 — `flutter run --dart-define=API_BASE_URL=http://...` 로 바꾼다.
// 기본값은 iOS 시뮬레이터 기준. Android 에뮬레이터에서는 http://10.0.2.2:4000 을 넘긴다.
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:4000',
);

void main() {
  runApp(PickupApp(api: PickupApi(Dio(BaseOptions(baseUrl: apiBaseUrl)))));
}

class PickupApp extends StatelessWidget {
  const PickupApp({super.key, required this.api});

  /// pnpm api:generate 로 만든 클라이언트 (flutter_packages/app_api)
  final PickupApi api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pickup',
      theme: pickupTheme(),
      home: MenuScreen(api: api),
    );
  }
}
