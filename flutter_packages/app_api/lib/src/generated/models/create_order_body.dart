// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'create_order_item.dart';

part 'create_order_body.g.dart';

@JsonSerializable()
class CreateOrderBody {
  const CreateOrderBody({
    required this.items,
    required this.nickname,
  });
  
  factory CreateOrderBody.fromJson(Map<String, Object?> json) => _$CreateOrderBodyFromJson(json);
  
  final List<CreateOrderItem> items;
  final String nickname;

  Map<String, Object?> toJson() => _$CreateOrderBodyToJson(this);
}
