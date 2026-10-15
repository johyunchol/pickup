// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'order_line.g.dart';

@JsonSerializable()
class OrderLine {
  const OrderLine({
    required this.menuId,
    required this.name,
    required this.price,
    required this.quantity,
  });
  
  factory OrderLine.fromJson(Map<String, Object?> json) => _$OrderLineFromJson(json);
  
  final int menuId;
  final String name;
  final int price;
  final int quantity;

  Map<String, Object?> toJson() => _$OrderLineToJson(this);
}
