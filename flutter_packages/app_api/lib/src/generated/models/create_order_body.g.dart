// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrderBody _$CreateOrderBodyFromJson(Map<String, dynamic> json) =>
    CreateOrderBody(
      items: (json['items'] as List<dynamic>)
          .map((e) => CreateOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nickname: json['nickname'] as String,
    );

Map<String, dynamic> _$CreateOrderBodyToJson(CreateOrderBody instance) =>
    <String, dynamic>{'items': instance.items, 'nickname': instance.nickname};
