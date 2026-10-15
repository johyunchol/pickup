// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// 메뉴 분류 — 손님 앱의 카테고리 칩과 같다
@JsonEnum()
enum MenuCategory {
  @JsonValue('coffee')
  coffee('coffee'),
  @JsonValue('non_coffee')
  nonCoffee('non_coffee'),
  @JsonValue('dessert')
  dessert('dessert');

  const MenuCategory(this.json);

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError('Cannot convert enum value with null JSON representation to String. '
          'This usually happens for \$unknown or @JsonValue(null) entries.');
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();
}
