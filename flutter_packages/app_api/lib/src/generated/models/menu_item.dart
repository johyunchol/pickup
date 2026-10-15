// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'menu_category.dart';

part 'menu_item.g.dart';

@JsonSerializable()
class MenuItem {
  const MenuItem({
    required this.category,
    required this.description,
    required this.id,
    required this.name,
    required this.price,
    required this.soldOut,
  });
  
  factory MenuItem.fromJson(Map<String, Object?> json) => _$MenuItemFromJson(json);
  
  final MenuCategory category;
  final String description;
  final int id;
  final String name;

  /// 원 단위 가격
  final int price;
  final bool soldOut;

  Map<String, Object?> toJson() => _$MenuItemToJson(this);
}
