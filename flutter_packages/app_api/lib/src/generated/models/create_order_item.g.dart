// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrderItem _$CreateOrderItemFromJson(Map<String, dynamic> json) =>
    CreateOrderItem(
      extraShot: (json['extraShot'] as num).toInt(),
      menuId: (json['menuId'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$CreateOrderItemToJson(CreateOrderItem instance) =>
    <String, dynamic>{
      'extraShot': instance.extraShot,
      'menuId': instance.menuId,
      'quantity': instance.quantity,
    };
