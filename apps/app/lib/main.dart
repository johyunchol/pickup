import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'menu/menu_api.dart';
import 'menu/menu_screen.dart';

// api 주소 — `flutter run --dart-define=API_BASE_URL=http://...` 로 바꾼다.
// 기본값은 iOS 시뮬레이터 기준. Android 에뮬레이터에서는 http://10.0.2.2:4000 을 넘긴다.
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:4000',
);

void main() {
  runApp(PickupApp(menuApi: MenuApi(http.Client(), baseUrl: apiBaseUrl)));
}

class PickupApp extends StatelessWidget {
  const PickupApp({super.key, required this.menuApi});

  final MenuApi menuApi;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pickup',
      theme: ThemeData(colorSchemeSeed: Colors.brown),
      home: MenuScreen(menuApi: menuApi),
    );
  }
}
