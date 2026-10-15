// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrderItem _$CreateOrderItemFromJson(Map<String, dynamic> json) =>
    CreateOrderItem(
      menuId: (json['menuId'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$CreateOrderItemToJson(CreateOrderItem instance) =>
    <String, dynamic>{'menuId': instance.menuId, 'quantity': instance.quantity};
