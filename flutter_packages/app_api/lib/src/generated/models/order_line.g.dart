// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderLine _$OrderLineFromJson(Map<String, dynamic> json) => OrderLine(
  extraShot: (json['extraShot'] as num).toInt(),
  menuId: (json['menuId'] as num).toInt(),
  name: json['name'] as String,
  price: (json['price'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$OrderLineToJson(OrderLine instance) => <String, dynamic>{
  'extraShot': instance.extraShot,
  'menuId': instance.menuId,
  'name': instance.name,
  'price': instance.price,
  'quantity': instance.quantity,
};
