import 'dart:convert';

import 'package:http/http.dart' as http;

import 'menu_item.dart';

class MenuApi {
  MenuApi(this._client, {required this.baseUrl});

  final http.Client _client;
  final String baseUrl;

  Future<List<MenuItem>> fetchMenu() async {
    final res = await _client.get(Uri.parse('$baseUrl/menu'));
    if (res.statusCode != 200) {
      throw Exception('메뉴를 불러오지 못했습니다 (${res.statusCode})');
    }
    final list = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
    return list
        .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
