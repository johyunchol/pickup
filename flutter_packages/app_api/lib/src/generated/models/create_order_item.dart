// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_order_item.g.dart';

@JsonSerializable()
class CreateOrderItem {
  const CreateOrderItem({
    required this.extraShot,
    required this.menuId,
    required this.quantity,
  });
  
  factory CreateOrderItem.fromJson(Map<String, Object?> json) => _$CreateOrderItemFromJson(json);
  
  /// 샷 추가 횟수 0~2번 · 커피 메뉴만 · 한 번에 500원
  final int extraShot;
  final int menuId;
  final int quantity;

  Map<String, Object?> toJson() => _$CreateOrderItemToJson(this);
}
